package uz.pdp.mini_blok_with_jakarta.security;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** IP bo'yicha xato urinishlarni sanaydi: oyna ichida chegaradan oshsa, vaqtincha bloklaydi. */
public final class LoginThrottle {
    private final int max;
    private final long windowMs;
    private final Map<String, long[]> map = new ConcurrentHashMap<>();   // [count, windowStart]

    public LoginThrottle(int max, long windowMs) { this.max = max; this.windowMs = windowMs; }

    public boolean isBlocked(String key) {
        long[] v = map.get(key);
        if (v == null) return false;
        if (System.currentTimeMillis() - v[1] > windowMs) { map.remove(key); return false; }
        return v[0] >= max;
    }

    public void fail(String key) {
        long now = System.currentTimeMillis();
        map.compute(key, (k, v) -> (v == null || now - v[1] > windowMs) ? new long[]{1, now} : new long[]{v[0] + 1, v[1]});
        if (map.size() > 50_000) map.clear();   // xotirani himoyalash
    }

    public void reset(String key) { map.remove(key); }
}
