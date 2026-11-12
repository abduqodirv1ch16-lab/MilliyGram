package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.FollowDao;
import uz.pdp.mini_blok_with_jakarta.dao.PostDao;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "SavedPostsServlet", urlPatterns = "/saved/posts")
public class SavedPostsServlet extends HttpServlet {
    private final PostService postService = new PostService();
    private final PostDao postDao = new PostDao();
    private final FollowDao followDao = new FollowDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("id") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        Integer currentUserId = (Integer) session.getAttribute("id");

        // Faqat saqlangan postlar — to'g'ridan-to'g'ri bazadan (avval butun lenta yuklanib, keyin ajratilardi)
        List<PostDetailResponseDTO> savedPosts = postService.getSavedPosts(currentUserId);
        uz.pdp.mini_blok_with_jakarta.servlet.SidebarStats.put(req, new uz.pdp.mini_blok_with_jakarta.dao.SocialDao(), currentUserId);

        req.setAttribute("savedPosts", savedPosts);
        req.getRequestDispatcher("/user/saved_post.jsp").forward(req, resp);
    }
}