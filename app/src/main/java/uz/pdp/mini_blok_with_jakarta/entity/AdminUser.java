package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/** Admin panel foydalanuvchilari — oddiy sayt foydalanuvchilaridan butunlay alohida. */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Entity
@Table(name = "admin_users")
public class AdminUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true, length = 40)
    private String username;

    @Column(nullable = false)
    private String password;

    /** Google Authenticator uchun maxfiy kalit (Base32) */
    @Column(name = "totp_secret", nullable = false, length = 64)
    private String totpSecret;

    /** Oxirgi ishlatilgan kod qadami — bitta kodni ikki marta ishlatib bo'lmaydi */
    @Column(name = "totp_last_step")
    private Long totpLastStep;

    @Column(nullable = false)
    private Boolean enabled;

    @Column(name = "super_admin", nullable = false)
    private Boolean superAdmin;

    @Column(name = "failed_attempts", nullable = false)
    private Integer failedAttempts;

    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    @Column(name = "last_login_ip", length = 64)
    private String lastLoginIp;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
