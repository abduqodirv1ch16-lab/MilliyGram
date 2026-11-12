package uz.pdp.mini_blok_with_jakarta.dto;

public record PostUpdateDTO(
        Integer id,
        String title,
        String content,
        Integer userId // Tekshirish uchun: faqat post egasi tahrirlashi mumkin
) {}