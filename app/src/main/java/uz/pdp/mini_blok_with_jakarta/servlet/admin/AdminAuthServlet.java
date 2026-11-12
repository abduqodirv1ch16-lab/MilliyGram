package uz.pdp.mini_blok_with_jakarta.servlet.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.AdminDao;
import uz.pdp.mini_blok_with_jakarta.entity.AdminUser;
import uz.pdp.mini_blok_with_jakarta.security.AdminFilter;
import uz.pdp.mini_blok_with_jakarta.service.AdminService;
import uz.pdp.mini_blok_with_jakarta.utils.QrUtils;
import uz.pdp.mini_blok_with_jakarta.utils.Totp;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/** /mgadmin/login — 2 bosqichli kirish (parol + Google Authenticator), /mgadmin/logout, /mgadmin/setup — birinchi adminni yaratish */
@WebServlet(name = "AdminAuthServlet", urlPatterns = {"/mgadmin/login", "/mgadmin/logout", "/mgadmin/setup"})
public class AdminAuthServlet extends HttpServlet {
    private static final long PENDING_MS = 5 * 60_000L;   // parol kiritilgandan keyin kod uchun 5 daqiqa
    private static final SecureRandom RND = new SecureRandom();
    private final AdminService service = new AdminService();
    private final AdminDao dao = new AdminDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (path.equals("/mgadmin/logout")) { resp.sendError(405); return; }
        if (path.equals("/mgadmin/setup")) { setupGet(req, resp); return; }

        HttpSession s = req.getSession(false);
        if (s != null && req.getParameter("restart") != null) { s.removeAttribute("adminPending"); s.removeAttribute("adminPendingAt"); }
        if (s != null && s.getAttribute("adminId") != null) { resp.sendRedirect(req.getContextPath() + "/mgadmin"); return; }
        boolean pending = s != null && s.getAttribute("adminPending") != null && !pendingExpired(s);
        req.setAttribute("stage", pending ? "totp" : "password");
        req.setAttribute("noAdmins", dao.countAdmins() == 0);
        req.setAttribute("formToken", newFormToken(req.getSession()));
        req.getRequestDispatcher("/WEB-INF/admin/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        if (path.equals("/mgadmin/logout")) { logout(req, resp); return; }
        if (path.equals("/mgadmin/setup")) { setupPost(req, resp); return; }

        HttpSession s = req.getSession();
        if (!formTokenOk(req, s)) { fail(req, resp, "password", "Sahifa eskirgan. Qaytadan urinib ko'ring."); return; }
        String step = req.getParameter("step");

        if ("totp".equals(step)) {
            Integer pid = (Integer) s.getAttribute("adminPending");
            if (pid == null || pendingExpired(s)) {
                AdminFilter.clearAdmin(s);
                fail(req, resp, "password", "Vaqt tugadi. Login va parolni qayta kiriting.");
                return;
            }
            AdminUser[] out = new AdminUser[1];
            AdminService.Result r = service.checkTotp(req, pid, req.getParameter("code"), out);
            if (r == AdminService.Result.OK) {
                AdminFilter.clearAdmin(s);
                req.changeSessionId();
                AdminUser a = out[0];
                s.setAttribute("adminId", a.getId());
                s.setAttribute("adminName", a.getUsername());
                s.setAttribute("adminSuper", Boolean.TRUE.equals(a.getSuperAdmin()));
                s.setAttribute("adminCsrf", token(32));
                s.setAttribute("adminSeen", System.currentTimeMillis());
                s.setAttribute("adminUa", AdminFilter.uaHash(req));
                resp.sendRedirect(req.getContextPath() + "/mgadmin");
                return;
            }
            if (r == AdminService.Result.LOCKED) {
                AdminFilter.clearAdmin(s);
                fail(req, resp, "password", "Juda ko'p xato urinish. Akkaunt " + AdminService.LOCK_MINUTES + " daqiqaga bloklandi.");
                return;
            }
            if (r == AdminService.Result.IP_BLOCKED) { AdminFilter.clearAdmin(s); fail(req, resp, "password", "Juda ko'p urinish. Keyinroq qayta urinib ko'ring."); return; }
            fail(req, resp, "totp", "Kod noto'g'ri yoki eskirgan.");
            return;
        }

        AdminUser[] out = new AdminUser[1];
        AdminService.Result r = service.checkPassword(req, req.getParameter("username"), req.getParameter("password"), out);
        if (r == AdminService.Result.OK) {
            s.setAttribute("adminPending", out[0].getId());
            s.setAttribute("adminPendingAt", System.currentTimeMillis());
            req.setAttribute("stage", "totp");
            req.setAttribute("formToken", newFormToken(s));
            req.getRequestDispatcher("/WEB-INF/admin/login.jsp").forward(req, resp);
            return;
        }
        String msg = switch (r) {
            case LOCKED -> "Juda ko'p xato urinish. Akkaunt vaqtincha bloklangan.";
            case IP_BLOCKED -> "Juda ko'p urinish. Keyinroq qayta urinib ko'ring.";
            default -> "Login yoki parol noto'g'ri.";
        };
        fail(req, resp, "password", msg);
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String stage, String msg) throws ServletException, IOException {
        try { Thread.sleep(400 + RND.nextInt(400)); } catch (InterruptedException ignored) { }   // tez-tez urinishni sekinlashtiradi
        req.setAttribute("stage", stage);
        req.setAttribute("error", msg);
        req.setAttribute("noAdmins", dao.countAdmins() == 0);
        req.setAttribute("formToken", newFormToken(req.getSession()));
        req.getRequestDispatcher("/WEB-INF/admin/login.jsp").forward(req, resp);
    }

    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        if (s != null) {
            String csrf = (String) s.getAttribute("adminCsrf");
            String given = req.getParameter("csrf");
            if (csrf != null && given != null && MessageDigest.isEqual(csrf.getBytes(), given.getBytes())) {
                Integer id = (Integer) s.getAttribute("adminId");
                if (id != null) dao.findAdmin(id).ifPresent(a -> service.log(req, a, null, "LOGIN", "LOGOUT", null, "Chiqish", true));
                AdminFilter.clearAdmin(s);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/mgadmin/login");
    }

    /* ---------------- birinchi adminni yaratish ---------------- */
    private boolean setupAllowed(HttpServletRequest req) {
        String expected = uz.pdp.mini_blok_with_jakarta.dao.BaseDao.getConfig("ADMIN_SETUP_TOKEN");
        String given = req.getParameter("token");
        return expected != null && expected.length() >= 24 && given != null
                && MessageDigest.isEqual(expected.getBytes(), given.getBytes())
                && dao.countAdmins() == 0;
    }

    private void setupGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!setupAllowed(req)) { resp.sendError(404); return; }
        HttpSession s = req.getSession();
        String secret = (String) s.getAttribute("setupSecret");
        if (secret == null) { secret = Totp.newSecret(); s.setAttribute("setupSecret", secret); }
        showSetup(req, resp, secret, null);
    }

    private void setupPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!setupAllowed(req)) { resp.sendError(404); return; }
        HttpSession s = req.getSession();
        String secret = (String) s.getAttribute("setupSecret");
        if (secret == null || !formTokenOk(req, s)) { resp.sendRedirect(req.getContextPath() + "/mgadmin/setup?token=" + req.getParameter("token")); return; }
        String username = req.getParameter("username"), password = req.getParameter("password"), password2 = req.getParameter("password2");
        String err = service.validateNew(username, password);
        if (err == null && !password.equals(password2)) err = "Parollar bir xil emas";
        if (err == null && Totp.verify(secret, req.getParameter("code"), null) < 0) err = "Google Authenticator kodi noto'g'ri. Ilovadagi joriy kodni kiriting.";
        if (err != null) { showSetup(req, resp, secret, err); return; }
        AdminUser a = service.create(username, password, secret, true);
        s.removeAttribute("setupSecret");
        service.log(req, a, null, "SECURITY", "SETUP", a.getUsername(), "Birinchi (bosh) admin yaratildi", true);
        req.setAttribute("stage", "password");
        req.setAttribute("info", "Bosh admin yaratildi. Endi login, parol va Google Authenticator kodi bilan kiring.");
        req.setAttribute("formToken", newFormToken(s));
        req.setAttribute("noAdmins", false);
        req.getRequestDispatcher("/WEB-INF/admin/login.jsp").forward(req, resp);
    }

    private void showSetup(HttpServletRequest req, HttpServletResponse resp, String secret, String err) throws ServletException, IOException {
        String uri = Totp.otpauthUri("MilliyGram Admin", "admin", secret);
        req.setAttribute("qrSvg", QrUtils.svg(uri, 200));
        req.setAttribute("secret", secret.replaceAll("(.{4})", "$1 ").trim());
        req.setAttribute("token", req.getParameter("token"));
        req.setAttribute("error", err);
        req.setAttribute("formToken", newFormToken(req.getSession()));
        req.getRequestDispatcher("/WEB-INF/admin/setup.jsp").forward(req, resp);
    }

    /* ---------------- yordamchilar ---------------- */
    private static boolean pendingExpired(HttpSession s) {
        Long at = (Long) s.getAttribute("adminPendingAt");
        return at == null || System.currentTimeMillis() - at > PENDING_MS;
    }

    static String token(int bytes) {
        byte[] b = new byte[bytes];
        RND.nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }

    /** Login formasi uchun bir martalik token (boshqa saytdan forma yuborishning oldini oladi) */
    public static String newFormToken(HttpSession s) {
        String t = token(24);
        s.setAttribute("adminFormToken", t);
        return t;
    }

    private static boolean formTokenOk(HttpServletRequest req, HttpSession s) {
        String expected = (String) s.getAttribute("adminFormToken");
        String given = req.getParameter("ft");
        return expected != null && given != null && MessageDigest.isEqual(expected.getBytes(), given.getBytes());
    }
}
