package uz.pdp.mini_blok_with_jakarta.security;

import jakarta.servlet.http.HttpServletRequest;

public final class ClientIp {
    private ClientIp() {}
    /** Nginx orqali kelgan haqiqiy IP. Faqat lokal proksidan kelgan sarlavhaga ishoniladi. */
    public static String of(HttpServletRequest r) {
        String remote = r.getRemoteAddr();
        if ("127.0.0.1".equals(remote) || "0:0:0:0:0:0:0:1".equals(remote)) {
            String x = r.getHeader("X-Real-IP");
            if (x != null && !x.isBlank() && x.length() < 64) return x.trim();
        }
        return remote;
    }
}
