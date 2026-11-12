package uz.pdp.mini_blok_with_jakarta.dto;

public record UserSearchResponseDTO(
        Integer id,
        String username,
        String fullName,
        String avatarUrl,
        boolean isFollowingByMe
) {}