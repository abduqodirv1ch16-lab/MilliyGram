package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.CommentLikeDao;
import uz.pdp.mini_blok_with_jakarta.service.CommentService;

import java.io.IOException;

@WebServlet(name = "CommentLikeServlet", urlPatterns = "/comment/like")
public class CommentLikeServlet extends HttpServlet {
    private final CommentService commentService = new CommentService();
    private final CommentLikeDao commentLikeDao = new CommentLikeDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("id");
        Integer commentId = Integer.parseInt(req.getParameter("commentId"));
        boolean liked = commentService.togleCommentLike(userId,commentId);
        long count = commentLikeDao.countLikes(commentId);

        resp.setContentType("application/json");
        resp.getWriter().write(String.format("{\"liked\": %b, \"count\": %d}",liked,count));
    }
}
