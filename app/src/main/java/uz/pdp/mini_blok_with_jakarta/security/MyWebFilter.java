package uz.pdp.mini_blok_with_jakarta.security;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class MyWebFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI().substring(req.getContextPath().length());

        // Admin panelning o'z himoyasi bor (AdminFilter)
        if (uri.equals("/mgadmin") || uri.startsWith("/mgadmin/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        Object id = session == null ? null : session.getAttribute("id");

        // Admin bloklagan foydalanuvchi darhol tizimdan chiqariladi
        if (id instanceof Integer uid && UserFlags.isBlocked(uid)) {
            for (String k : new String[]{"id", "username", "role", "fullName", "avatar"}) session.removeAttribute(k);
            id = null;
            if (!uri.equals("/login")) {
                resp.sendRedirect(req.getContextPath() + "/login?blocked=1");
                return;
            }
        }

        if (uri.equals("/login") || uri.equals("/register") || uri.equals("/")) {
            chain.doFilter(request, response);
        } else if (id != null) {
            chain.doFilter(request, response);
        } else if (uri.startsWith("/api/")) {
            resp.setStatus(401);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Tizimga kiring\"}");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}
