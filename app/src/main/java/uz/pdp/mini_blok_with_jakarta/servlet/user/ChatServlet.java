package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import uz.pdp.mini_blok_with_jakarta.enums.MessageType;
import uz.pdp.mini_blok_with_jakarta.service.ChatService;
import uz.pdp.mini_blok_with_jakarta.utils.FileUtils;
import static uz.pdp.mini_blok_with_jakarta.utils.JsonUtils.q;

import java.io.IOException;

@WebServlet(name = "ChatServlet",urlPatterns = "/chat/send")
@MultipartConfig(maxFileSize = 1024 * 1024 * 50)
public class ChatServlet extends HttpServlet {
    private final ChatService chatService = new ChatService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("id");
        String targetUserIdStr = req.getParameter("targetUserId");

        if(targetUserIdStr == null){
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        var history = chatService.getCHatHistory(currentUserId,Integer.parseInt(targetUserIdStr));

        resp.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for(int i=0; i< history.size(); i++){
            var msg = history.get(i);
            json.append("{\"id\": ").append(msg.id())
                .append(", \"senderId\": ").append(msg.senderId())
                .append(", \"sender\": ").append(q(msg.senderUsername()))
                .append(", \"content\": ").append(q(msg.content() != null ? msg.content() : ""))
                .append(", \"mediaUrl\": ").append(q(msg.mediaUrl() != null ? msg.mediaUrl() : ""))
                .append(", \"type\": ").append(q(String.valueOf(msg.messageType())))
                .append(", \"isDeleted\": ").append(msg.isDeleted())
                .append("}");
            if (i<history.size()-1) json.append(",");
        }
        json.append("]");
        resp.getWriter().write(json.toString());
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Integer senderId = (Integer) req.getSession().getAttribute("id");
        Integer receiverId =  Integer.parseInt(req.getParameter("receiverId"));
        String content = req.getParameter("content");
        if (content != null && content.length() > 5000) content = content.substring(0, 5000);
        String replyToIdStr = req.getParameter("replyToId");
        Integer replyToId = (replyToIdStr !=null && !replyToIdStr.isBlank()) ? Integer.parseInt(replyToIdStr) : null;

        Part mediaPart = null;
        try {
            mediaPart = req.getPart("media");
        }catch (Exception ignored){}

        String mediaUrl = null;
        MessageType type = MessageType.TEXT;

        if(mediaPart != null && mediaPart.getSize()>0){
            try {
                mediaUrl = FileUtils.uploadFile(mediaPart);
            } catch (IllegalArgumentException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
                return;
            }
            String mime = mediaPart.getContentType();
            if(mime !=null){
                if(mime.startsWith("audio")) type = MessageType.AUDIO;
                else if (mime.startsWith("video")) type = MessageType.VIDEO;
                else if (mime.startsWith("image")) type = MessageType.IMAGE;
            }
        }
        chatService.sendMessage(senderId,receiverId,content,mediaUrl,type,replyToId);
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
