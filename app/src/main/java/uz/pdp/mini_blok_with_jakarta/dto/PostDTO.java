package uz.pdp.mini_blok_with_jakarta.dto;

import java.time.LocalDateTime;

public record PostDTO(Integer id, String title, String content, Integer userId, LocalDateTime time ) {

}
