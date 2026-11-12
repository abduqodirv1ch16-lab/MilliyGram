package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.service.ChatService;

import java.io.IOException;
@WebServlet(name = "ChatActionServlet",urlPatterns = "/chat/action")
public class ChatActionServlet extends HttpServlet {
   private final ChatService chatService = new ChatService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("id");
        String action = req.getParameter("action");
        Integer messageId = Integer.parseInt(req.getParameter("messageId"));

        if ("delete".equals(action)){
            chatService.deleteMessage(messageId,currentUserId);
            resp.setStatus(HttpServletResponse.SC_OK);
        }else if("edit".equals(action)){
            String newContent = req.getParameter("content");
            boolean updated = chatService.editMessage(messageId,currentUserId,newContent);
            resp.setStatus(updated ? HttpServletResponse.SC_OK : HttpServletResponse.SC_FORBIDDEN);
        }else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
