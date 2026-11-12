<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<jsp:include page="/fragments/css.jsp"/>
<script>
    /* =====================================================================
       MilliyGram — tema (light/dark) va fon rasmlari (wallpaper).
       Bu skript <head> ichida ishlaydi, shuning uchun sahifa "yilt" etmaydi.
       Tanlov brauzerda saqlanadi (localStorage: mg_prefs).
       DIQQAT: JSP ichida bo'lgani uchun bu yerda dollar+figurali qavs ishlatilmagan.
       ===================================================================== */
    (function () {
        var MG = window.MG = window.MG || {};

        function load() { try { return JSON.parse(localStorage.getItem('mg_prefs') || '{}') || {}; } catch (e) { return {}; } }
        function save(p) { try { localStorage.setItem('mg_prefs', JSON.stringify(p)); } catch (e) {} }

        /* ---------- Telegram uslubidagi naqshlar: SVG "doodle" plitkasi ---------- */
        var M = {
            star: 'M12 2l2.9 6.3 6.9.7-5.2 4.6 1.5 6.8L12 17l-6.1 3.4 1.5-6.8L2.2 9l6.9-.7z',
            heart: 'M12 21s-7-4.6-9.3-9A5.3 5.3 0 0 1 12 6.3 5.3 5.3 0 0 1 21.3 12C19 16.4 12 21 12 21z',
            moon: 'M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z',
            plane: 'M3 11l18-8-8 18-2-8-8-2z',
            leaf: 'M5 19C5 9 11 4 20 4c0 9-5 15-15 15zM5 19l8-8',
            wave: 'M2 12c3-4 5-4 8 0s5 4 8 0 4-3 4-3',
            bolt: 'M13 2L4 14h7l-1 8 9-12h-7z',
            diamond: 'M12 3l9 9-9 9-9-9z',
            cloud: 'M7 18a4 4 0 0 1-.5-8A6 6 0 0 1 18 9a4.5 4.5 0 0 1 0 9z',
            ring: 'M12 6a6 6 0 1 0 0 12 6 6 0 1 0 0-12z',
            flower: 'M12 9a3 3 0 1 0 0 6 3 3 0 1 0 0-6zM12 3c2 0 3 2 0 6-3-4-2-6 0-6zM21 12c0 2-2 3-6 0 4-3 6-2 6 0zM12 21c-2 0-3-2 0-6 3 4 2 6 0 6zM3 12c0-2 2-3 6 0-4 3-6 2-6 0z'
        };
        var POS = [[10, 12, -12, 1.2], [84, 6, 18, 1], [138, 34, -8, 1.15], [38, 68, 24, 1.1],
            [106, 82, -20, 1.3], [8, 126, 10, 1.1], [70, 138, -14, 1], [136, 136, 22, 1.2]];

        function tile(motifs, color, op) {
            var g = '';
            for (var i = 0; i < POS.length; i++) {
                var p = POS[i];
                g += '<g transform="translate(' + p[0] + ' ' + p[1] + ') rotate(' + p[2] + ' 12 12) scale(' + p[3] + ')"><path d="' + M[motifs[i % motifs.length]] + '"/></g>';
            }
            var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180" viewBox="0 0 180 180">' +
                '<g fill="none" stroke="' + color + '" stroke-opacity="' + op + '" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' + g + '</g></svg>';
            return 'url("data:image/svg+xml,' + encodeURIComponent(svg) + '")';
        }

        function mk(id, name, theme, grad, motifs, color, op) {
            var t = tile(motifs, color, op);
            return {
                id: id, name: name, theme: theme,
                body: t + ' 0 0/180px 180px repeat fixed, ' + grad + ' fixed',
                area: t + ' 0 0/180px 180px repeat, ' + grad,
                preview: t + ' 0 0/90px 90px repeat, ' + grad
            };
        }

        MG.wallpapers = [
            {id: 'white', name: 'Oq (standart)', theme: 'light', body: '#ffffff', area: '#f4f5fa', preview: '#ffffff'},
            {id: 'black', name: 'Qora (standart)', theme: 'dark', body: '#05060b', area: '#0d0f1a', preview: '#05060b'},
            mk('dawn', 'Shafaq', 'light', 'linear-gradient(160deg,#ffd3a5 0%,#fd9aa8 50%,#c9a6ff 100%)', ['star', 'heart', 'ring', 'cloud', 'plane', 'flower'], '#ffffff', 0.55),
            mk('ocean', 'Okean', 'light', 'linear-gradient(160deg,#b7f0ee 0%,#78b8f7 55%,#6f86f7 100%)', ['wave', 'ring', 'cloud', 'star', 'wave', 'plane'], '#ffffff', 0.55),
            mk('spring', 'Bahor', 'light', 'linear-gradient(160deg,#e6fbb0 0%,#a6e8a8 50%,#8fe3d0 100%)', ['leaf', 'flower', 'ring', 'leaf', 'heart', 'star'], '#ffffff', 0.6),
            mk('night', 'Tungi osmon', 'dark', 'linear-gradient(160deg,#0f2027 0%,#203a43 55%,#2c5364 100%)', ['star', 'moon', 'ring', 'star', 'cloud', 'diamond'], '#ffffff', 0.16),
            mk('violet', 'Binafsha tun', 'dark', 'linear-gradient(160deg,#1b1038 0%,#3a1c71 55%,#5b2a86 100%)', ['heart', 'bolt', 'star', 'plane', 'moon', 'flower'], '#ffffff', 0.15),
            mk('onyx', 'Qora olmos', 'dark', 'linear-gradient(160deg,#07070d 0%,#14141f 55%,#1d1d2e 100%)', ['diamond', 'ring', 'diamond', 'bolt', 'wave', 'star'], '#ffffff', 0.1)
        ];

        var styleEl = document.createElement('style');
        styleEl.id = 'mgWpStyle';
        document.head.appendChild(styleEl);

        MG.getPrefs = load;

        MG.setTheme = function (t, persist) {
            document.documentElement.setAttribute('data-theme', t === 'dark' ? 'dark' : 'light');
            if (persist !== false) { var p = load(); p.theme = t; save(p); }
            var ev; try { ev = new CustomEvent('mg-theme', {detail: t}); document.dispatchEvent(ev); } catch (e) {}
        };

        MG.applyWallpaper = function (id, persist) {
            var w = null, i;
            for (i = 0; i < MG.wallpapers.length; i++) if (MG.wallpapers[i].id === id) w = MG.wallpapers[i];
            styleEl.textContent = w ? 'html body{background:' + w.body + ' !important}.scrollable-main-area{background:' + w.area + ' !important}' : '';
            if (persist !== false) {
                var p = load();
                if (w) p.wp = id; else delete p.wp;
                save(p);
                if (w) MG.setTheme(w.theme);   // qorong'u fon -> qorong'u tema, yorqin fon -> yorug' tema
            }
        };

        var prefs = load();
        MG.setTheme(prefs.theme || 'light', false);
        if (prefs.wp) MG.applyWallpaper(prefs.wp, false);
    })();
</script>
