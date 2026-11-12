package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "stories")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Story {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(nullable = false)
    private Integer userId;
    @Column(nullable = false)
    private String mediaUrl;
    @Column(nullable = false, length = 10)
    private String mediaType;            // IMAGE / VIDEO
    @Column(length = 300)
    private String caption;
    @CreationTimestamp
    private LocalDateTime createdAt;
}