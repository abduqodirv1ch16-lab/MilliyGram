package uz.pdp.mini_blok_with_jakarta.servlet.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.AdminDao;
import uz.pdp.mini_blok_with_jakarta.entity.AdminLog;
import uz.pdp.mini_blok_with_jakarta.entity.AdminUser;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.enums.Status;
import uz.pdp.mini_blok_with_jakarta.security.UserFlags;
import uz.pdp.mini_blok_with_jakarta.service.AdminService;
import uz.pdp.mini_blok_with_jakarta.utils.*;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.nio.file.Files;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Stream;

/** Admin panel API: /mgadmin/api/* (faqat kirgan admin, POST lar CSRF token bilan — AdminFilter tekshiradi) */
@WebServlet(name = "AdminApiServlet", urlPatterns = "/mgadmin/api/*")
public class AdminApiServlet extends HttpServlet {
    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final int PAGE = 20;
    private final AdminDao dao = new AdminDao();
    private final AdminService service = new AdminService();

    /* ---------------- yordamchilar ---------------- */
    private static void out(HttpServletResponse r, int status, Object body) throws IOException {
        r.setStatus(status);
        r.setContentType("application/json;charset=UTF-8");
        r.getWriter().write(Json.of(body));
    }
    private static void err(HttpServletResponse r, int status, String msg) throws IOException { out(r, status, Map.of("error", msg)); }
    private static Map<String, Object> m(Object... kv) {
        Map<String, Object> m = new LinkedHashMap<>();
        for (int i = 0; i < kv.length; i += 2) m.put((String) kv[i], kv[i + 1]);
        return m;
    }
    private static int intParam(HttpServletRequest r, String n, int def) {
        try { return Integer.parseInt(r.getParameter(n)); } catch (Exception e) { return def; }
    }
    private static Integer idParam(HttpServletRequest r) {
        try { return Integer.valueOf(r.getParameter("id")); } catch (Exception e) { return null; }
    }
    private static String qParam(HttpServletRequest r) {
        String q = r.getParameter("q");
        if (q == null) return "";
        q = q.trim().replace("%", "").replace("\\", "");
        return q.length() > 60 ? q.substring(0, 60) : q;
    }
    private static String fmt(LocalDateTime t) { return t == null ? null : t.format(DT); }
    private static AdminUser me(HttpServletRequest req, AdminDao dao) {
        HttpSession s = req.getSession(false);
        Integer id = s == null ? null : (Integer) s.getAttribute("adminId");
        return id == null ? null : dao.findAdmin(id).orElse(null);
    }
    private static void deleteFiles(Collection<String> names) {
        for (String n : names) {
            File f = FileUtils.resolveSafe(n);
            if (f != null && f.isFile()) { try { Files.deleteIfExists(f.toPath()); } catch (Exception ignored) { } }
        }
    }

    /* ================================ GET ================================ */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String p = req.getPathInfo() == null ? "" : req.getPathInfo();
        int page = Math.max(0, intParam(req, "page", 0));
        try {
            switch (p) {
                case "/stats" -> out(resp, 200, stats());
                case "/users" -> {
                    String f = Optional.ofNullable(req.getParameter("filter")).filter(x -> x.matches("all|active|blocked|verified")).orElse("all");
                    String q = qParam(req);
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (Object[] r : dao.users(q, f, page, PAGE))
                        list.add(m("id", r[0], "username", r[1], "fullName", r[2], "avatar", r[3], "status", r[4], "verified", r[5],
                                "createdAt", r[6], "posts", r[7], "followers", r[8], "following", r[9]));
                    out(resp, 200, m("items", list, "total", dao.countUsers(q, f), "page", page, "size", PAGE));
                }
                case "/posts" -> {
                    String q = qParam(req);
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (Object[] r : dao.posts(q, page, PAGE))
                        list.add(m("id", r[0], "title", r[1], "content", r[2], "mediaUrl", r[3], "mediaType", r[4], "createdAt", r[5],
                                "userId", r[6], "username", r[7], "likes", r[8], "comments", r[9], "complaints", r[10], "views", r[11]));
                    out(resp, 200, m("items", list, "total", dao.countPosts(q), "page", page, "size", PAGE));
                }
                case "/comments" -> {
                    String q = qParam(req);
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (Object[] r : dao.comments(q, page, PAGE))
                        list.add(m("id", r[0], "content", r[1], "createdAt", r[2], "userId", r[3], "username", r[4], "postId", r[5], "likes", r[6]));
                    out(resp, 200, m("items", list, "total", dao.countComments(q), "page", page, "size", PAGE));
                }
                case "/complaints" -> {
                    boolean open = !"closed".equals(req.getParameter("status"));
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (Object[] r : dao.complaintGroups(open, 100))
                        list.add(m("postId", r[0], "count", r[1], "lastAt", r[2], "reasons", r[3], "title", r[4], "content", r[5],
                                "mediaUrl", r[6], "mediaType", r[7], "authorId", r[8], "author", r[9], "postExists", r[10], "status", r[11]));
                    out(resp, 200, m("items", list));
                }
                case "/logs" -> {
                    String type = req.getParameter("type");
                    if (type != null && !type.matches("LOGIN|ACTION|SECURITY")) type = null;
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (AdminLog l : dao.logs(type, page, 30))
                        list.add(m("id", l.getId(), "admin", l.getAdminUsername(), "type", l.getType(), "action", l.getAction(),
                                "target", l.getTarget(), "details", l.getDetails(), "ip", l.getIp(), "ua", l.getUserAgent(),
                                "success", l.getSuccess(), "at", fmt(l.getCreatedAt())));
                    out(resp, 200, m("items", list, "total", dao.countLogs(type), "page", page, "size", 30));
                }
                case "/system" -> out(resp, 200, system(req));
                case "/admins" -> {
                    AdminUser me = me(req, dao);
                    if (me == null || !Boolean.TRUE.equals(me.getSuperAdmin())) { err(resp, 403, "Faqat bosh admin uchun"); return; }
                    List<Map<String, Object>> list = new ArrayList<>();
                    for (AdminUser a : dao.listAdmins())
                        list.add(m("id", a.getId(), "username", a.getUsername(), "enabled", a.getEnabled(), "superAdmin", a.getSuperAdmin(),
                                "lastLoginAt", fmt(a.getLastLoginAt()), "lastLoginIp", a.getLastLoginIp(), "createdAt", fmt(a.getCreatedAt()),
                                "locked", a.getLockedUntil() != null && a.getLockedUntil().isAfter(LocalDateTime.now()), "me", a.getId().equals(me.getId())));
                    out(resp, 200, m("items", list));
                }
                default -> err(resp, 404, "Topilmadi");
            }
        } catch (IllegalArgumentException e) {
            err(resp, 400, "Noto'g'ri so'rov");
        }
    }

    private Map<String, Object> stats() {
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("totals", dao.totals());
        Map<String, Object> series = new LinkedHashMap<>();
        for (String t : new String[]{"users", "posts", "comments", "likes", "messages"}) {
            List<Object[]> s = new ArrayList<>();
            for (Object[] row : dao.dailySeries(t, 30)) s.add(new Object[]{row[0], row[1]});
            series.put(t, s);
        }
        r.put("series", series);
        List<Map<String, Object>> top = new ArrayList<>();
        for (Object[] u : dao.topUsers(6))
            top.add(m("id", u[0], "username", u[1], "fullName", u[2], "avatar", u[3], "verified", u[4], "followers", u[5], "posts", u[6]));
        r.put("topUsers", top);
        List<Map<String, Object>> recent = new ArrayList<>();
        for (Object[] u : dao.users("", "all", 0, 6))
            recent.add(m("id", u[0], "username", u[1], "fullName", u[2], "avatar", u[3], "status", u[4], "verified", u[5], "createdAt", u[6]));
        r.put("recentUsers", recent);
        r.put("failedLogins24h", dao.countFailedLoginsSince(LocalDateTime.now().minusHours(24)));
        return r;
    }

    private Map<String, Object> system(HttpServletRequest req) {
        Runtime rt = Runtime.getRuntime();
        long up = ManagementFactory.getRuntimeMXBean().getUptime();
        File uploads = new File(FileUtils.UPLOAD_DIR);
        long files = 0, bytes = 0;
        try (Stream<java.nio.file.Path> s = Files.list(uploads.toPath())) {
            for (java.nio.file.Path f : (Iterable<java.nio.file.Path>) s::iterator) { files++; bytes += f.toFile().length(); }
        } catch (Exception ignored) { }
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("javaVersion", System.getProperty("java.version"));
        r.put("server", getServletContext().getServerInfo());
        r.put("os", System.getProperty("os.name") + " " + System.getProperty("os.version"));
        r.put("cpus", rt.availableProcessors());
        r.put("load", ManagementFactory.getOperatingSystemMXBean().getSystemLoadAverage());
        r.put("memUsed", rt.totalMemory() - rt.freeMemory());
        r.put("memMax", rt.maxMemory());
        r.put("uptimeMs", up);
        r.put("diskFree", uploads.getUsableSpace());
        r.put("diskTotal", uploads.getTotalSpace());
        r.put("uploadFiles", files);
        r.put("uploadBytes", bytes);
        r.putAll(dao.dbInfo());
        r.put("failedLogins24h", dao.countFailedLoginsSince(LocalDateTime.now().minusHours(24)));
        r.put("ip", uz.pdp.mini_blok_with_jakarta.security.ClientIp.of(req));
        return r;
    }

    /* ================================ POST ================================ */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String p = req.getPathInfo() == null ? "" : req.getPathInfo();
        AdminUser me = me(req, dao);
        if (me == null || !Boolean.TRUE.equals(me.getEnabled())) { err(resp, 401, "Qayta kiring"); return; }
        Integer id = idParam(req);

        switch (p) {
            case "/user/block", "/user/unblock" -> {
                AuthUser u = id == null ? null : dao.findUser(id).orElse(null);
                if (u == null) { err(resp, 404, "Foydalanuvchi topilmadi"); return; }
                boolean block = p.endsWith("/block");
                dao.setUserStatus(id, block ? Status.BLOK : Status.ACTIVE);
                UserFlags.setBlocked(id, block);
                service.log(req, me, null, "ACTION", block ? "USER_BLOCK" : "USER_UNBLOCK", "@" + u.getUsername() + " (#" + id + ")",
                        cut(req.getParameter("reason")), true);
                out(resp, 200, m("ok", true));
            }
            case "/user/verify", "/user/unverify" -> {
                AuthUser u = id == null ? null : dao.findUser(id).orElse(null);
                if (u == null) { err(resp, 404, "Foydalanuvchi topilmadi"); return; }
                boolean v = p.endsWith("/verify");
                dao.setVerified(id, v);
                UserFlags.setVerified(id, v);
                service.log(req, me, null, "ACTION", v ? "USER_VERIFY" : "USER_UNVERIFY", "@" + u.getUsername() + " (#" + id + ")", null, true);
                out(resp, 200, m("ok", true));
            }
            case "/user/delete" -> {
                AuthUser u = id == null ? null : dao.findUser(id).orElse(null);
                if (u == null) { err(resp, 404, "Foydalanuvchi topilmadi"); return; }
                if (!u.getUsername().equalsIgnoreCase(String.valueOf(req.getParameter("confirm")))) { err(resp, 400, "Tasdiqlash uchun username ni to'g'ri yozing"); return; }
                List<String> files = dao.deleteUser(id);
                UserFlags.setBlocked(id, true);   // eski sessiyalari ham darhol yopiladi
                deleteFiles(files);
                service.log(req, me, null, "ACTION", "USER_DELETE", "@" + u.getUsername() + " (#" + id + ")",
                        files.size() + " ta fayl o'chirildi. " + Objects.toString(cut(req.getParameter("reason")), ""), true);
                out(resp, 200, m("ok", true));
            }
            case "/post/delete" -> {
                if (id == null) { err(resp, 400, "id kerak"); return; }
                String media = dao.deletePost(id);
                if (media != null) deleteFiles(List.of(media));
                service.log(req, me, null, "ACTION", "POST_DELETE", "Post #" + id, cut(req.getParameter("reason")), true);
                out(resp, 200, m("ok", true));
            }
            case "/comment/delete" -> {
                if (id == null) { err(resp, 400, "id kerak"); return; }
                dao.deleteComment(id);
                service.log(req, me, null, "ACTION", "COMMENT_DELETE", "Izoh #" + id, cut(req.getParameter("reason")), true);
                out(resp, 200, m("ok", true));
            }
            case "/complaint/dismiss" -> {
                if (id == null) { err(resp, 400, "id kerak"); return; }
                int n = dao.setComplaintStatus(id, "DISMISSED", me.getId());
                service.log(req, me, null, "ACTION", "COMPLAINT_DISMISS", "Post #" + id, n + " ta shikoyat rad etildi", true);
                out(resp, 200, m("ok", true));
            }
            case "/complaint/resolve" -> {   // postni o'chirib, shikoyatlarni yopadi
                if (id == null) { err(resp, 400, "id kerak"); return; }
                dao.setComplaintStatus(id, "RESOLVED", me.getId());
                String media = dao.deletePost(id);
                if (media != null) deleteFiles(List.of(media));
                service.log(req, me, null, "ACTION", "COMPLAINT_RESOLVE", "Post #" + id, "Shikoyat asosida post o'chirildi", true);
                out(resp, 200, m("ok", true));
            }
            case "/me/password" -> {
                String cur = req.getParameter("current"), nw = req.getParameter("new");
                if (!PasswordUtils.matches(cur == null ? "" : cur, me.getPassword())) {
                    service.log(req, me, null, "SECURITY", "PASSWORD_CHANGE", null, "Joriy parol noto'g'ri", false);
                    err(resp, 400, "Joriy parol noto'g'ri"); return;
                }
                String e = AdminService.validatePassword(nw);
                if (e != null) { err(resp, 400, e); return; }
                long step = Totp.verify(me.getTotpSecret(), req.getParameter("code"), me.getTotpLastStep());
                if (step < 0) { err(resp, 400, "2FA kodi noto'g'ri"); return; }
                me.setTotpLastStep(step);
                me.setPassword(PasswordUtils.hash(nw));
                dao.updateAdmin(me);
                service.log(req, me, null, "SECURITY", "PASSWORD_CHANGE", null, "Admin paroli o'zgartirildi", true);
                out(resp, 200, m("ok", true));
            }
            case "/admins/create" -> {
                if (!Boolean.TRUE.equals(me.getSuperAdmin())) { err(resp, 403, "Faqat bosh admin uchun"); return; }
                String u = req.getParameter("username"), pw = req.getParameter("password");
                String e = service.validateNew(u, pw);
                if (e == null && dao.findAdmin(u.trim()).isPresent()) e = "Bu login band";
                if (e != null) { err(resp, 400, e); return; }
                String secret = Totp.newSecret();
                AdminUser a = service.create(u, pw, secret, false);
                service.log(req, me, null, "SECURITY", "ADMIN_CREATE", a.getUsername(), "Yangi admin yaratildi", true);
                String uri = Totp.otpauthUri("MilliyGram Admin", a.getUsername(), secret);
                out(resp, 200, m("ok", true, "qrSvg", QrUtils.svg(uri, 200), "secret", secret.replaceAll("(.{4})", "$1 ").trim()));
            }
            case "/admins/toggle" -> {
                if (!Boolean.TRUE.equals(me.getSuperAdmin())) { err(resp, 403, "Faqat bosh admin uchun"); return; }
                AdminUser a = id == null ? null : dao.findAdmin(id).orElse(null);
                if (a == null) { err(resp, 404, "Topilmadi"); return; }
                if (a.getId().equals(me.getId())) { err(resp, 400, "O'zingizni o'chira olmaysiz"); return; }
                a.setEnabled(!Boolean.TRUE.equals(a.getEnabled()));
                a.setLockedUntil(null);
                a.setFailedAttempts(0);
                dao.updateAdmin(a);
                service.log(req, me, null, "SECURITY", a.getEnabled() ? "ADMIN_ENABLE" : "ADMIN_DISABLE", a.getUsername(), null, true);
                out(resp, 200, m("ok", true, "enabled", a.getEnabled()));
            }
            default -> err(resp, 404, "Topilmadi");
        }
    }

    private static String cut(String s) { return s == null ? null : (s.length() > 500 ? s.substring(0, 500) : s); }
}
