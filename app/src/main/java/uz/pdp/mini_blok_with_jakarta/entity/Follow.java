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
@Table(name = "follows", uniqueConstraints = {
        @UniqueConstraint(name = "uk_follower_following",columnNames = {"follower_id","following_id"})
})
public class Follow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "follower_id",nullable = false)
    private Integer followerId;

    @Column(name = "following_id", nullable = false)
    private Integer followingId;

    @CreationTimestamp
    @Column(name = "created_at",updatable = false)
    private LocalDateTime createdAt;
}
