package uz.pdp.mini_blok_with_jakarta.security;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Admin panelning barcha manzillarini himoyalaydi:
 *  - qat'iy xavfsizlik sarlavhalari (CSP, freym taqiqi, kesh yo'q)
 *  - kirmagan bo'lsa → login sahifasiga
 *  - 30 daqiqa harakatsizlikda sessiya tugaydi
 *  - sessiya boshqa brauzerga ko'chirilsa (User-Agent o'zgarsa) — chiqarib yuboriladi
 *  - POST so'rovlarda CSRF token va Origin tekshiriladi
 */
@WebFilter("/mgadmin/*")
public class AdminFilter implements Filter {
    public static final long IDLE_MS = 30 * 60_000L;
    private static final SecureRandom RND = new SecureRandom();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        byte[] nb = new byte[16];
        RND.nextBytes(nb);
        String nonce = Base64.getEncoder().encodeToString(nb);
        req.setAttribute("cspNonce", nonce);
        resp.setHeader("Content-Security-Policy",
                "default-src 'self'; script-src 'nonce-" + nonce + "'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; " +
                "media-src 'self' blob:; connect-src 'self'; font-src 'self' data:; frame-ancestors 'none'; form-action 'self'; base-uri 'none'; object-src 'none'");
        resp.setHeader("X-Frame-Options", "DENY");
        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("Referrer-Policy", "no-referrer");
        resp.setHeader("Cache-Control", "no-store, max-age=0");
        resp.setHeader("X-Robots-Tag", "noindex, nofollow");

        String path = req.getRequestURI().substring(req.getContextPath().length());
        boolean open = path.equals("/mgadmin/login") || path.equals("/mgadmin/setup");
        if (open) { chain.doFilter(request, response); return; }

        HttpSession s = req.getSession(false);
        Integer adminId = s == null ? null : (Integer) s.getAttribute("adminId");
        boolean api = path.startsWith("/mgadmin/api/");
        if (adminId != null) {
            Long seen = (Long) s.getAttribute("adminSeen");
            String uaHash = (String) s.getAttribute("adminUa");
            boolean idle = seen == null || System.currentTimeMillis() - seen > IDLE_MS;
            boolean uaChanged = uaHash == null || !uaHash.equals(uaHash(req));
            if (idle || uaChanged) {
                clearAdmin(s);
                adminId = null;
            }
        }
        if (adminId == null) {
            if (api) {
                resp.setStatus(401);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"error\":\"Sessiya tugadi, qayta kiring\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/mgadmin/login");
            }
            return;
        }
        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String token = req.getHeader("X-CSRF-Token");
            String expected = (String) s.getAttribute("adminCsrf");
            String origin = req.getHeader("Origin");
            boolean originOk = origin == null || sameHost(origin, req);
            if (expected == null || token == null || !MessageDigest.isEqual(expected.getBytes(), token.getBytes()) || !originOk) {
                resp.setStatus(403);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"error\":\"Xavfsizlik tekshiruvi o'tmadi (CSRF)\"}");
                return;
            }
        }
        // Fon so'rovlari (avtomatik yangilanish) sessiyani uzaytirmaydi — faqat adminning o'z harakatlari
        if (req.getHeader("X-Background") == null) s.setAttribute("adminSeen", System.currentTimeMillis());
        chain.doFilter(request, response);
    }

    private static boolean sameHost(String origin, HttpServletRequest req) {
        try {
            String host = new java.net.URI(origin).getHost();
            String reqHost = req.getHeader("Host");
            if (reqHost != null && reqHost.contains(":")) reqHost = reqHost.substring(0, reqHost.indexOf(':'));
            return host != null && host.equalsIgnoreCase(reqHost);
        } catch (Exception e) { return false; }
    }

    public static String uaHash(HttpServletRequest req) {
        String ua = req.getHeader("User-Agent");
        return Integer.toHexString((ua == null ? "" : ua).hashCode());
    }

    public static void clearAdmin(HttpSession s) {
        for (String k : new String[]{"adminId", "adminName", "adminSuper", "adminCsrf", "adminSeen", "adminUa", "adminPending", "adminPendingAt"})
            s.removeAttribute(k);
    }
}
