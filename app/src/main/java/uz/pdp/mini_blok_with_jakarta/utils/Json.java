package uz.pdp.mini_blok_with_jakarta.utils;

import java.util.Collection;
import java.util.Map;

/** Juda kichik JSON yozuvchi: Map, List, String, Number, Boolean, null va Object[] ni xavfsiz JSON ga aylantiradi. */
public final class Json {
    private Json() {}

    public static String of(Object o) {
        StringBuilder b = new StringBuilder();
        write(b, o);
        return b.toString();
    }

    @SuppressWarnings("unchecked")
    private static void write(StringBuilder b, Object o) {
        if (o == null) b.append("null");
        else if (o instanceof String s) b.append(JsonUtils.q(s));
        else if (o instanceof Boolean || o instanceof Integer || o instanceof Long || o instanceof Short) b.append(o);
        else if (o instanceof Number n) {
            double d = n.doubleValue();
            b.append(Double.isFinite(d) ? (d == Math.rint(d) && Math.abs(d) < 1e15 ? String.valueOf((long) d) : String.valueOf(d)) : "null");
        } else if (o instanceof Map<?, ?> m) {
            b.append('{');
            boolean first = true;
            for (Map.Entry<?, ?> e : m.entrySet()) {
                if (!first) b.append(',');
                first = false;
                b.append(JsonUtils.q(String.valueOf(e.getKey()))).append(':');
                write(b, e.getValue());
            }
            b.append('}');
        } else if (o instanceof Collection<?> c) {
            b.append('[');
            boolean first = true;
            for (Object x : c) { if (!first) b.append(','); first = false; write(b, x); }
            b.append(']');
        } else if (o instanceof Object[] a) {
            b.append('[');
            for (int i = 0; i < a.length; i++) { if (i > 0) b.append(','); write(b, a[i]); }
            b.append(']');
        } else b.append(JsonUtils.q(o.toString()));
    }
}
