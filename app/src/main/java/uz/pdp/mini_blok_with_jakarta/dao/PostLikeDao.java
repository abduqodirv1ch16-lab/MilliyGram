package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.PostLike;

import java.util.List;

public class PostLikeDao extends BaseDao {
    public boolean toggleLike(Integer userId, Integer postId) {
        return execute(em -> {
            em.getTransaction().begin();
            List<PostLike> likes = em.createQuery(
                            "select pl from PostLike pl where pl.userId =: userId and pl.postId =: postId", PostLike.class)
                    .setParameter("userId", userId)
                    .setParameter("postId", postId)
                    .getResultList();
            boolean isLiked;
            if (likes.isEmpty()) {
                PostLike newLike = PostLike.builder().userId(userId).postId(postId).build();
                em.persist(newLike);
                isLiked = true;
            } else {
                em.remove(likes.get(0));
                isLiked = false;
            }
            em.getTransaction().commit();
            return isLiked;
        });
    }

    public long countLikes(Integer postId) {
        return execute(em -> em.createQuery(
                        "select count(pl) from PostLike pl where pl.postId=:postId", Long.class)
                .setParameter("postId", postId)
                .getSingleResult());
    }

    public boolean isUserLiked(Integer userId, Integer postId) {
        return execute(em -> {
            Long count = em.createQuery(
                            "select count(pl) from PostLike pl where pl.userId=:userId and pl.postId=:postId", Long.class)
                    .setParameter("userId", userId)
                    .setParameter("postId", postId)
                    .getSingleResult();
            return count > 0;
        });
    }
}
