package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dao.FollowDao;
import uz.pdp.mini_blok_with_jakarta.dao.PostDao;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.service.PostService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "PostListServlet", urlPatterns = "/profile")
public class PostListServlet extends HttpServlet {
 private final PostService postService = new PostService();
 private final AuthUserDao authUserDao = new AuthUserDao();
 private final FollowDao followDao = new FollowDao();
 private final PostDao postDao = new PostDao();

 @Override
 protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
  Integer currentUserId = (Integer) req.getSession().getAttribute("id");
  String targetUserIdStr = req.getParameter("userId");


  Integer targetUserId = (targetUserIdStr != null && !targetUserIdStr.isBlank())
          ? Integer.parseInt(targetUserIdStr)
          : currentUserId;

  AuthUser targetUser = authUserDao.findById(targetUserId).orElse(null);
  if (targetUser == null) {
   resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Foydalanuvchi topilmadi");
   return;
  }

  // Foydalanuvchining o'z postlari
  List<PostDetailResponseDTO> userPosts = postService.getUserPosts(targetUserId, currentUserId);

  // Hisoblagichlar
  long followersCount = followDao.countFollowers(targetUserId);
  long followingCount = followDao.countFollowing(targetUserId);
  // Sahifani ochish obuna holatini o'zgartirmasligi kerak — faqat o'qiymiz
  boolean isFollowing = currentUserId != null && !targetUserId.equals(currentUserId)
          && followDao.isFollowing(currentUserId, targetUserId);

  req.setAttribute("targetUser", targetUser);
  req.setAttribute("posts", userPosts);
  req.setAttribute("postCount", userPosts.size());
  req.setAttribute("followersCount", followersCount);
  req.setAttribute("followingCount", followingCount);
  req.setAttribute("isFollowing", isFollowing);
  req.setAttribute("isMe", targetUserId.equals(currentUserId));

  req.getRequestDispatcher("/user/post_list.jsp").forward(req, resp);
 }
}