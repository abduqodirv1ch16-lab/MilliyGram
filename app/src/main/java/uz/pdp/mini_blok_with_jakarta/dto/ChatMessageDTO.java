package uz.pdp.mini_blok_with_jakarta.dto;

import uz.pdp.mini_blok_with_jakarta.enums.MessageType;
import java.time.LocalDateTime;

public record ChatMessageDTO(
        Integer id,
        Integer senderId,
        String senderUsername,
        Integer receiverId,
        String content,
        String mediaUrl,
        MessageType messageType,
        Integer replyToId,
        boolean isDeleted,
        LocalDateTime createdAt
) {}