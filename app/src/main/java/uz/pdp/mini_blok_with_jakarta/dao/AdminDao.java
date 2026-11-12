package uz.pdp.mini_blok_with_jakarta.dao;

import jakarta.persistence.EntityManager;
import uz.pdp.mini_blok_with_jakarta.entity.AdminLog;
import uz.pdp.mini_blok_with_jakarta.entity.AdminUser;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.enums.Status;

import java.time.LocalDateTime;
import java.util.*;

/** Admin panel uchun barcha baza so'rovlari. Hammasi parametrli — SQL injection mumkin emas. */
public class AdminDao extends BaseDao {

    /* ======================= Adminlar ======================= */
    public long countAdmins() {
        return execute(em -> em.createQuery("select count(a) from AdminUser a", Long.class).getSingleResult());
    }
    public Optional<AdminUser> findAdmin(String username) {
        return execute(em -> em.createQuery("select a from AdminUser a where lower(a.username) = lower(:u)", AdminUser.class)
                .setParameter("u", username).getResultStream().findFirst());
    }
    public Optional<AdminUser> findAdmin(Integer id) {
        return execute(em -> Optional.ofNullable(em.find(AdminUser.class, id)));
    }
    public List<AdminUser> listAdmins() {
        return execute(em -> em.createQuery("select a from AdminUser a order by a.id", AdminUser.class).getResultList());
    }
    public void saveAdmin(AdminUser a) { executeInTransaction(em -> em.persist(a)); }
    public void updateAdmin(AdminUser a) { executeInTransaction(em -> em.merge(a)); }

    /* ======================= Jurnal ======================= */
    public void log(AdminLog l) {
        try { executeInTransaction(em -> em.persist(l)); } catch (Exception ignored) { }
    }
    public List<AdminLog> logs(String type, int page, int size) {
        return execute(em -> {
            String q = "select l from AdminLog l" + (type != null ? " where l.type = :t" : "") + " order by l.id desc";
            var query = em.createQuery(q, AdminLog.class);
            if (type != null) query.setParameter("t", type);
            return query.setFirstResult(page * size).setMaxResults(size).getResultList();
        });
    }
    public long countLogs(String type) {
        return execute(em -> {
            var q = em.createQuery("select count(l) from AdminLog l" + (type != null ? " where l.type = :t" : ""), Long.class);
            if (type != null) q.setParameter("t", type);
            return q.getSingleResult();
        });
    }
    public long countFailedLoginsSince(LocalDateTime since) {
        return execute(em -> em.createQuery(
                "select count(l) from AdminLog l where l.type = 'LOGIN' and l.success = false and l.createdAt > :s", Long.class)
                .setParameter("s", since).getSingleResult());
    }

    /* ======================= Statistika ======================= */
    private static long num(Object o) { return o == null ? 0 : ((Number) o).longValue(); }

    public Map<String, Long> totals() {
        return execute(em -> {
            Object[] r = (Object[]) em.createNativeQuery(
                    "select (select count(*) from auht_users), " +
                    "(select count(*) from auht_users where status = 'BLOK'), " +
                    "(select count(*) from auht_users where verified = true), " +
                    "(select count(*) from post), " +
                    "(select count(*) from comment), " +
                    "(select count(*) from post_likes), " +
                    "(select count(*) from chat_messages), " +
                    "(select count(*) from stories where createdat > now() - interval '24 hours'), " +
                    "(select count(*) from complaints where status is null or status = 'OPEN'), " +
                    "(select count(*) from auht_users where created_at > now() - interval '24 hours'), " +
                    "(select count(*) from post where created_at > now() - interval '24 hours'), " +
                    "(select count(*) from follows), " +
                    "(select count(distinct sender_id) from chat_messages where created_at > now() - interval '24 hours')")
                    .getSingleResult();
            Map<String, Long> m = new LinkedHashMap<>();
            String[] k = {"users", "blocked", "verified", "posts", "comments", "likes", "messages", "storiesActive",
                    "complaintsOpen", "usersToday", "postsToday", "follows", "chattersToday"};
            for (int i = 0; i < k.length; i++) m.put(k[i], num(r[i]));
            return m;
        });
    }

    /** Oxirgi N kun bo'yicha kunlik son: [sana, soni] */
    @SuppressWarnings("unchecked")
    public List<Object[]> dailySeries(String table, int days) {
        String t = switch (table) {   // jadval nomi faqat ruxsat etilgan ro'yxatdan
            case "users" -> "auht_users";
            case "posts" -> "post";
            case "comments" -> "comment";
            case "likes" -> "post_likes";
            case "messages" -> "chat_messages";
            default -> throw new IllegalArgumentException("jadval");
        };
        return execute(em -> em.createNativeQuery(
                "select to_char(d, 'YYYY-MM-DD'), coalesce(c.n, 0) from generate_series(current_date - (:days - 1), current_date, interval '1 day') d " +
                "left join (select created_at::date dd, count(*) n from " + t + " where created_at >= current_date - (:days - 1) group by 1) c on c.dd = d::date order by d")
                .setParameter("days", days).getResultList());
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> topUsers(int limit) {   // id, username, fullName, avatar, verified, followers, posts
        return execute(em -> em.createNativeQuery(
                "select u.id, u.username, u.full_name, u.avatar_url, coalesce(u.verified,false), " +
                "(select count(*) from follows f where f.following_id = u.id) fc, (select count(*) from post p where p.user_id = u.id) pc " +
                "from auht_users u order by fc desc, pc desc, u.id limit :l")
                .setParameter("l", limit).getResultList());
    }

    /* ======================= Foydalanuvchilar ======================= */
    @SuppressWarnings("unchecked")
    public List<Object[]> users(String q, String filter, int page, int size) {
        // id, username, full_name, avatar, status, verified, created_at, posts, followers, following
        return execute(em -> em.createNativeQuery(
                "select u.id, u.username, u.full_name, u.avatar_url, u.status, coalesce(u.verified,false), to_char(u.created_at,'YYYY-MM-DD HH24:MI'), " +
                "(select count(*) from post p where p.user_id = u.id), (select count(*) from follows f where f.following_id = u.id), " +
                "(select count(*) from follows f where f.follower_id = u.id) " +
                "from auht_users u where (:q = '' or u.username ilike :lq or u.full_name ilike :lq) " +
                "and (:f = 'all' or (:f = 'blocked' and u.status = 'BLOK') or (:f = 'verified' and u.verified = true) or (:f = 'active' and u.status = 'ACTIVE')) " +
                "order by u.id desc offset :o limit :l")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").setParameter("f", filter)
                .setParameter("o", page * size).setParameter("l", size).getResultList());
    }
    public long countUsers(String q, String filter) {
        return execute(em -> num(em.createNativeQuery(
                "select count(*) from auht_users u where (:q = '' or u.username ilike :lq or u.full_name ilike :lq) " +
                "and (:f = 'all' or (:f = 'blocked' and u.status = 'BLOK') or (:f = 'verified' and u.verified = true) or (:f = 'active' and u.status = 'ACTIVE'))")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").setParameter("f", filter).getSingleResult()));
    }
    public Optional<AuthUser> findUser(Integer id) {
        return execute(em -> Optional.ofNullable(em.find(AuthUser.class, id)));
    }
    public void setUserStatus(Integer id, Status s) {
        executeInTransaction(em -> { AuthUser u = em.find(AuthUser.class, id); if (u != null) u.setStatus(s); });
    }
    public void setVerified(Integer id, boolean v) {
        executeInTransaction(em -> { AuthUser u = em.find(AuthUser.class, id); if (u != null) u.setVerified(v); });
    }
    @SuppressWarnings("unchecked")
    public List<Integer> blockedIds() {
        return execute(em -> em.createQuery("select u.id from AuthUser u where u.status = :s", Integer.class)
                .setParameter("s", Status.BLOK).getResultList());
    }
    @SuppressWarnings("unchecked")
    public List<Integer> verifiedIds() {
        return execute(em -> em.createQuery("select u.id from AuthUser u where u.verified = true", Integer.class).getResultList());
    }

    /** Foydalanuvchini va uning barcha ma'lumotlarini o'chiradi. Fayl nomlarini qaytaradi (diskdan o'chirish uchun). */
    @SuppressWarnings("unchecked")
    public List<String> deleteUser(Integer id) {
        List<String> files = new ArrayList<>();
        executeInTransaction(em -> {
            files.addAll(em.createNativeQuery("select media_url from post where user_id = :id and media_url is not null").setParameter("id", id).getResultList());
            files.addAll(em.createNativeQuery("select mediaurl from stories where userid = :id").setParameter("id", id).getResultList());
            files.addAll(em.createNativeQuery("select media_url from chat_messages where sender_id = :id and media_url is not null").setParameter("id", id).getResultList());
            files.addAll(em.createNativeQuery("select x from (select avatar_url x from auht_users where id = :id union all select cover_url from auht_users where id = :id) t where x is not null").setParameter("id", id).getResultList());
            List<Integer> postIds = em.createNativeQuery("select id from post where user_id = :id").setParameter("id", id).getResultList();
            for (Integer pid : postIds) deletePostRows(em, pid);
            String[] sql = {
                    "delete from comment_likes where user_id = :id or comment_id in (select c.id from comment c where c.user_id = :id or c.parent_id in (select id from comment where user_id = :id))",
                    "delete from comment where parent_id in (select id from comment where user_id = :id)",
                    "delete from comment where user_id = :id",
                    "delete from post_likes where user_id = :id",
                    "delete from saved_post where user_id = :id",
                    "delete from post_views where user_id = :id",
                    "delete from complaints where user_id = :id",
                    "delete from follows where follower_id = :id or following_id = :id",
                    "delete from message_likes where user_id = :id or message_id in (select m.id from chat_messages m where m.sender_id = :id or m.reseiver_id = :id)",
                    "delete from chat_messages where sender_id = :id or reseiver_id = :id",
                    "delete from stories where userid = :id",
                    "delete from auht_users where id = :id"
            };
            for (String s : sql) em.createNativeQuery(s).setParameter("id", id).executeUpdate();
        });
        return files;
    }

    /* ======================= Kontent ======================= */
    @SuppressWarnings("unchecked")
    public List<Object[]> posts(String q, int page, int size) {
        // id, title, content, media_url, media_type, created_at, user_id, username, likes, comments, complaints, views
        return execute(em -> em.createNativeQuery(
                "select p.id, p.title, left(p.content, 300), p.media_url, p.media_type, to_char(p.created_at,'YYYY-MM-DD HH24:MI'), p.user_id, u.username, " +
                "(select count(*) from post_likes l where l.post_id = p.id), (select count(*) from comment c where c.post_id = p.id), " +
                "(select count(*) from complaints k where k.post_id = p.id and (k.status is null or k.status='OPEN')), p.view_count " +
                "from post p left join auht_users u on u.id = p.user_id where (:q = '' or p.title ilike :lq or p.content ilike :lq or u.username ilike :lq) " +
                "order by p.id desc offset :o limit :l")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").setParameter("o", page * size).setParameter("l", size).getResultList());
    }
    public long countPosts(String q) {
        return execute(em -> num(em.createNativeQuery(
                "select count(*) from post p left join auht_users u on u.id = p.user_id where (:q = '' or p.title ilike :lq or p.content ilike :lq or u.username ilike :lq)")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").getSingleResult()));
    }
    @SuppressWarnings("unchecked")
    public List<Object[]> comments(String q, int page, int size) {
        // id, content, created_at, user_id, username, post_id, likes
        return execute(em -> em.createNativeQuery(
                "select c.id, c.content, to_char(c.created_at,'YYYY-MM-DD HH24:MI'), c.user_id, u.username, c.post_id, " +
                "(select count(*) from comment_likes l where l.comment_id = c.id) " +
                "from comment c left join auht_users u on u.id = c.user_id where (:q = '' or c.content ilike :lq or u.username ilike :lq) " +
                "order by c.id desc offset :o limit :l")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").setParameter("o", page * size).setParameter("l", size).getResultList());
    }
    public long countComments(String q) {
        return execute(em -> num(em.createNativeQuery(
                "select count(*) from comment c left join auht_users u on u.id = c.user_id where (:q = '' or c.content ilike :lq or u.username ilike :lq)")
                .setParameter("q", q).setParameter("lq", "%" + q + "%").getSingleResult()));
    }

    /** Postni va unga bog'liq barcha yozuvlarni o'chiradi. Media fayl nomini qaytaradi. */
    public String deletePost(Integer postId) {
        final String[] media = {null};
        executeInTransaction(em -> {
            Object m = em.createNativeQuery("select media_url from post where id = :id").setParameter("id", postId)
                    .getResultStream().findFirst().orElse(null);
            media[0] = m == null ? null : m.toString();
            deletePostRows(em, postId);
        });
        return media[0];
    }
    private void deletePostRows(EntityManager em, Integer pid) {
        String[] sql = {
                "delete from comment_likes where comment_id in (select id from comment where post_id = :p)",
                "delete from comment where post_id = :p and parent_id is not null",
                "delete from comment where post_id = :p",
                "delete from post_likes where post_id = :p",
                "delete from saved_post where post_id = :p",
                "delete from post_views where post_id = :p",
                "update complaints set status = 'RESOLVED', resolved_at = now() where post_id = :p and (status is null or status = 'OPEN')",
                "delete from post where id = :p"
        };
        for (String s : sql) em.createNativeQuery(s).setParameter("p", pid).executeUpdate();
    }
    public void deleteComment(Integer id) {
        executeInTransaction(em -> {
            em.createNativeQuery("delete from comment_likes where comment_id = :id or comment_id in (select id from comment where parent_id = :id)").setParameter("id", id).executeUpdate();
            em.createNativeQuery("delete from comment where parent_id = :id").setParameter("id", id).executeUpdate();
            em.createNativeQuery("delete from comment where id = :id").setParameter("id", id).executeUpdate();
        });
    }

    /* ======================= Shikoyatlar ======================= */
    @SuppressWarnings("unchecked")
    public List<Object[]> complaintGroups(boolean open, int limit) {
        // post_id, count, last_at, reasons(joined), title, content, media_url, media_type, author_id, author_username, post_exists
        return execute(em -> em.createNativeQuery(
                "select k.post_id, count(*), to_char(max(k.created_at),'YYYY-MM-DD HH24:MI'), string_agg(distinct left(k.reason,200), ' ¦ '), " +
                "max(p.title), max(left(p.content,300)), max(p.media_url), max(p.media_type), max(p.user_id), max(u.username), count(p.id) > 0, max(k.status) " +
                "from complaints k left join post p on p.id = k.post_id left join auht_users u on u.id = p.user_id " +
                "where " + (open ? "(k.status is null or k.status = 'OPEN')" : "k.status in ('RESOLVED','DISMISSED')") +
                " group by k.post_id order by count(*) desc, max(k.created_at) desc limit :l")
                .setParameter("l", limit).getResultList());
    }
    public int setComplaintStatus(Integer postId, String status, Integer adminId) {
        final int[] n = {0};
        executeInTransaction(em -> n[0] = em.createNativeQuery(
                "update complaints set status = :s, resolved_by = :a, resolved_at = now() where post_id = :p and (status is null or status = 'OPEN')")
                .setParameter("s", status).setParameter("a", adminId).setParameter("p", postId).executeUpdate());
        return n[0];
    }

    /* ======================= Tizim ======================= */
    public Map<String, Object> dbInfo() {
        return execute(em -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("dbSize", em.createNativeQuery("select pg_size_pretty(pg_database_size(current_database()))").getSingleResult());
            m.put("dbVersion", em.createNativeQuery("select split_part(version(), ',', 1)").getSingleResult());
            m.put("connections", num(em.createNativeQuery("select count(*) from pg_stat_activity where datname = current_database()").getSingleResult()));
            return m;
        });
    }
}
