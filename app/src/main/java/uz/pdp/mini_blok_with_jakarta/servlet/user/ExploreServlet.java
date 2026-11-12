package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.FeedDao;
import uz.pdp.mini_blok_with_jakarta.dao.SocialDao;
import uz.pdp.mini_blok_with_jakarta.security.UserFlags;
import uz.pdp.mini_blok_with_jakarta.service.PostService;
import uz.pdp.mini_blok_with_jakarta.servlet.SidebarStats;

import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Explore: trenddagi postlar, ommabop hashtaglar va akkauntlar. /explore?tag=sayohat — hashtag bo'yicha */
@WebServlet(name = "ExploreServlet", urlPatterns = "/explore")
public class ExploreServlet extends HttpServlet {
    private static final Pattern TAG = Pattern.compile("#([\\p{L}\\p{N}_]{2,40})");
    private static final Pattern SAFE_TAG = Pattern.compile("^[\\p{L}\\p{N}_]{2,40}$");
    private final PostService postService = new PostService();
    private final FeedDao feedDao = new FeedDao();
    private final SocialDao socialDao = new SocialDao();

    /** Hashtag reytingi 5 daqiqa keshda saqlanadi */
    private static volatile List<Map.Entry<String, Integer>> tagCache = List.of();
    private static volatile long tagCacheAt = 0;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer me = (Integer) req.getSession().getAttribute("id");
        String tag = req.getParameter("tag");
        if (tag != null) {
            tag = tag.trim().replaceFirst("^#", "");
            if (!SAFE_TAG.matcher(tag).matches()) tag = null;
        }
        req.setAttribute("tag", tag);
        req.setAttribute("posts", postService.getTrending(me, tag == null ? null : tag.toLowerCase(Locale.ROOT), 36));
        req.setAttribute("tags", topTags());

        List<Map<String, Object>> people = new ArrayList<>();
        Set<Integer> mine = me == null ? Set.of() : socialDao.followingIds(me);
        for (Object[] r : feedDao.popularUsers(12)) {
            Integer id = (Integer) r[0];
            if (id.equals(me)) continue;
            Map<String, Object> m = new HashMap<>();
            m.put("id", id); m.put("username", r[1]); m.put("fullName", r[2]); m.put("avatar", r[3]);
            m.put("followers", ((Number) r[4]).longValue()); m.put("verified", UserFlags.isVerified(id)); m.put("iFollow", mine.contains(id));
            people.add(m);
            if (people.size() == 8) break;
        }
        req.setAttribute("people", people);
        SidebarStats.put(req, socialDao, me);
        req.getRequestDispatcher("/user/explore.jsp").forward(req, resp);
    }

    private List<Map.Entry<String, Integer>> topTags() {
        if (System.currentTimeMillis() - tagCacheAt < 5 * 60_000L && !tagCache.isEmpty()) return tagCache;
        Map<String, Integer> count = new HashMap<>();
        for (String c : feedDao.recentContents(30, 3000)) {
            if (c == null) continue;
            Set<String> seen = new HashSet<>();
            Matcher m = TAG.matcher(c);
            while (m.find()) { String t = m.group(1).toLowerCase(Locale.ROOT); if (seen.add(t)) count.merge(t, 1, Integer::sum); }
        }
        List<Map.Entry<String, Integer>> list = new ArrayList<>(count.entrySet());
        list.sort((a, b) -> b.getValue() - a.getValue());
        tagCache = list.subList(0, Math.min(16, list.size()));
        tagCacheAt = System.currentTimeMillis();
        return tagCache;
    }
}
