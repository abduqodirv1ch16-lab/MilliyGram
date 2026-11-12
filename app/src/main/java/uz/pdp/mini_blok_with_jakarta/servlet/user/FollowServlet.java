package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.FollowDao;
import uz.pdp.mini_blok_with_jakarta.service.InteractionService;

import java.io.IOException;

@WebServlet(name = "FollowServlet",urlPatterns = "/user/follow")
public class FollowServlet extends HttpServlet {
    private final InteractionService interactionService = new InteractionService();
    private final FollowDao followDao = new FollowDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer followerId = (Integer) req.getSession().getAttribute("id");
        String targetIdStr = req.getParameter("targetUserId");

        if(targetIdStr == null || followerId == null){
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Integer targetUserId = Integer.parseInt(targetIdStr);
        boolean isFollowing = interactionService.toggleFollow(followerId,targetUserId);
        long followerCount = followDao.countFollowers(targetUserId);

        resp.setContentType("application/json");
        resp.getWriter().write(String.format("{\"following\": %b, \"followersCount\": %d}",isFollowing,followerCount));
    }
}
