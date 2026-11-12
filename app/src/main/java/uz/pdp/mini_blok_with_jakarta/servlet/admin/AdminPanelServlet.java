package uz.pdp.mini_blok_with_jakarta.servlet.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** Admin panelning asosiy sahifasi (bitta sahifali ilova). Kirish AdminFilter orqali tekshiriladi. */
@WebServlet(name = "AdminPanelServlet", urlPatterns = {"/mgadmin", "/mgadmin/"})
public class AdminPanelServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/admin/panel.jsp").forward(req, resp);
    }
}
