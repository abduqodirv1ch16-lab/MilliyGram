package uz.pdp.mini_blok_with_jakarta.servlet.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dto.LoginDTO;
import uz.pdp.mini_blok_with_jakarta.dto.LoginSuccessDTO;
import uz.pdp.mini_blok_with_jakarta.security.UserFlags;
import uz.pdp.mini_blok_with_jakarta.service.AuthService;

import java.io.IOException;

@WebServlet(name = "Login", urlPatterns = "/login")
public class LoginServlet extends HttpServlet {
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getParameter("blocked") != null) {
            req.setAttribute("errorMessage", "Akkauntingiz administrator tomonidan bloklangan.");
        }
        req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        LoginSuccessDTO successDTO = null;
        if (username != null && password != null && username.length() <= 30 && password.length() <= 100) {
            username = username.trim();
            successDTO = authService.loginDTO(new LoginDTO(username, password));
        }

        if (successDTO != null && UserFlags.isBlocked(successDTO.id())) {
            req.setAttribute("errorMessage", "Akkauntingiz administrator tomonidan bloklangan.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
            return;
        }
        if (successDTO != null) {
            HttpSession session = req.getSession();
            req.changeSessionId();               // sessiya o'g'irlashning oldini olish (session fixation)
            session.setAttribute("id", successDTO.id());
            session.setAttribute("username", username);
            session.setAttribute("role", successDTO.role());
            resp.sendRedirect("/");
        } else {
            req.setAttribute("errorMessage", "Foydalanuvchi nomi yoki parol noto'g'ri kiritildi.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
        }
    }
}
