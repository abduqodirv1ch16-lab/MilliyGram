package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
@Entity
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false,length = 200)
    private String title;

    @Column(columnDefinition = "TEXT",nullable = false)
    private String content;

    @Column(name = "media_url")
    private String mediaURL;

    @Column(name = "media_type")
    private String mediaType;

    @Column(name = "view_count", nullable = false)
    private Long viewCount =0L;

    @Column(name = "user_id",nullable = false)
    private Integer userId;


    @CreationTimestamp
    @Column( name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
