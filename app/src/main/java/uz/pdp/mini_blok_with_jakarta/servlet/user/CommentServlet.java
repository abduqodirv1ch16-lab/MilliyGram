package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.SocialDao;
import uz.pdp.mini_blok_with_jakarta.dto.CommentCreateDTO;
import uz.pdp.mini_blok_with_jakarta.dto.CommentResponseDTO;
import uz.pdp.mini_blok_with_jakarta.service.CommentService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CommentServlet", urlPatterns = "/comment")
public class CommentServlet extends HttpServlet {
    private final CommentService commentService = new CommentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = sessionUserId(req);
        Integer postId = parseInt(req.getParameter("postId"));
        Integer parentId = parseInt(req.getParameter("parrentId"));
        if (parentId == null) parentId = parseInt(req.getParameter("parentId"));

        List<CommentResponseDTO> list;
        if (postId != null) {
            list = commentService.getMainComments(postId, currentUserId);
        } else if (parentId != null) {
            list = commentService.getReplies(parentId, currentUserId);
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // izoh vaqtlarini bitta so'rov bilan olamiz
        Map<Integer, Object> times = new HashMap<>();
        List<Integer> cids = new ArrayList<>();
        for (CommentResponseDTO c : list) cids.add(c.id());
        for (Object[] r : new SocialDao().commentTimes(cids)) {
            times.put((Integer) r[0], r[1]);
        }

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            CommentResponseDTO c = list.get(i);
            Object created = times.get(c.id());
            json.append("{")
                    .append("\"id\":").append(c.id()).append(",")
                    .append("\"username\":").append(jsonStr(c.username())).append(",")
                    .append("\"verified\":").append(uz.pdp.mini_blok_with_jakarta.security.UserFlags.isVerified(c.userId())).append(",")
                    .append("\"avatar\":").append(jsonStr(c.userAvatar())).append(",")
                    .append("\"content\":").append(jsonStr(c.content())).append(",")
                    .append("\"likeCount\":").append(c.likeCount()).append(",")
                    .append("\"replyCount\":").append(c.replyCount()).append(",")
                    .append("\"createdAt\":").append(created == null ? "null" : "\"" + created + "\"").append(",")
                    .append("\"liked\":").append(c.isLikedByMe())
                    .append("}");
            if (i < list.size() - 1) json.append(",");
        }
        json.append("]");

        resp.setHeader("Cache-Control", "no-store");
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(json.toString());
    }

    // ---------- yordamchi metodlar (shu klass ichiga, doGet dan pastga qo'ying) ----------
    private static Integer sessionUserId(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        Object v = s == null ? null : s.getAttribute("id");
        return v instanceof Integer ? (Integer) v : null;
    }

    private static Integer parseInt(String s) {
        try { return s == null ? null : Integer.valueOf(s.trim()); } catch (Exception e) { return null; }
    }

    private static String jsonStr(String s) {
        if (s == null) return "null";
        StringBuilder b = new StringBuilder("\"");
        for (char ch : s.toCharArray()) {
            switch (ch) {
                case '"':  b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default:
                    if (ch < 0x20) b.append(String.format("\\u%04x", (int) ch));
                    else b.append(ch);
            }
        }
        return b.append('"').toString();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer userId = (Integer) req.getSession().getAttribute("id");
        Integer postId = Integer.parseInt(req.getParameter("postId"));
        String content = req.getParameter("content");
        if (content == null || content.isBlank() || content.length() > 2000) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Izoh 1-2000 belgi bo'lishi kerak");
            return;
        }
        String parentIdStr = req.getParameter("parentId");
        Integer parentId = (parentIdStr !=null && !parentIdStr.isBlank()) ? Integer.parseInt(parentIdStr) : null;

        commentService.addComment(new CommentCreateDTO(postId,userId,content,parentId));
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
