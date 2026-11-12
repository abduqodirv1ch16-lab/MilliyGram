package uz.pdp.mini_blok_with_jakarta.dto;

import java.time.LocalDateTime;

public record CommentResponseDTO(
        Integer id,
        String content,
        Integer userId,
        String username,
        String userAvatar,
        Integer postId,
        Integer parentId,
        long likeCount,
        long replyCount,       // Siz yozgan metod natijasi shu yerga tushadi
        boolean isLikedByMe,
        LocalDateTime createdAt
) {}