package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/** Admin harakatlari va kirish urinishlari jurnali */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity
@Table(name = "admin_logs", indexes = {
        @Index(name = "idx_admin_logs_created", columnList = "created_at"),
        @Index(name = "idx_admin_logs_type", columnList = "type")
})
public class AdminLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "admin_id")
    private Integer adminId;

    @Column(name = "admin_username", length = 40)
    private String adminUsername;

    /** LOGIN / ACTION / SECURITY */
    @Column(nullable = false, length = 20)
    private String type;

    @Column(nullable = false, length = 60)
    private String action;

    @Column(length = 120)
    private String target;

    @Column(length = 1000)
    private String details;

    @Column(length = 64)
    private String ip;

    @Column(name = "user_agent", length = 300)
    private String userAgent;

    @Column(nullable = false)
    private Boolean success;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
