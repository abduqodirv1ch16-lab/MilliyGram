package uz.pdp.mini_blok_with_jakarta.servlet.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dto.LoginSuccessDTO;
import uz.pdp.mini_blok_with_jakarta.dto.RegisterDTO;
import uz.pdp.mini_blok_with_jakarta.service.AuthService;

import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet(name = "Register", urlPatterns = "/register")
public class RegisterServlet extends HttpServlet {
    private final AuthService authService = new AuthService();
    private static final Pattern USERNAME = Pattern.compile("^[A-Za-z0-9_.]{3,30}$");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String fullname = req.getParameter("fullname");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        fullname = fullname == null ? "" : fullname.trim();
        username = username == null ? "" : username.trim();

        String error = null;
        if (fullname.isEmpty() || fullname.length() > 100) error = "To'liq ism 1-100 belgi bo'lishi kerak.";
        else if (!USERNAME.matcher(username).matches()) error = "Username 3-30 belgi: harf, raqam, _ yoki . bo'lishi kerak.";
        else if (password == null || password.length() < 6 || password.length() > 100) error = "Parol 6-100 belgi bo'lishi kerak.";

        if (error != null) {
            req.setAttribute("errorMessage", error);
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        LoginSuccessDTO successDTO = authService.register(new RegisterDTO(fullname, username, password));

        if (successDTO != null) {
            HttpSession session = req.getSession();
            req.changeSessionId();
            session.setAttribute("id", successDTO.id());
            session.setAttribute("username", username);
            session.setAttribute("role", successDTO.role());
            resp.sendRedirect("/");
        } else {
            req.setAttribute("errorMessage", "Bu foydalanuvchi nomi (" + username + ") allaqachon band. Boshqa nom tanlang.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
        }
    }
}
