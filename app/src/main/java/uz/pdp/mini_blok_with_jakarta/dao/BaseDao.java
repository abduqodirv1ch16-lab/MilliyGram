package uz.pdp.mini_blok_with_jakarta.dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.io.BufferedReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Function;

public abstract class BaseDao {
    private static final Map<String, String> DOTENV = loadDotEnv();
    private final static EntityManagerFactory emf = Persistence.createEntityManagerFactory("mini_blog", dbOverrides());

    /** Muhit o'zgaruvchisi, JVM property (-DKEY=VAL) yoki .env faylidan qiymatni o'qiydi. */
    public static String getConfig(String key) {
        String val = System.getenv(key);
        if (val != null && !val.isBlank()) return val.trim();
        val = System.getProperty(key);
        if (val != null && !val.isBlank()) return val.trim();
        return DOTENV.get(key);
    }

    private static Map<String, String> loadDotEnv() {
        Map<String, String> map = new HashMap<>();
        List<Path> candidates = List.of(
                Paths.get(".env"),
                Paths.get("app", ".env"),
                Paths.get(System.getProperty("user.home", "."), ".milliygram.env")
        );
        for (Path p : candidates) {
            if (Files.isRegularFile(p)) {
                try (BufferedReader br = Files.newBufferedReader(p, StandardCharsets.UTF_8)) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        if (line.isEmpty() || line.startsWith("#") || !line.contains("=")) continue;
                        int idx = line.indexOf('=');
                        String k = line.substring(0, idx).trim();
                        String v = line.substring(idx + 1).trim();
                        if ((v.startsWith("\"") && v.endsWith("\"")) || (v.startsWith("'") && v.endsWith("'"))) {
                            v = v.substring(1, v.length() - 1);
                        }
                        if (!k.isEmpty() && !v.isEmpty()) map.putIfAbsent(k, v);
                    }
                } catch (Exception ignored) {}
            }
        }
        return map;
    }

    /** Serverda va kompyuterda baza sozlamalari muhit o'zgaruvchilari yoki .env faylidan olinadi (DB_URL, DB_USER, DB_PASSWORD). */
    private static Map<String, Object> dbOverrides() {
        Map<String, Object> m = new HashMap<>();
        String url = getConfig("DB_URL"), user = getConfig("DB_USER"), pass = getConfig("DB_PASSWORD");
        if (url != null && !url.isBlank()) m.put("jakarta.persistence.jdbc.url", url);
        if (user != null && !user.isBlank()) m.put("jakarta.persistence.jdbc.user", user);
        if (pass != null && !pass.isBlank()) m.put("jakarta.persistence.jdbc.password", pass);
        return m;
    }

    public EntityManager getEm(){
        return emf.createEntityManager();
    }

    protected void executeInTransaction(Consumer<EntityManager> action){
        EntityManager em = getEm();
        try {
            em.getTransaction().begin();
            action.accept(em);
            em.getTransaction().commit();
        }catch (Exception e){
            if(em.getTransaction().isActive()){
                em.getTransaction().rollback();
            }
            throw new RuntimeException("DB operatsiyasida xatolik: "+e.getMessage(),e);
        }finally {
            em.close();
        }
    }

    protected <T> T execute(Function<EntityManager,T> function){
        try (EntityManager em = getEm()) {
            return function.apply(em);
        }
    }
}
