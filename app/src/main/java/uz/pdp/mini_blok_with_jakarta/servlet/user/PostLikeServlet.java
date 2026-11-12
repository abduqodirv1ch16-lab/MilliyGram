package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.PostLikeDao;
import uz.pdp.mini_blok_with_jakarta.service.InteractionService;

import java.io.IOException;

@WebServlet(name = "PostLikeServlet", urlPatterns = "/post/like")
public class PostLikeServlet extends HttpServlet {
    private final InteractionService interactionService = new InteractionService();
    private final PostLikeDao postLikeDao = new PostLikeDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("id");
        String postIdStr = req.getParameter("postId");
        if (postIdStr == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Integer postId = Integer.parseInt(postIdStr);
        boolean isLIked = interactionService.togglePostLike(userId, postId);
        long totalLikes = postLikeDao.countLikes(postId);

        resp.setContentType("application/json");
        resp.getWriter().write(String.format("{\"liked\": %b, \"count\": %d}", isLIked, totalLikes));
    }
}
