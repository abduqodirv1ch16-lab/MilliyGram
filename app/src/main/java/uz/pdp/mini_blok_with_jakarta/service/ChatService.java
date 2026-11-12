package uz.pdp.mini_blok_with_jakarta.service;

import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dao.ChatMessageDao;
import uz.pdp.mini_blok_with_jakarta.dto.ChatMessageDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.entity.ChatMessage;
import uz.pdp.mini_blok_with_jakarta.enums.MessageType;

import java.util.List;
import java.util.Optional;

public class ChatService {
    private final ChatMessageDao chatMessageDao =new ChatMessageDao();
    private final AuthUserDao authUserDao = new AuthUserDao();
    public void sendMessage(Integer senderId, Integer receiverId, String content, String mediaUrl, MessageType type, Integer replyId){
        ChatMessage message = ChatMessage.builder()
                .senderId(senderId)
                .receiverId(receiverId)
                .content(content)
                .mediaUrl(mediaUrl)
                .messageType(type)
                .replyToId(replyId)
                .isDeleted(false)
                .build();
        chatMessageDao.save(message);
    }
    public List<ChatMessageDTO> getCHatHistory(Integer currentUserId, Integer targetUserId){
        return chatMessageDao.getChatHistory(currentUserId,targetUserId).stream()
                .map(message -> {
                    AuthUser sender = authUserDao.findById(message.getSenderId()).orElse(null);
                    return new ChatMessageDTO(
                            message.getId(),
                            message.getSenderId(),
                            sender != null ? sender.getUsername() : "Noma'lum",
                            message.getReceiverId(),
                            message.getIsDeleted() ? "Ushbu xabar o'chirildi" : message.getContent(),
                            message.getIsDeleted() ? null : message.getMediaUrl(),
                            message.getMessageType(),
                            message.getReplyToId(),
                            message.getIsDeleted(),
                            message.getCreatedAt()
                    );
                }).toList();
    }

    public boolean editMessage(Integer messageId, Integer senderId,String newContent){
        Optional<ChatMessage> optional = chatMessageDao.findById(messageId);
        if(optional.isEmpty()) return false;

        ChatMessage message = optional.get();
        if(!message.getSenderId().equals(senderId) || message.getIsDeleted()){
            return false;
        }
        message.setContent(newContent);
        chatMessageDao.update(message);
        return true;
    }
    public void deleteMessage(Integer messageId, Integer senderId){
        chatMessageDao.softDelete(messageId,senderId);
    }
}
