package uz.pdp.mini_blok_with_jakarta.servlet.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.utils.FileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

/** Admin panelda rasm/videolarni ko'rsatish (admin oddiy foydalanuvchi sifatida kirmagan bo'lishi mumkin). */
@WebServlet(name = "AdminMediaServlet", urlPatterns = "/mgadmin/media")
public class AdminMediaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        File f = FileUtils.resolveSafe(req.getParameter("name"));
        if (f == null || !f.isFile()) { resp.sendError(404); return; }
        resp.setContentType(FileUtils.mimeOf(f.getName()));
        resp.setHeader("Content-Security-Policy", "default-src 'none'; sandbox");
        resp.setHeader("Cache-Control", "private, max-age=3600");
        resp.setContentLengthLong(f.length());
        try (FileInputStream in = new FileInputStream(f); OutputStream out = resp.getOutputStream()) { in.transferTo(out); }
    }
}
