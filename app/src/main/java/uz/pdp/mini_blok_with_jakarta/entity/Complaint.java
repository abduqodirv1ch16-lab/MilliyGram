package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
@Entity
@Table(name = "complaints")
public class Complaint {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id",nullable = false)
    private Integer userId;

    @Column(name = "post_id",nullable = false)
    private Integer postId;

    @Column(nullable = false, length = 500)
    private String reason;

    @CreationTimestamp
    @Column(name = "created_at",updatable = false)
    private LocalDateTime created_at;

    /** null yoki OPEN — ko'rib chiqilmagan, RESOLVED — post o'chirildi, DISMISSED — rad etildi */
    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "resolved_by")
    private Integer resolvedBy;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
}
