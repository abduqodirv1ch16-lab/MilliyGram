package uz.pdp.mini_blok_with_jakarta.dto;

public record PostCreateDTO(
        String title,
        String content,
        String mediaUrl,
        String mediaType,
        Integer userId
) {}