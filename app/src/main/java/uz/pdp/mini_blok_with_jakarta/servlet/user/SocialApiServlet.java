package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dao.SocialDao;
import uz.pdp.mini_blok_with_jakarta.dto.LoginDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.entity.Story;
import uz.pdp.mini_blok_with_jakarta.service.AuthService;
import uz.pdp.mini_blok_with_jakarta.utils.FileUtils;

import java.io.IOException;
import java.util.*;
import java.util.regex.Pattern;

@WebServlet(name = "SocialApiServlet", urlPatterns = "/api/*")
@MultipartConfig(maxFileSize = 50L * 1024 * 1024, maxRequestSize = 55L * 1024 * 1024)
public class SocialApiServlet extends HttpServlet {
    private final SocialDao dao = new SocialDao();
    private final AuthUserDao users = new AuthUserDao();
    private final AuthService authService = new AuthService();
    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_.]{3,30}$");

    /* ----- kichik yordamchilar ----- */
    private static String q(String s) {
        if (s == null) return "null";
        StringBuilder b = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default: if (c < 0x20) b.append(String.format("\\u%04x", (int) c)); else b.append(c);
            }
        }
        return b.append('"').toString();
    }
    private static void out(HttpServletResponse r, int status, String json) throws IOException {
        r.setStatus(status);
        r.setContentType("application/json;charset=UTF-8");
        r.setHeader("Cache-Control", "no-store");
        r.getWriter().write(json);
    }
    private static void err(HttpServletResponse r, int status, String msg) throws IOException {
        out(r, status, "{\"error\":" + q(msg) + "}");
    }
    private static Integer me(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        Object v = s == null ? null : s.getAttribute("id");
        return v instanceof Integer ? (Integer) v : null;
    }
    private static Integer toInt(String s) {
        try { return s == null ? null : Integer.valueOf(s.trim()); } catch (Exception e) { return null; }
    }
    private static String t(Object o) { return o == null ? "null" : q(o.toString()); }
    private String fileOf(Part p) throws IOException {
        if (p == null || p.getSize() == 0) return null;
        return FileUtils.uploadFile(p);
    }
    private static String typeOf(Part p) {
        String ct = p.getContentType();
        return ct != null && ct.startsWith("video/") ? "VIDEO" : "IMAGE";
    }

    /* ================= GET ================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer me = me(req);
        if (me == null) { err(resp, 401, "Tizimga kiring"); return; }
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        switch (path) {
            case "/user": {                       // chap panel statistikasi
                AuthUser u = users.findById(me).orElse(null);
                if (u == null) { err(resp, 404, "Topilmadi"); return; }
                out(resp, 200, "{\"id\":" + u.getId() + ",\"username\":" + q(u.getUsername()) + ",\"fullName\":" + q(u.getFullName())
                        + ",\"avatar\":" + q(u.getAvatarUrl()) + ",\"posts\":" + dao.countPosts(me)
                        + ",\"followers\":" + dao.countFollowers(me) + ",\"following\":" + dao.countFollowing(me) + "}");
                return;
            }
            case "/me": {                         // Edit profile oynasi uchun
                AuthUser u = users.findById(me).orElse(null);
                if (u == null) { err(resp, 404, "Topilmadi"); return; }
                out(resp, 200, "{\"fullName\":" + q(u.getFullName()) + ",\"username\":" + q(u.getUsername()) + ",\"bio\":" + q(u.getBio())
                        + ",\"location\":" + q(u.getLocation()) + ",\"avatarUrl\":" + q(u.getAvatarUrl()) + ",\"coverUrl\":" + q(u.getCoverUrl()) + "}");
                return;
            }
            case "/follows": {                    // Followers / Following ro'yxati
                String type = req.getParameter("type");
                Integer uid = toInt(req.getParameter("userId"));
                if (uid == null) uid = me;
                List<AuthUser> list = "followers".equals(type) ? dao.followersOf(uid) : dao.followingOf(uid);
                Set<Integer> mine = dao.followingIds(me);
                StringBuilder b = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    AuthUser u = list.get(i);
                    if (i > 0) b.append(',');
                    b.append("{\"id\":").append(u.getId()).append(",\"username\":").append(q(u.getUsername()))
                            .append(",\"fullName\":").append(q(u.getFullName())).append(",\"avatar\":").append(q(u.getAvatarUrl()))
                            .append(",\"verified\":").append(u.isVerifiedUser())
                            .append(",\"iFollow\":").append(mine.contains(u.getId())).append(",\"isMe\":").append(u.getId().equals(me)).append('}');
                }
                out(resp, 200, b.append(']').toString());
                return;
            }
            case "/notifications": { notifications(me, resp); return; }
            case "/postmeta": {                   // post vaqti + ko'rishlar soni
                List<Integer> ids = new ArrayList<>();
                String raw = req.getParameter("ids");
                if (raw != null) for (String s : raw.split(",")) { Integer i = toInt(s); if (i != null) ids.add(i); }
                StringBuilder b = new StringBuilder("{");
                boolean first = true;
                for (Object[] r : dao.postMeta(ids)) {
                    if (!first) b.append(','); first = false;
                    b.append('"').append(r[0]).append("\":{\"views\":").append(r[1] == null ? 0 : ((Number) r[1]).longValue())
                            .append(",\"createdAt\":").append(t(r[2])).append('}');
                }
                out(resp, 200, b.append('}').toString());
                return;
            }
            case "/stories": { stories(me, toInt(req.getParameter("userId")), resp); return; }
            default: err(resp, 404, "Topilmadi");
        }
    }

    private void notifications(Integer me, HttpServletResponse resp) throws IOException {
        class N { String type, text, media; Integer userId, postId; Object at; }
        List<N> all = new ArrayList<>();
        for (Object[] r : dao.likeNotifs(me)) { N n = new N(); n.type = "LIKE"; n.userId = (Integer) r[0]; n.postId = (Integer) r[1]; n.at = r[2]; n.media = (String) r[3]; n.text = "postingizga like bosdi"; all.add(n); }
        for (Object[] r : dao.commentNotifs(me)) { N n = new N(); n.type = "COMMENT"; n.userId = (Integer) r[0]; n.postId = (Integer) r[1]; n.at = r[3]; n.media = (String) r[4]; n.text = "izoh yozdi: " + cut((String) r[2]); all.add(n); }
        for (Object[] r : dao.replyNotifs(me)) { N n = new N(); n.type = "REPLY"; n.userId = (Integer) r[0]; n.postId = (Integer) r[1]; n.at = r[3]; n.media = (String) r[4]; n.text = "izohingizga javob yozdi: " + cut((String) r[2]); all.add(n); }
        for (Object[] r : dao.followNotifs(me)) { N n = new N(); n.type = "FOLLOW"; n.userId = (Integer) r[0]; n.at = r[1]; n.text = "sizni kuzata boshladi"; all.add(n); }
        all.sort((a, b) -> String.valueOf(b.at).compareTo(String.valueOf(a.at)));   // ISO vaqt matn sifatida to'g'ri saralanadi
        if (all.size() > 50) all = all.subList(0, 50);
        Map<Integer, AuthUser> cache = new HashMap<>();
        StringBuilder b = new StringBuilder("[");
        for (int i = 0; i < all.size(); i++) {
            N n = all.get(i);
            AuthUser u = cache.computeIfAbsent(n.userId, id -> users.findById(id).orElse(null));
            if (u == null) continue;
            if (b.length() > 1) b.append(',');
            b.append("{\"type\":").append(q(n.type)).append(",\"userId\":").append(n.userId).append(",\"username\":").append(q(u.getUsername()))
                    .append(",\"avatar\":").append(q(u.getAvatarUrl())).append(",\"text\":").append(q(n.text))
                    .append(",\"postId\":").append(n.postId).append(",\"mediaUrl\":").append(q(n.media)).append(",\"createdAt\":").append(t(n.at)).append('}');
        }
        out(resp, 200, b.append(']').toString());
    }
    private static String cut(String s) { return s == null ? "" : (s.length() > 60 ? s.substring(0, 60) + "…" : s); }

    private void stories(Integer me, Integer onlyUser, HttpServletResponse resp) throws IOException {
        Set<Integer> allowed = new HashSet<>(dao.followingIds(me));
        allowed.add(me);
        Collection<Integer> ids;
        if (onlyUser != null) ids = allowed.contains(onlyUser) ? List.of(onlyUser) : List.of();
        else ids = allowed;
        Map<Integer, List<Story>> byUser = new LinkedHashMap<>();
        for (Story s : dao.activeStories(ids)) byUser.computeIfAbsent(s.getUserId(), k -> new ArrayList<>()).add(s);
        StringBuilder b = new StringBuilder("[");
        boolean first = true;
        for (Map.Entry<Integer, List<Story>> e : byUser.entrySet()) {
            AuthUser u = users.findById(e.getKey()).orElse(null);
            if (u == null) continue;
            if (!first) b.append(','); first = false;
            b.append("{\"userId\":").append(u.getId()).append(",\"username\":").append(q(u.getUsername()))
                    .append(",\"avatar\":").append(q(u.getAvatarUrl())).append(",\"mine\":").append(u.getId().equals(me)).append(",\"stories\":[");
            List<Story> l = e.getValue();
            for (int i = 0; i < l.size(); i++) {
                Story s = l.get(i);
                if (i > 0) b.append(',');
                b.append("{\"id\":").append(s.getId()).append(",\"mediaUrl\":").append(q(s.getMediaUrl())).append(",\"mediaType\":").append(q(s.getMediaType()))
                        .append(",\"caption\":").append(q(s.getCaption())).append(",\"createdAt\":").append(t(s.getCreatedAt())).append('}');
            }
            b.append("]}");
        }
        out(resp, 200, b.append(']').toString());
    }

    /* ================= POST ================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer me = me(req);
        if (me == null) { err(resp, 401, "Tizimga kiring"); return; }
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        try {
            switch (path) {
                case "/follow/remove": {
                    Integer fid = toInt(req.getParameter("followerId"));
                    if (fid == null) { err(resp, 400, "followerId kerak"); return; }
                    dao.removeFollower(me, fid);
                    out(resp, 200, "{\"ok\":true}");
                    return;
                }
                case "/post/view": {
                    Integer pid = toInt(req.getParameter("postId"));
                    if (pid == null) { err(resp, 400, "postId kerak"); return; }
                    out(resp, 200, "{\"views\":" + dao.registerView(pid, me) + "}");
                    return;
                }
                case "/password": { changePassword(req, resp, me); return; }
                case "/profile/edit": { editProfile(req, resp, me); return; }
                case "/story/create": {
                    Part media = req.getPart("media");
                    String file = fileOf(media);
                    if (file == null) { err(resp, 400, "Rasm yoki video tanlang"); return; }
                    String cap = req.getParameter("caption");
                    if (cap != null && cap.length() > 300) cap = cap.substring(0, 300);
                    dao.saveStory(Story.builder().userId(me).mediaUrl(file).mediaType(typeOf(media)).caption(cap == null ? null : cap.trim()).build());
                    out(resp, 200, "{\"ok\":true}");
                    return;
                }
                case "/story/update": {
                    Story s = dao.findStory(toInt(req.getParameter("id"))).orElse(null);
                    if (s == null || !s.getUserId().equals(me)) { err(resp, 403, "Ruxsat yo'q"); return; }
                    String cap = req.getParameter("caption");
                    if (cap != null && cap.length() > 300) cap = cap.substring(0, 300);
                    dao.updateStoryCaption(s.getId(), cap == null ? "" : cap.trim());
                    out(resp, 200, "{\"ok\":true}");
                    return;
                }
                case "/story/delete": {
                    Story s = dao.findStory(toInt(req.getParameter("id"))).orElse(null);
                    if (s == null || !s.getUserId().equals(me)) { err(resp, 403, "Ruxsat yo'q"); return; }
                    dao.deleteStory(s.getId());
                    try {
                        java.io.File f = new java.io.File(FileUtils.UPLOAD_DIR, s.getMediaUrl());
                        if (f.exists()) f.delete();
                    } catch (Exception ignored) {}
                    out(resp, 200, "{\"ok\":true}");
                    return;
                }
                default: err(resp, 404, "Topilmadi");
            }
        } catch (IllegalArgumentException e) {
            err(resp, 400, e.getMessage());
        } catch (IllegalStateException e) {
            err(resp, 413, "Fayl juda katta (50 MB gacha)");
        }
    }

    private void changePassword(HttpServletRequest req, HttpServletResponse resp, Integer me) throws IOException {
        String oldP = req.getParameter("oldPassword"), newP = req.getParameter("newPassword");
        if (oldP == null || newP == null || newP.length() < 6 || newP.length() > 100) { err(resp, 400, "Yangi parol 6-100 belgi bo'lsin"); return; }
        AuthUser u = users.findById(me).orElse(null);
        if (u == null) { err(resp, 404, "Topilmadi"); return; }
        if (authService.loginDTO(new LoginDTO(u.getUsername(), oldP)) == null) { err(resp, 400, "Joriy parol noto'g'ri"); return; }

        authService.changePassword(u, newP);
        out(resp, 200, "{\"ok\":true}");
    }

    private void editProfile(HttpServletRequest req, HttpServletResponse resp, Integer me) throws IOException, ServletException {
        AuthUser u = users.findById(me).orElse(null);
        if (u == null) { err(resp, 404, "Topilmadi"); return; }
        String fullName = req.getParameter("fullName"), username = req.getParameter("username");
        String bio = req.getParameter("bio"), location = req.getParameter("location");
        if (fullName != null && !fullName.isBlank()) u.setFullName(fullName.trim().length() > 100 ? fullName.trim().substring(0, 100) : fullName.trim());
        if (username != null && !username.trim().equalsIgnoreCase(u.getUsername())) {
            username = username.trim();
            if (!USERNAME.matcher(username).matches()) { err(resp, 400, "Username 3-30 belgi: harf, raqam, _ yoki ."); return; }
            Optional<AuthUser> ex = users.findByUsername(username);
            if (ex.isPresent() && !ex.get().getId().equals(me)) { err(resp, 400, "Bu username band"); return; }
            u.setUsername(username);
        }
        if (bio != null) u.setBio(bio.trim().length() > 300 ? bio.trim().substring(0, 300) : bio.trim());
        if (location != null) u.setLocation(location.trim().length() > 100 ? location.trim().substring(0, 100) : location.trim());
        String av = fileOf(req.getPart("avatar"));
        if (av != null) u.setAvatarUrl(av);
        String cv = fileOf(req.getPart("cover"));
        if (cv != null) u.setCoverUrl(cv);
        users.update(u);

        HttpSession s = req.getSession();      // chap paneldagi ma'lumot ham yangilansin
        s.setAttribute("username", u.getUsername());
        s.setAttribute("fullName", u.getFullName());
        s.setAttribute("avatar", u.getAvatarUrl());
        out(resp, 200, "{\"ok\":true}");
    }
}