package uz.pdp.mini_blok_with_jakarta.utils;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.util.Map;

/** QR kodni server tomonda SVG ko'rinishida yaratadi (tashqi xizmatlarga ma'lumot yuborilmaydi). */
public final class QrUtils {
    private QrUtils() {}

    public static String svg(String text, int size) {
        try {
            BitMatrix m = new QRCodeWriter().encode(text, BarcodeFormat.QR_CODE, 0, 0,
                    Map.of(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M, EncodeHintType.MARGIN, 2));
            int n = m.getWidth();
            StringBuilder p = new StringBuilder();
            for (int y = 0; y < n; y++)
                for (int x = 0; x < n; x++)
                    if (m.get(x, y)) p.append('M').append(x).append(' ').append(y).append("h1v1h-1z");
            return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + size + "\" height=\"" + size + "\" viewBox=\"0 0 " + n + " " + n
                    + "\" shape-rendering=\"crispEdges\"><rect width=\"100%\" height=\"100%\" fill=\"#fff\"/><path fill=\"#0b0b14\" d=\"" + p + "\"/></svg>";
        } catch (Exception e) {
            return "";
        }
    }
}
