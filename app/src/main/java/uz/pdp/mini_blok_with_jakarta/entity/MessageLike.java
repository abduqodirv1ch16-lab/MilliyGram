package uz.pdp.mini_blok_with_jakarta.entity;

import jakarta.persistence.*;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
@Entity
@Table(name = "message_likes", uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_message_like", columnNames = {"user_id", "message_id"})
})
public class MessageLike {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "message_id", nullable = false)
    private Integer messageId;
}
