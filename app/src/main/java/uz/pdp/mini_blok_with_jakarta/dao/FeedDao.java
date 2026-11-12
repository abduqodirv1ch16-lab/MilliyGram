package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.entity.Post;
import uz.pdp.mini_blok_with_jakarta.enums.Status;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Tezkor so'rovlar: bir nechta post uchun hisoblagichlarni BITTA so'rovda oladi.
 * (Avval har bir post uchun 6 ta alohida so'rov ketardi.)
 */
public class FeedDao extends BaseDao {
    private static final String NOT_BLOCKED = " p.userId not in (select u.id from AuthUser u where u.status = :blk) ";

    public List<Post> feed(Integer beforeId, int limit) {
        return execute(em -> {
            var q = em.createQuery("select p from Post p where " + NOT_BLOCKED + (beforeId != null ? " and p.id < :b" : "") + " order by p.id desc", Post.class)
                    .setParameter("blk", Status.BLOK);
            if (beforeId != null) q.setParameter("b", beforeId);
            return q.setMaxResults(limit).getResultList();
        });
    }

    public List<Post> byUser(Integer userId) {
        return execute(em -> em.createQuery("select p from Post p where p.userId = :u order by p.id desc", Post.class)
                .setParameter("u", userId).getResultList());
    }

    public List<Post> savedBy(Integer userId) {
        return execute(em -> em.createQuery(
                "select p from Post p, SavedPost s where s.postId = p.id and s.userId = :u and " + NOT_BLOCKED + " order by s.id desc", Post.class)
                .setParameter("u", userId).setParameter("blk", Status.BLOK).getResultList());
    }

    /** Trenddagi postlar: oxirgi N kunda like*3 + izoh*4 + ko'rish/20 bo'yicha */
    @SuppressWarnings("unchecked")
    public List<Post> trending(int days, String tag, int limit) {
        return execute(em -> {
            var nq = em.createNativeQuery(
                    "select p.id from post p left join auht_users u on u.id = p.user_id " +
                    "where (u.status is null or u.status <> 'BLOK') and p.created_at > now() - make_interval(days => :d) " +
                    (tag != null ? "and p.content ~* :re " : "") +
                    "order by ((select count(*) from post_likes l where l.post_id = p.id) * 3 + (select count(*) from comment c where c.post_id = p.id) * 4 + coalesce(p.view_count,0) / 20.0) desc, p.id desc limit :l")
                    .setParameter("d", days).setParameter("l", limit);
            if (tag != null) nq.setParameter("re", "(^|[^[:alnum:]_])#" + tag + "([^[:alnum:]_]|$)");
            List<Integer> ids = nq.getResultList();
            if (ids.isEmpty()) return List.of();
            Map<Integer, Post> byId = new HashMap<>();
            for (Post p : em.createQuery("select p from Post p where p.id in :ids", Post.class).setParameter("ids", ids).getResultList()) byId.put(p.getId(), p);
            List<Post> out = new ArrayList<>();
            for (Integer id : ids) if (byId.containsKey(id)) out.add(byId.get(id));
            return out;
        });
    }

    /** Oxirgi 30 kundagi post matnlari (hashtaglarni sanash uchun) */
    public List<String> recentContents(int days, int limit) {
        LocalDateTime since = LocalDateTime.now().minusDays(days);
        return execute(em -> em.createQuery("select p.content from Post p where p.createdAt > :s and p.content like '%#%' order by p.id desc", String.class)
                .setParameter("s", since).setMaxResults(limit).getResultList());
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> popularUsers(int limit) {   // id, username, fullName, avatar, followers
        return execute(em -> em.createNativeQuery(
                "select u.id, u.username, u.full_name, u.avatar_url, count(f.id) fc from auht_users u left join follows f on f.following_id = u.id " +
                "where u.status <> 'BLOK' group by u.id order by fc desc, u.id limit :l").setParameter("l", limit).getResultList());
    }

    /* ---------- hisoblagichlar (bitta so'rovda) ---------- */
    private Map<Integer, Long> countBy(String jpql, Collection<Integer> ids) {
        Map<Integer, Long> m = new HashMap<>();
        if (ids.isEmpty()) return m;
        execute(em -> {
            for (Object[] r : em.createQuery(jpql, Object[].class).setParameter("ids", ids).getResultList())
                m.put((Integer) r[0], ((Number) r[1]).longValue());
            return null;
        });
        return m;
    }
    public Map<Integer, Long> likeCounts(Collection<Integer> ids) { return countBy("select l.postId, count(l) from PostLike l where l.postId in :ids group by l.postId", ids); }
    public Map<Integer, Long> commentCounts(Collection<Integer> ids) { return countBy("select c.postId, count(c) from Comment c where c.postId in :ids group by c.postId", ids); }
    public Map<Integer, Long> saveCounts(Collection<Integer> ids) { return countBy("select s.postId, count(s) from SavedPost s where s.postId in :ids group by s.postId", ids); }

    public Set<Integer> likedBy(Integer userId, Collection<Integer> ids) {
        if (userId == null || ids.isEmpty()) return Set.of();
        return new HashSet<>(execute(em -> em.createQuery("select l.postId from PostLike l where l.userId = :u and l.postId in :ids", Integer.class)
                .setParameter("u", userId).setParameter("ids", ids).getResultList()));
    }
    public Set<Integer> savedBy(Integer userId, Collection<Integer> ids) {
        if (userId == null || ids.isEmpty()) return Set.of();
        return new HashSet<>(execute(em -> em.createQuery("select s.postId from SavedPost s where s.userId = :u and s.postId in :ids", Integer.class)
                .setParameter("u", userId).setParameter("ids", ids).getResultList()));
    }
    public Map<Integer, AuthUser> users(Collection<Integer> ids) {
        Map<Integer, AuthUser> m = new HashMap<>();
        if (ids.isEmpty()) return m;
        for (AuthUser u : execute(em -> em.createQuery("select u from AuthUser u where u.id in :ids", AuthUser.class).setParameter("ids", ids).getResultList()))
            m.put(u.getId(), u);
        return m;
    }

    /* ---------- izohlar uchun ---------- */
    public Map<Integer, Long> commentLikeCounts(Collection<Integer> ids) { return countBy("select l.commentId, count(l) from CommentLike l where l.commentId in :ids group by l.commentId", ids); }
    public Map<Integer, Long> replyCounts(Collection<Integer> ids) { return countBy("select c.parentId, count(c) from Comment c where c.parentId in :ids group by c.parentId", ids); }
    public Set<Integer> commentsLikedBy(Integer userId, Collection<Integer> ids) {
        if (userId == null || ids.isEmpty()) return Set.of();
        return new HashSet<>(execute(em -> em.createQuery("select l.commentId from CommentLike l where l.userId = :u and l.commentId in :ids", Integer.class)
                .setParameter("u", userId).setParameter("ids", ids).getResultList()));
    }
}
