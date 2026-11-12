package uz.pdp.mini_blok_with_jakarta.service;

import jakarta.servlet.http.HttpServletRequest;
import uz.pdp.mini_blok_with_jakarta.dao.AdminDao;
import uz.pdp.mini_blok_with_jakarta.entity.AdminLog;
import uz.pdp.mini_blok_with_jakarta.entity.AdminUser;
import uz.pdp.mini_blok_with_jakarta.security.ClientIp;
import uz.pdp.mini_blok_with_jakarta.security.LoginThrottle;
import uz.pdp.mini_blok_with_jakarta.utils.PasswordUtils;
import uz.pdp.mini_blok_with_jakarta.utils.Totp;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.regex.Pattern;

public class AdminService {
    public static final int MAX_FAILS = 5;                 // shundan keyin akkaunt 15 daqiqaga bloklanadi
    public static final int LOCK_MINUTES = 15;
    /** Bir IP dan 15 daqiqada 10 ta xato urinish — keyin shu IP vaqtincha bloklanadi */
    public static final LoginThrottle IP_THROTTLE = new LoginThrottle(10, 15 * 60_000L);
    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_.-]{4,40}$");
    /** Mavjud bo'lmagan login uchun ham parol tekshiruvi vaqti bir xil bo'lsin (login borligini bilib bo'lmasin) */
    private static final String DUMMY_HASH = PasswordUtils.hash("dummy-password-for-timing");

    private final AdminDao dao = new AdminDao();

    public enum Result { OK, BAD, LOCKED, IP_BLOCKED }

    /** 1-qadam: login va parol. Muvaffaqiyatli bo'lsa admin qaytariladi (2FA hali so'raladi). */
    public Result checkPassword(HttpServletRequest req, String username, String password, AdminUser[] out) {
        String ip = ClientIp.of(req);
        if (IP_THROTTLE.isBlocked(ip)) {
            log(req, null, username, "LOGIN", "IP_BLOCKED", null, "IP vaqtincha bloklangan", false);
            return Result.IP_BLOCKED;
        }
        if (username == null || password == null || username.length() > 40 || password.length() > 200) {
            IP_THROTTLE.fail(ip);
            return Result.BAD;
        }
        Optional<AdminUser> opt = dao.findAdmin(username.trim());
        if (opt.isEmpty()) {
            PasswordUtils.matches(password, DUMMY_HASH);
            IP_THROTTLE.fail(ip);
            log(req, null, username, "LOGIN", "PASSWORD", null, "Bunday admin yo'q", false);
            return Result.BAD;
        }
        AdminUser a = opt.get();
        if (a.getLockedUntil() != null && a.getLockedUntil().isAfter(LocalDateTime.now())) {
            log(req, a, null, "LOGIN", "LOCKED", null, "Akkaunt bloklangan holatda urinish", false);
            return Result.LOCKED;
        }
        if (!Boolean.TRUE.equals(a.getEnabled()) || !PasswordUtils.matches(password, a.getPassword())) {
            registerFail(req, a, "PASSWORD");
            return Result.BAD;
        }
        out[0] = a;
        log(req, a, null, "LOGIN", "PASSWORD", null, "Parol to'g'ri, 2FA kutilmoqda", true);
        return Result.OK;
    }

    /** 2-qadam: Google Authenticator kodi. */
    public Result checkTotp(HttpServletRequest req, Integer adminId, String code, AdminUser[] out) {
        String ip = ClientIp.of(req);
        if (IP_THROTTLE.isBlocked(ip)) return Result.IP_BLOCKED;
        AdminUser a = dao.findAdmin(adminId).orElse(null);
        if (a == null || !Boolean.TRUE.equals(a.getEnabled())) return Result.BAD;
        if (a.getLockedUntil() != null && a.getLockedUntil().isAfter(LocalDateTime.now())) return Result.LOCKED;
        long step = Totp.verify(a.getTotpSecret(), code, a.getTotpLastStep());
        if (step < 0) {
            registerFail(req, a, "TOTP");
            return Result.BAD;
        }
        a.setTotpLastStep(step);
        a.setFailedAttempts(0);
        a.setLockedUntil(null);
        a.setLastLoginAt(LocalDateTime.now());
        a.setLastLoginIp(ip);
        dao.updateAdmin(a);
        IP_THROTTLE.reset(ip);
        log(req, a, null, "LOGIN", "SUCCESS", null, "Muvaffaqiyatli kirish", true);
        out[0] = a;
        return Result.OK;
    }

    private void registerFail(HttpServletRequest req, AdminUser a, String stage) {
        IP_THROTTLE.fail(ClientIp.of(req));
        int f = (a.getFailedAttempts() == null ? 0 : a.getFailedAttempts()) + 1;
        a.setFailedAttempts(f);
        String det = stage.equals("TOTP") ? "Noto'g'ri 2FA kodi" : "Noto'g'ri parol";
        if (f >= MAX_FAILS) {
            a.setLockedUntil(LocalDateTime.now().plusMinutes(LOCK_MINUTES));
            a.setFailedAttempts(0);
            det += " — akkaunt " + LOCK_MINUTES + " daqiqaga bloklandi";
            log(req, a, null, "SECURITY", "ACCOUNT_LOCKED", a.getUsername(), det, false);
        }
        dao.updateAdmin(a);
        log(req, a, null, "LOGIN", stage, null, det, false);
    }

    public String validateNew(String username, String password) {
        if (username == null || !USERNAME.matcher(username).matches()) return "Login 4-40 belgi: harf, raqam, _ . - bo'lishi kerak";
        return validatePassword(password);
    }

    public static String validatePassword(String p) {
        if (p == null || p.length() < 12 || p.length() > 200) return "Parol kamida 12 belgi bo'lishi kerak";
        boolean up = false, low = false, dig = false, sym = false;
        for (char c : p.toCharArray()) {
            if (Character.isUpperCase(c)) up = true;
            else if (Character.isLowerCase(c)) low = true;
            else if (Character.isDigit(c)) dig = true;
            else sym = true;
        }
        if (!(up && low && dig && sym)) return "Parolda katta va kichik harf, raqam va belgi (!@# kabi) bo'lishi kerak";
        return null;
    }

    public AdminUser create(String username, String password, String secret, boolean superAdmin) {
        AdminUser a = AdminUser.builder()
                .username(username.trim())
                .password(PasswordUtils.hash(password))
                .totpSecret(secret)
                .enabled(true)
                .superAdmin(superAdmin)
                .failedAttempts(0)
                .build();
        dao.saveAdmin(a);
        return a;
    }

    public void log(HttpServletRequest req, AdminUser a, String username, String type, String action, String target, String details, boolean ok) {
        String ua = req.getHeader("User-Agent");
        dao.log(AdminLog.builder()
                .adminId(a == null ? null : a.getId())
                .adminUsername(a != null ? a.getUsername() : (username == null ? null : cut(username, 40)))
                .type(type).action(action).target(cut(target, 120)).details(cut(details, 1000))
                .ip(ClientIp.of(req)).userAgent(cut(ua, 300)).success(ok)
                .build());
    }

    private static String cut(String s, int n) { return s == null ? null : (s.length() > n ? s.substring(0, n) : s); }
}
