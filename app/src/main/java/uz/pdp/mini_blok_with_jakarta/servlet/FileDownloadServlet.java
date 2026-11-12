package uz.pdp.mini_blok_with_jakarta.servlet;

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

@WebServlet(name = "FileDownloadServlet", urlPatterns = "/download")
public class FileDownloadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Faqat yuklangan papkadagi, UUID nomli fayllar beriladi — "../" orqali boshqa fayllarni o'qib bo'lmaydi
        File file = FileUtils.resolveSafe(req.getParameter("name"));
        if (file == null || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Fayl topilmadi");
            return;
        }
        resp.setContentType(FileUtils.mimeOf(file.getName()));
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("Content-Security-Policy", "default-src 'none'; sandbox");
        resp.setHeader("Cache-Control", "private, max-age=86400");
        resp.setContentLengthLong(file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
