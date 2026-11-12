package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.SavedPostDao;
import uz.pdp.mini_blok_with_jakarta.service.InteractionService;

import java.io.IOException;

@WebServlet(name = "PostSaveServlet",urlPatterns = "/post/save")
public class PostSaveServlet extends HttpServlet {
 private final InteractionService interactionService = new InteractionService();
 private final SavedPostDao savedPostDao = new SavedPostDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("id");
        Integer postId = Integer.parseInt(req.getParameter("postId"));

        boolean isSaved = interactionService.toggleSavePost(userId,postId);
        long totalSaved = savedPostDao.countSaved(postId);

        resp.setContentType("application/json");
        resp.getWriter().write(String.format("{\"saved\": %b, \"count\": %d}",isSaved,totalSaved));

    }
}
