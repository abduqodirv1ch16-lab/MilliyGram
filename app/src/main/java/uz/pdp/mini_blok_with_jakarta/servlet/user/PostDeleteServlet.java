package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;

@WebServlet(name = "PostDeleteServlet",urlPatterns = "/post/delete")
public class PostDeleteServlet extends HttpServlet {
    private final PostService postService = new PostService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("id");
        Integer postId = Integer.parseInt(req.getParameter("id"));

        boolean deleted  = postService.deletePost(postId,currentUserId);
        if(deleted){
            resp.sendRedirect("/");
        }else {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,"O'chirishga ruxsat yo'q");
        }
    }
}
