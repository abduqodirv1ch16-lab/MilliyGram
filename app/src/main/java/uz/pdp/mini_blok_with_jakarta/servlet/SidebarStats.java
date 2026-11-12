package uz.pdp.mini_blok_with_jakarta.servlet;

import jakarta.servlet.http.HttpServletRequest;
import uz.pdp.mini_blok_with_jakarta.dao.SocialDao;

/** Chap paneldagi Posts / Followers / Following sonlari — 3 ta tezkor COUNT so'rovi */
public final class SidebarStats {
    private SidebarStats() {}
    public static void put(HttpServletRequest req, SocialDao dao, Integer me) {
        if (me == null) return;
        req.setAttribute("realPostCount", dao.countPosts(me));
        req.setAttribute("realFollowerCount", dao.countFollowers(me));
        req.setAttribute("realFollowingCount", dao.countFollowing(me));
    }
}
