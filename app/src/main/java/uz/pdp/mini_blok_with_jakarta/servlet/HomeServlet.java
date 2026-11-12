package uz.pdp.mini_blok_with_jakarta.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.SocialDao;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = "/" )
public class HomeServlet extends HttpServlet {
    public static final int PAGE_SIZE = 20;
    private final PostService postService = new PostService();
    private final SocialDao socialDao = new SocialDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // "/" barcha noma'lum manzillarni ham ushlaydi — ular uchun 404
        String path = req.getServletPath() + (req.getPathInfo() == null ? "" : req.getPathInfo());
        if (!path.equals("/") && !path.isEmpty()) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Integer me = (Integer) session.getAttribute("id");
        Integer before = null;
        try { if (req.getParameter("before") != null) before = Integer.valueOf(req.getParameter("before")); } catch (NumberFormatException ignored) { }

        List<PostDetailResponseDTO> posts = postService.getFeed(me, before, PAGE_SIZE + 1);
        boolean hasMore = posts.size() > PAGE_SIZE;
        if (hasMore) posts = posts.subList(0, PAGE_SIZE);
        req.setAttribute("posts", posts);
        req.setAttribute("hasMore", hasMore);
        req.setAttribute("nextBefore", posts.isEmpty() ? null : posts.get(posts.size() - 1).id());
        SidebarStats.put(req, socialDao, me);
        req.getRequestDispatcher("/home.jsp").forward(req, resp);
    }
}
