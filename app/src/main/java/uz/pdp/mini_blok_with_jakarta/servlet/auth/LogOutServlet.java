package uz.pdp.mini_blok_with_jakarta.servlet.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import uz.pdp.mini_blok_with_jakarta.dto.LoginDTO;
import uz.pdp.mini_blok_with_jakarta.dto.LoginSuccessDTO;
import uz.pdp.mini_blok_with_jakarta.service.AuthService;

import java.io.IOException;

@WebServlet(name = "Logout", urlPatterns = "/logout")
public class LogOutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/auth/logout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
         req.getSession().invalidate();
        resp.sendRedirect("/login");


    }
}
