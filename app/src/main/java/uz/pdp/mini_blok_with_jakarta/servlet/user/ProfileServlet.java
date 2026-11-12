package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dao.FollowDao;
import uz.pdp.mini_blok_with_jakarta.dao.PostDao;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProfileServlet", urlPatterns = "/user/profile")
public class ProfileServlet extends HttpServlet {
    private final AuthUserDao authUserDao = new AuthUserDao();
    private final PostDao postDao = new PostDao();
    private final FollowDao followDao = new FollowDao();
    private final PostService postService = new PostService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("id") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        String idParam = req.getParameter("id");
        Integer userId;
        Integer currentUserId = null;

        Object sessId = session.getAttribute("id");
        if (sessId instanceof Long) {
            currentUserId = ((Long) sessId).intValue();
        } else if (sessId instanceof Integer) {
            currentUserId = (Integer) sessId;
        } else if (sessId != null) {
            currentUserId = Integer.parseInt(sessId.toString());
        }

        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                userId = Integer.parseInt(idParam.trim());
            } else {
                userId = currentUserId;
            }

            AuthUser profileUser = authUserDao.findById(userId).orElse(null);
            if (profileUser == null || (profileUser.isBlocked() && !profileUser.getId().equals(currentUserId))) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Foydalanuvchi topilmadi");
                return;
            }

            final Integer finalCurrentUserId = currentUserId;

            // Foydalanuvchining postlari
            List<PostDetailResponseDTO> profilePosts = postService.getUserPosts(userId, finalCurrentUserId);

            long followersCount = followDao.countFollowers(userId);
            long followingCount = followDao.countFollowing(userId);

            boolean isFollowing = currentUserId != null && !userId.equals(currentUserId)
                    && followDao.isFollowing(currentUserId, userId);

            // --- NAVBAR (Sidebar) UCHUN REAL STATISTIKA ---
            uz.pdp.mini_blok_with_jakarta.servlet.SidebarStats.put(req, new uz.pdp.mini_blok_with_jakarta.dao.SocialDao(), currentUserId);
            // ----------------------------------------------

            req.setAttribute("profileUser", profileUser);
            req.setAttribute("profilePosts", profilePosts);
            req.setAttribute("followersCount", followersCount);
            req.setAttribute("followingCount", followingCount);
            req.setAttribute("isFollowing", isFollowing);
            req.setAttribute("isMyProfile", currentUserId != null && currentUserId.equals(userId));

            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
        }
    }
}