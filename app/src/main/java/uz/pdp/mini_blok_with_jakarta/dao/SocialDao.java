package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.*;
import java.time.LocalDateTime;
import java.util.*;

public class SocialDao extends BaseDao {

    /* ---------- followers / following ---------- */
    public List<AuthUser> followersOf(Integer uid) {
        return execute(em -> em.createQuery(
                "select u from AuthUser u where u.id in (select f.followerId from Follow f where f.followingId = :uid) order by u.username",
                AuthUser.class).setParameter("uid", uid).getResultList());
    }
    public List<AuthUser> followingOf(Integer uid) {
        return execute(em -> em.createQuery(
                "select u from AuthUser u where u.id in (select f.followingId from Follow f where f.followerId = :uid) order by u.username",
                AuthUser.class).setParameter("uid", uid).getResultList());
    }
    public Set<Integer> followingIds(Integer uid) {
        return new HashSet<>(execute(em -> em.createQuery(
                "select f.followingId from Follow f where f.followerId = :uid", Integer.class)
                .setParameter("uid", uid).getResultList()));
    }
    public long countFollowers(Integer uid) {
        return execute(em -> em.createQuery("select count(f) from Follow f where f.followingId = :uid", Long.class)
                .setParameter("uid", uid).getSingleResult());
    }
    public long countFollowing(Integer uid) {
        return execute(em -> em.createQuery("select count(f) from Follow f where f.followerId = :uid", Long.class)
                .setParameter("uid", uid).getSingleResult());
    }
    public long countPosts(Integer uid) {
        return execute(em -> em.createQuery("select count(p) from Post p where p.userId = :uid", Long.class)
                .setParameter("uid", uid).getSingleResult());
    }
    /** meni kuzatayotgan followerId ni ro'yxatdan olib tashlaydi (Remove) */
    public void removeFollower(Integer me, Integer followerId) {
        executeInTransaction(em -> em.createQuery(
                "delete from Follow f where f.followerId = :fid and f.followingId = :me")
                .setParameter("fid", followerId).setParameter("me", me).executeUpdate());
    }

    /* ---------- stories ---------- */
    public Story saveStory(Story s) {
        executeInTransaction(em -> em.persist(s));
        return s;
    }
    public Optional<Story> findStory(Integer id) {
        return execute(em -> Optional.ofNullable(em.find(Story.class, id)));
    }
    public void updateStoryCaption(Integer id, String caption) {
        executeInTransaction(em -> {
            Story s = em.find(Story.class, id);
            if (s != null) s.setCaption(caption);
        });
    }
    public void deleteStory(Integer id) {
        executeInTransaction(em -> {
            Story s = em.find(Story.class, id);
            if (s != null) em.remove(s);
        });
    }
    /** oxirgi 24 soatdagi hikoyalar */
    public List<Story> activeStories(Collection<Integer> userIds) {
        if (userIds.isEmpty()) return List.of();
        LocalDateTime since = LocalDateTime.now().minusHours(24);
        return execute(em -> em.createQuery(
                "select s from Story s where s.userId in :ids and s.createdAt > :since order by s.createdAt asc", Story.class)
                .setParameter("ids", userIds).setParameter("since", since).getResultList());
    }

    /* ---------- bildirishnomalar (yangi jadval kerak emas) ---------- */
    public List<Object[]> likeNotifs(Integer me) {   // userId, postId, createdAt, mediaUrl
        return execute(em -> em.createQuery(
                "select l.userId, l.postId, l.createdAt, p.mediaURL from PostLike l, Post p " +
                "where p.id = l.postId and p.userId = :me and l.userId <> :me and l.createdAt is not null order by l.createdAt desc",
                Object[].class).setParameter("me", me).setMaxResults(40).getResultList());
    }
    public List<Object[]> commentNotifs(Integer me) {  // userId, postId, content, createdAt, mediaUrl
        return execute(em -> em.createQuery(
                "select c.userId, c.postId, c.content, c.createdAt, p.mediaURL from Comment c, Post p " +
                "where p.id = c.postId and p.userId = :me and c.userId <> :me and c.parentId is null and c.createdAt is not null order by c.createdAt desc",
                Object[].class).setParameter("me", me).setMaxResults(40).getResultList());
    }
    public List<Object[]> replyNotifs(Integer me) {    // javoblar: mening izohimga
        return execute(em -> em.createQuery(
                "select c.userId, c.postId, c.content, c.createdAt, p.mediaURL from Comment c, Comment pc, Post p " +
                "where c.parentId = pc.id and pc.userId = :me and p.id = c.postId and c.userId <> :me and c.createdAt is not null order by c.createdAt desc",
                Object[].class).setParameter("me", me).setMaxResults(40).getResultList());
    }
    public List<Object[]> followNotifs(Integer me) {   // followerId, createdAt
        return execute(em -> em.createQuery(
                "select f.followerId, f.createdAt from Follow f where f.followingId = :me and f.createdAt is not null order by f.createdAt desc",
                Object[].class).setParameter("me", me).setMaxResults(40).getResultList());
    }

    /* ---------- post vaqti, ko'rishlar, izoh vaqtlari ---------- */
    public List<Object[]> postMeta(Collection<Integer> ids) {   // id, viewCount, createdAt
        if (ids.isEmpty()) return List.of();
        return execute(em -> em.createQuery(
                "select p.id, p.viewCount, p.createdAt from Post p where p.id in :ids", Object[].class)
                .setParameter("ids", ids).getResultList());
    }
    public List<Object[]> commentTimes(Collection<Integer> ids) {  // id, createdAt
        if (ids.isEmpty()) return List.of();
        return execute(em -> em.createQuery(
                "select c.id, c.createdAt from Comment c where c.id in :ids", Object[].class)
                .setParameter("ids", ids).getResultList());
    }

    public long registerView(Integer postId, Integer userId) {
        final long[] result = {0L};
        executeInTransaction(em -> {
            long seen = em.createQuery(
                            "select count(v) from PostView v where v.postId = :p and v.userId = :u", Long.class)
                    .setParameter("p", postId).setParameter("u", userId).getSingleResult();
            if (seen == 0) {
                em.persist(PostView.builder().postId(postId).userId(userId).build());
                em.createQuery("update Post p set p.viewCount = p.viewCount + 1 where p.id = :p")
                        .setParameter("p", postId).executeUpdate();
            }
            Number n = em.createQuery("select p.viewCount from Post p where p.id = :p", Number.class)
                    .setParameter("p", postId).getSingleResult();
            result[0] = n == null ? 0L : n.longValue();
        });
        return result[0];
    }
}
