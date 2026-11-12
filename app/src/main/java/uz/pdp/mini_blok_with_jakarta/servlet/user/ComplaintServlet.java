package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.service.InteractionService;

import java.io.IOException;
@WebServlet(name = "ComplaintServlet", urlPatterns = "/post/report")
public class ComplaintServlet extends HttpServlet {
    private final InteractionService interactionService = new InteractionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("id");
        String postIdStr = req.getParameter("postId");
        String reason = req.getParameter("reason");

        if(postIdStr == null || reason == null || reason.isBlank() || reason.length() > 1000){
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,"Ma'lumotlar toliq emas");
            return;
        }
        interactionService.reportPost(userId,Integer.parseInt(postIdStr),reason);
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
