package uz.pdp.mini_blok_with_jakarta.dao;

/** Ilova ishga tushganda bir marta: tezlik uchun indekslar yaratadi (bor bo'lsa — tegmaydi). */
public class StartupDao extends BaseDao {
    private static final String[] INDEXES = {
            "create index if not exists idx_post_created on post(created_at desc)",
            "create index if not exists idx_post_user_created on post(user_id, created_at desc)",
            "create index if not exists idx_post_likes_post on post_likes(post_id)",
            "create index if not exists idx_comment_post on comment(post_id)",
            "create index if not exists idx_comment_parent on comment(parent_id)",
            "create index if not exists idx_comment_likes_comment on comment_likes(comment_id)",
            "create index if not exists idx_saved_post_post on saved_post(post_id)",
            "create index if not exists idx_follows_following on follows(following_id)",
            "create index if not exists idx_complaints_post on complaints(post_id)",
            "create index if not exists idx_chat_pair on chat_messages(sender_id, reseiver_id)",
            "create index if not exists idx_chat_receiver on chat_messages(reseiver_id)",
            "create index if not exists idx_stories_user on stories(userid, createdat)",
            "create index if not exists idx_users_created on auht_users(created_at)"
    };

    public void ensureIndexes() {
        for (String sql : INDEXES) {
            try { executeInTransaction(em -> em.createNativeQuery(sql).executeUpdate()); }
            catch (Exception e) { System.err.println("[MilliyGram] index: " + e.getMessage()); }
        }
    }
}
