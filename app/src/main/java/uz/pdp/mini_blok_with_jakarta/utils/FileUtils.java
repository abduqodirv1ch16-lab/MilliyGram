package uz.pdp.mini_blok_with_jakarta.utils;

import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

public class FileUtils {
    public static final String UPLOAD_DIR = System.getProperty("user.home") + File.separator + "mini_blog_uploads";

    /** Faqat shu turdagi fayllarni yuklashga ruxsat (kengaytma -> MIME turi). */
    public static final Map<String, String> ALLOWED = Map.ofEntries(
            Map.entry(".jpg", "image/jpeg"), Map.entry(".jpeg", "image/jpeg"),
            Map.entry(".png", "image/png"), Map.entry(".gif", "image/gif"),
            Map.entry(".webp", "image/webp"), Map.entry(".heic", "image/heic"),
            Map.entry(".mp4", "video/mp4"), Map.entry(".webm", "video/webm"),
            Map.entry(".mov", "video/quicktime"), Map.entry(".m4v", "video/mp4"),
            Map.entry(".mp3", "audio/mpeg"), Map.entry(".ogg", "audio/ogg"),
            Map.entry(".oga", "audio/ogg"), Map.entry(".opus", "audio/ogg"),
            Map.entry(".wav", "audio/wav"), Map.entry(".m4a", "audio/mp4"),
            Map.entry(".aac", "audio/aac")
    );

    /** Saqlangan fayl nomi: UUID + ruxsat etilgan kengaytma. Boshqa hech narsa qabul qilinmaydi. */
    private static final Pattern SAFE_NAME = Pattern.compile("^[0-9a-fA-F\\-]{36}\\.[a-z0-9]{2,5}$");

    static {
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    public static String uploadFile(Part part) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String submitted = part.getSubmittedFileName();
        String originalFilename = submitted == null ? "" : Paths.get(submitted).getFileName().toString();
        String extension = "";
        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = originalFilename.substring(dotIndex).toLowerCase(Locale.ROOT);
        }
        if (!ALLOWED.containsKey(extension)) {
            // brauzer yozib olgan ovoz/video blob'larida nom bo'lmasligi mumkin — MIME bo'yicha aniqlaymiz
            extension = extensionFromMime(part.getContentType());
        }
        if (extension == null) {
            throw new IllegalArgumentException("Faqat rasm, video yoki audio fayl yuklash mumkin");
        }
        String uniqueFileName = UUID.randomUUID() + extension;
        Path targetPath = Paths.get(UPLOAD_DIR, uniqueFileName);

        Files.copy(part.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
        return uniqueFileName;
    }

    private static String extensionFromMime(String mime) {
        if (mime == null) return null;
        String m = mime.toLowerCase(Locale.ROOT).split(";")[0].trim();
        return switch (m) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/gif" -> ".gif";
            case "image/webp" -> ".webp";
            case "video/mp4" -> ".mp4";
            case "video/webm" -> ".webm";
            case "video/quicktime" -> ".mov";
            case "audio/webm" -> ".webm";
            case "audio/ogg" -> ".ogg";
            case "audio/mpeg" -> ".mp3";
            case "audio/wav", "audio/x-wav" -> ".wav";
            case "audio/mp4", "audio/x-m4a" -> ".m4a";
            case "audio/aac" -> ".aac";
            default -> null;
        };
    }

    /** Fayl nomi xavfsizmi (../ kabi yo'llar bo'lmasligi kerak). Xavfsiz bo'lsa faylni qaytaradi, aks holda null. */
    public static File resolveSafe(String name) {
        if (name == null || !SAFE_NAME.matcher(name).matches()) return null;
        File dir = new File(UPLOAD_DIR);
        File f = new File(dir, name);
        try {
            if (!f.getCanonicalFile().getParentFile().equals(dir.getCanonicalFile())) return null;
        } catch (IOException e) {
            return null;
        }
        return f;
    }

    public static String mimeOf(String name) {
        int dot = name.lastIndexOf('.');
        String ext = dot >= 0 ? name.substring(dot).toLowerCase(Locale.ROOT) : "";
        return ALLOWED.getOrDefault(ext, "application/octet-stream");
    }
}
