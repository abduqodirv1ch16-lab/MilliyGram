package uz.pdp.mini_blok_with_jakarta.security;

import java.util.Collection;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Xotirada saqlanadigan tezkor ro'yxatlar: bloklangan va tasdiqlangan foydalanuvchilar.
 * Har bir so'rovda bazaga murojaat qilmaslik uchun. Ilova ishga tushganda va admin o'zgartirganda yangilanadi.
 */
public final class UserFlags {
    private static final Set<Integer> BLOCKED = ConcurrentHashMap.newKeySet();
    private static final Set<Integer> VERIFIED = ConcurrentHashMap.newKeySet();
    private UserFlags() {}

    public static void loadBlocked(Collection<Integer> ids) { BLOCKED.clear(); BLOCKED.addAll(ids); }
    public static void loadVerified(Collection<Integer> ids) { VERIFIED.clear(); VERIFIED.addAll(ids); }
    public static boolean isBlocked(Integer id) { return id != null && BLOCKED.contains(id); }
    public static boolean isVerified(Integer id) { return id != null && VERIFIED.contains(id); }
    public static void setBlocked(Integer id, boolean b) { if (b) BLOCKED.add(id); else BLOCKED.remove(id); }
    public static void setVerified(Integer id, boolean v) { if (v) VERIFIED.add(id); else VERIFIED.remove(id); }
    public static void forget(Integer id) { BLOCKED.remove(id); VERIFIED.remove(id); }
}
