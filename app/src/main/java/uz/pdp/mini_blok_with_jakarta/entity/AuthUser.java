package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import uz.pdp.mini_blok_with_jakarta.enums.Role;
import uz.pdp.mini_blok_with_jakarta.enums.Status;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
@Entity
@Table(name = "auht_users", indexes = {
        @Index(name = "idx_user_username", columnList = "username")
})
public class AuthUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    private String bio;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Status status;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Role role;

    @CreationTimestamp
    @Column(name = "created_at",updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "location", length = 100)
    private String location;

    @Column(name = "cover_url")
    private String coverUrl;

    /** Admin bergan tasdiqlangan belgi (✓) */
    @Column(name = "verified")
    private Boolean verified;

    public boolean isVerifiedUser() { return Boolean.TRUE.equals(verified); }
    public boolean isBlocked() { return status == Status.BLOK; }

}
