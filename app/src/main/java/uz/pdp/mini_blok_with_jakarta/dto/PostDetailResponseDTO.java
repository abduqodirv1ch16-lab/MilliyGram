package uz.pdp.mini_blok_with_jakarta.dto;

import java.time.LocalDateTime;

public record PostDetailResponseDTO(
        Integer id,
        String title,
        String content,
        String mediaUrl,
        String mediaType,
        Long viewCount,
        long likeCount,
        long commentCount,
        long saveCount,
        boolean isLikedByMe,
        boolean isSavedByMe,
        Integer authorId,
        String authorUsername,
        String authorAvatar,
        LocalDateTime createdAt,
        boolean authorVerified
) {}