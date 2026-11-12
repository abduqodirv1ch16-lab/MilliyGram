package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import uz.pdp.mini_blok_with_jakarta.dto.PostCreateDTO;
import uz.pdp.mini_blok_with_jakarta.service.PostService;
import uz.pdp.mini_blok_with_jakarta.utils.FileUtils;

import java.io.IOException;

@WebServlet(name = "Post Create Servlet", urlPatterns = "/post/create")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 60
)
public class PostCreateServlet extends HttpServlet {
   private final PostService postService = new PostService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/user/post_create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String title = req.getParameter("title");
        String content = req.getParameter("content");
        Integer userId = (Integer) req.getSession().getAttribute("id");

        if (title == null || title.isBlank() || content==null || content.isBlank()
                || title.length() > 200 || content.length() > 5000){
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Sarlavha va matn majburiy");
            return;
        }
        Part mediaPart = req.getPart("media");
        String mediaFIleName;
        try {
            mediaFIleName = FileUtils.uploadFile(mediaPart);
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }
        String mediaType =null;
        if(mediaFIleName !=null){
            String submittedType = mediaPart.getContentType();
            if(submittedType !=null && submittedType.startsWith("video")){
                mediaType="VIDEO";
            } else if (submittedType !=null && submittedType.startsWith("image")) {
                mediaType="IMAGE";
            }
        }
        PostCreateDTO createDTO = new PostCreateDTO(title,content,mediaFIleName, mediaType,userId);
        postService.createPost(createDTO);
        resp.sendRedirect("/");
    }
}
