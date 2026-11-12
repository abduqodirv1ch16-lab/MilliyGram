package uz.pdp.mini_blok_with_jakarta.dto;

public record CommentCreateDTO(
        Integer postId,
        Integer userId,
        String content,
        Integer parentId // null bo'lsa asosiy komment, raqam bo'lsa reply
) {}