package uz.pdp.mini_blok_with_jakarta.utils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;

/** Google Authenticator / Microsoft Authenticator bilan mos TOTP (RFC 6238): 6 xonali kod, 30 soniya. */
public final class Totp {
    private static final String B32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    private static final SecureRandom RND = new SecureRandom();
    private Totp() {}

    public static String newSecret() {
        byte[] b = new byte[20];
        RND.nextBytes(b);
        return base32(b);
    }

    public static long currentStep() { return System.currentTimeMillis() / 1000L / 30L; }

    /**
     * Kodni tekshiradi (±1 qadam, ya'ni ±30 soniya farq). Mos kelsa qadam raqamini, aks holda -1 qaytaradi.
     * lastStep — oxirgi muvaffaqiyatli qadam: undan katta bo'lmagan qadam qabul qilinmaydi (kodni qayta ishlatish taqiqlanadi).
     */
    public static long verify(String secret, String code, Long lastStep) {
        if (code == null) return -1;
        code = code.replaceAll("\\s", "");
        if (!code.matches("\\d{6}")) return -1;
        byte[] key = unbase32(secret);
        long now = currentStep();
        for (long s = now - 1; s <= now + 1; s++) {
            if (lastStep != null && s <= lastStep) continue;
            if (constantEq(code, codeAt(key, s))) return s;
        }
        return -1;
    }

    public static String otpauthUri(String issuer, String account, String secret) {
        String label = enc(issuer) + ":" + enc(account);
        return "otpauth://totp/" + label + "?secret=" + secret + "&issuer=" + enc(issuer) + "&algorithm=SHA1&digits=6&period=30";
    }

    static String codeAt(byte[] key, long step) {
        try {
            byte[] msg = new byte[8];
            for (int i = 7; i >= 0; i--) { msg[i] = (byte) (step & 0xff); step >>= 8; }
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(new SecretKeySpec(key, "HmacSHA1"));
            byte[] h = mac.doFinal(msg);
            int o = h[h.length - 1] & 0xf;
            int bin = ((h[o] & 0x7f) << 24) | ((h[o + 1] & 0xff) << 16) | ((h[o + 2] & 0xff) << 8) | (h[o + 3] & 0xff);
            return String.format("%06d", bin % 1_000_000);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static boolean constantEq(String a, String b) {
        if (a.length() != b.length()) return false;
        int r = 0;
        for (int i = 0; i < a.length(); i++) r |= a.charAt(i) ^ b.charAt(i);
        return r == 0;
    }

    private static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8).replace("+", "%20"); }

    static String base32(byte[] data) {
        StringBuilder sb = new StringBuilder();
        int buf = 0, bits = 0;
        for (byte b : data) {
            buf = (buf << 8) | (b & 0xff); bits += 8;
            while (bits >= 5) { sb.append(B32.charAt((buf >> (bits - 5)) & 31)); bits -= 5; }
        }
        if (bits > 0) sb.append(B32.charAt((buf << (5 - bits)) & 31));
        return sb.toString();
    }

    static byte[] unbase32(String s) {
        s = s.replace("=", "").replace(" ", "").toUpperCase();
        byte[] out = new byte[s.length() * 5 / 8];
        int buf = 0, bits = 0, idx = 0;
        for (char c : s.toCharArray()) {
            int v = B32.indexOf(c);
            if (v < 0) continue;
            buf = (buf << 5) | v; bits += 5;
            if (bits >= 8) { out[idx++] = (byte) ((buf >> (bits - 8)) & 0xff); bits -= 8; }
        }
        return out;
    }
}
