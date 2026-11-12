package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.dto.PostUpdateDTO;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;
@WebServlet(name = "PostEditServlet",urlPatterns = "/post/edit")
public class PostEditServlet extends HttpServlet {
    private final PostService postService = new PostService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String postIdStr = req.getParameter("id");
        Integer currentUserId = (Integer) req.getSession().getAttribute("id");

        if(postIdStr == null){
            resp.sendRedirect("/");
            return;
        }
        PostDetailResponseDTO post = postService.getPostById(Integer.parseInt(postIdStr),currentUserId);
        if(post==null || !post.authorId().equals(currentUserId)){
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,"Siz faqat o'zingizning postingizni tahrirlay olasiz");
           return;
        }
        req.setAttribute("post",post);
        req.getRequestDispatcher("/user/post_edit.jsp").forward(req,resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("id");
        Integer id = Integer.parseInt(req.getParameter("id"));
        String title = req.getParameter("title");
        String content = req.getParameter("content");

        boolean update = postService.updatePost(new PostUpdateDTO(id,title,content,currentUserId));
        if(update){
            resp.sendRedirect("/");
        }else {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
    }
}
