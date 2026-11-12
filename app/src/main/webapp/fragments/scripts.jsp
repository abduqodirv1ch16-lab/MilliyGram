<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/fragments/modals.jsp"/>
<script>
    /* =====================================================================
       MilliyGram — yagona frontend skripti (hamma sahifada ishlaydi)
       Tarkib:  1 Yordamchilar   2 Oynalar (modal/confirm/prompt)   3 Yon panel + Followers/Following
                4 Settings (tema, fon, parol)   5 Bildirishnomalar   6 Qidiruv
                7 Post amallari (like/save/share/menyu/view)   8 Post oynasi + izohlar
                9 Stories   10 Video kesish (3 soniya)   11 Ishga tushirish
       DIQQAT: JSP ichida bo'lgani uchun bu yerda dollar+figurali qavs va shablon satrlar (backtick) ishlatilmagan.
       ===================================================================== */
    var CONTEXT_PATH = '${pageContext.request.contextPath}';
    var CURRENT_USER_ID = '${sessionScope.id}';
    var API = CONTEXT_PATH + '/api';
    var DEFAULT_AVATAR = "data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E";
    var ME = null;
    window.MG = window.MG || {};

    /* ------------------------------------------------------------------ 1. Yordamchilar */
    function el(tag, cls, text) {
        var e = document.createElement(tag);
        if (cls) e.className = cls;
        if (text !== undefined && text !== null) e.textContent = text;
        return e;
    }
    function $id(x) { return document.getElementById(x); }
    /* Tasdiqlangan belgi (admin beradi) */
    function vBadge() {
        var s = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        s.setAttribute('viewBox', '0 0 24 24'); s.setAttribute('class', 'mg-verified'); s.setAttribute('aria-label', 'Tasdiqlangan akkaunt');
        s.innerHTML = '<path fill="#3b9bff" d="M12 1.8l2.6 1.9 3.2-.2 1 3 2.6 1.9-1 3.1 1 3.1-2.6 1.9-1 3-3.2-.2L12 22.2l-2.6-1.9-3.2.2-1-3-2.6-1.9 1-3.1-1-3.1 2.6-1.9 1-3 3.2.2z"/><path stroke="#fff" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round" d="M8 12.2l2.7 2.7L16.2 9.4"/>';
        return s;
    }
    MG.vBadge = vBadge;
    function mediaSrc(name) { return CONTEXT_PATH + '/download?name=' + encodeURIComponent(name); }
    function resolveAvatar(av) {
        if (!av || av === 'null' || String(av).trim() === '') return DEFAULT_AVATAR;
        if (/^(https?:|data:|blob:)/.test(av)) return av;
        return mediaSrc(av);
    }
    function isVideoName(n) { return /\.(mp4|webm|mov|m4v|ogv|mkv|3gp)$/i.test(String(n || '').split('?')[0]); }
    function lsGet(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }
    function lsSet(k, v) { try { localStorage.setItem(k, v); } catch (e) {} }
    function onReady(fn) { if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn); else fn(); }

    function showToast(msg, type) {
        var c = $id('mgToastContainer');
        if (!c) { c = el('div', 'mg-toast-container'); c.id = 'mgToastContainer'; document.body.appendChild(c); }
        var t = el('div', 'mg-toast ' + (type === 'error' ? 'is-error' : 'is-success'), msg);
        c.appendChild(t);
        setTimeout(function () { t.remove(); }, 3200);
    }

    function copyText(t) {
        if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(t);
        return new Promise(function (res, rej) {
            var ta = document.createElement('textarea');
            ta.value = t; document.body.appendChild(ta); ta.select();
            try { document.execCommand('copy'); res(); } catch (e) { rej(e); }
            ta.remove();
        });
    }

    /* so'rovlar */
    function postJSON(url, params) {          // mavjud servletlar uchun (/post/like, /user/follow ...)
        return fetch(url, {
            method: 'POST', credentials: 'same-origin',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams(params).toString()
        }).then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r; });
    }
    function jsonOrThrow(r) {
        if (r.redirected && /\/login/.test(r.url)) { location.href = CONTEXT_PATH + '/login'; throw new Error('Tizimga kiring'); }
        return r.text().then(function (t) {
            var d = null;
            try { d = t ? JSON.parse(t) : null; } catch (e) {}
            if (!r.ok) {
                var er = new Error(d && d.error ? d.error : 'Xatolik (' + r.status + ')');
                er.status = r.status; throw er;
            }
            return d;
        });
    }
    function api(path) { return fetch(API + path, {credentials: 'same-origin', cache: 'no-store'}).then(jsonOrThrow); }
    function apiPost(path, params) {
        return fetch(API + path, {
            method: 'POST', credentials: 'same-origin',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams(params || {}).toString()
        }).then(jsonOrThrow);
    }
    function apiForm(path, fd) { return fetch(API + path, {method: 'POST', body: fd, credentials: 'same-origin'}).then(jsonOrThrow); }

    /* vaqt: server LocalDateTime ("2026-10-22T14:13:05.123456") ni brauzer vaqtida o'qiymiz */
    var WD = ['Yakshanba', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'];
    var MON = ['yan', 'fev', 'mar', 'apr', 'may', 'iyn', 'iyl', 'avg', 'sen', 'okt', 'noy', 'dek'];
    function parseTime(s) {
        if (!s) return null;
        var d = new Date(String(s).replace(' ', 'T').replace(/(\.\d{3})\d+/, '$1'));
        return isNaN(d.getTime()) ? null : d;
    }
    function pad2(n) { return n < 10 ? '0' + n : '' + n; }
    /* Izoh / bildirishnoma: 1 kun ichida soat, 1 hafta ichida hafta kuni, undan keyin sana */
    function shortTime(s) {
        var d = parseTime(s); if (!d) return '';
        var diff = Math.max(0, (Date.now() - d.getTime()) / 1000);
        if (diff < 60) return 'hozir';
        if (diff < 3600) return Math.floor(diff / 60) + ' daq';
        if (diff < 86400) return Math.floor(diff / 3600) + ' soat';
        if (diff < 7 * 86400) return WD[d.getDay()];
        var t = d.getDate() + ' ' + MON[d.getMonth()];
        return d.getFullYear() === new Date().getFullYear() ? t : t + ' ' + d.getFullYear();
    }
    /* Post: "5 daqiqa oldin", "3 soat oldin", "2 kun oldin" */
    function agoTime(s) {
        var d = parseTime(s); if (!d) return '';
        var diff = Math.max(0, (Date.now() - d.getTime()) / 1000);
        if (diff < 60) return 'hozirgina';
        if (diff < 3600) return Math.floor(diff / 60) + ' daqiqa oldin';
        if (diff < 86400) return Math.floor(diff / 3600) + ' soat oldin';
        if (diff < 7 * 86400) return Math.floor(diff / 86400) + ' kun oldin';
        return fullTime(s);
    }
    function fullTime(s) {
        var d = parseTime(s); if (!d) return '';
        return d.getDate() + ' ' + MON[d.getMonth()] + ' ' + d.getFullYear() + ', ' + pad2(d.getHours()) + ':' + pad2(d.getMinutes());
    }
    /* post vaqti va ko'rishlar soni: /api/postmeta (DTO ga bog'lanmaslik uchun) */
    function loadPostMeta() {
        var ids = [];
        document.querySelectorAll('.js-post').forEach(function (p) { ids.push(p.dataset.postId); });
        if (!ids.length) return;
        api('/postmeta?ids=' + ids.join(',')).then(function (m) {
            document.querySelectorAll('.js-post').forEach(function (p) {
                var x = m[p.dataset.postId]; if (!x) return;
                p.dataset.created = x.createdAt || '';
                setViews(p.dataset.postId, x.views || 0);
            });
            refreshTimes();
        }).catch(function () {});
    }
    function refreshTimes() {
        document.querySelectorAll('.js-post').forEach(function (p) {
            var c = p.dataset.created; if (!c) return;
            var full = p.querySelector('.js-post-time'); if (full) full.textContent = fullTime(c);
            var top = p.querySelector('.js-post-time-top'); if (top) top.textContent = agoTime(c);
        });
    }

    /* ------------------------------------------------------------------ 2. Oynalar */
    function mgModal(title, bodyNode, buttons, opts) {
        var ov = el('div', 'mg-modal-overlay');
        var m = el('div', 'mg-modal' + (opts && opts.wide ? ' wide' : ''));
        var head = el('div', 'mg-modal-head');
        head.appendChild(el('span', null, title));
        var x = el('button', 'icon-btn'); x.type = 'button'; x.innerHTML = '<i class="fa-solid fa-xmark"></i>';
        head.appendChild(x);
        var body = el('div', 'mg-modal-body'); if (bodyNode) body.appendChild(bodyNode);
        m.appendChild(head); m.appendChild(body);
        var api2 = {overlay: ov, body: body, buttons: {}};
        api2.close = function () { ov.remove(); if (opts && opts.onClose) opts.onClose(); };
        x.onclick = api2.close;
        ov.addEventListener('mousedown', function (e) { if (e.target === ov) api2.close(); });
        if (buttons && buttons.length) {
            var foot = el('div', 'mg-modal-foot');
            buttons.forEach(function (b) {
                var btn = el('button', 'btn ' + (b.cls || 'btn-ghost'), b.text); btn.type = 'button';
                btn.onclick = function () { b.onClick(api2, btn); };
                foot.appendChild(btn); if (b.key) api2.buttons[b.key] = btn;
            });
            m.appendChild(foot);
        }
        ov.appendChild(m);
        document.body.appendChild(ov);
        return api2;
    }
    function mgConfirm(message, okText, danger) {
        return new Promise(function (resolve) {
            var done = false;
            function fin(v, md) { if (done) return; done = true; md.close(); resolve(v); }
            var p = el('p', null, message); p.style.cssText = 'margin:0;font-size:14px;line-height:1.5;';
            mgModal('Tasdiqlang', p, [
                {text: 'Bekor qilish', onClick: function (md) { fin(false, md); }},
                {text: okText || 'Ha', cls: danger ? 'btn-danger' : 'btn-primary', onClick: function (md) { fin(true, md); }}
            ], {onClose: function () { if (!done) { done = true; resolve(false); } }});
        });
    }
    function mgPrompt(title, value, placeholder) {
        return new Promise(function (resolve) {
            var done = false;
            var inp = el('textarea', 'form-control'); inp.rows = 3; inp.value = value || ''; inp.placeholder = placeholder || '';
            function fin(v, md) { if (done) return; done = true; md.close(); resolve(v); }
            var md = mgModal(title, inp, [
                {text: 'Bekor qilish', onClick: function (m) { fin(null, m); }},
                {text: 'Saqlash', cls: 'btn-primary', onClick: function (m) { fin(inp.value.trim(), m); }}
            ], {onClose: function () { if (!done) { done = true; resolve(null); } }});
            setTimeout(function () { inp.focus(); }, 60);
        });
    }

    /* ------------------------------------------------------------------ 3. Yon panel + Followers / Following */
    function fillMe(u) {
        if (!u) return;
        ME = u;
        var av = document.querySelector('.sidebar-avatar'); if (av) av.src = resolveAvatar(u.avatar);
        var nm = document.querySelector('.sidebar-name'); if (nm) nm.textContent = u.fullName || u.username;
        var hd = document.querySelector('.sidebar-handle'); if (hd) hd.textContent = '@' + u.username;
        ['posts', 'followers', 'following'].forEach(function (k) {
            document.querySelectorAll('[data-stat="' + k + '"]').forEach(function (n) { n.textContent = u[k]; });
        });
    }
    function refreshMe() {
        return api('/user').then(function (u) {
            try { sessionStorage.setItem('mg_me', JSON.stringify(u)); } catch (e) {}
            fillMe(u); return u;
        }).catch(function () {});
    }

    var flState = {type: null, userId: null, items: []};
    function openFollowList(type, userId) {
        var panel = $id('sbListPanel'); if (!panel) return;
        flState.type = type; flState.userId = String(userId || CURRENT_USER_ID); flState.items = [];
        $id('sbListTitle').textContent = type === 'followers' ? 'Followers' : 'Following';
        $id('sbListSearch').value = '';
        var body = $id('sbListBody'); body.innerHTML = '';
        body.appendChild(el('div', 'text-muted small text-center p-4', 'Yuklanmoqda...'));
        panel.classList.add('open'); panel.setAttribute('aria-hidden', 'false');
        api('/follows?type=' + type + '&userId=' + encodeURIComponent(flState.userId)).then(function (list) {
            flState.items = Array.isArray(list) ? list : [];
            renderFollowList();
        }).catch(function () { body.innerHTML = ''; body.appendChild(el('div', 'text-muted small text-center p-4', 'Ro‘yxatni yuklab bo‘lmadi')); });
    }
    function closeFollowList() {
        var panel = $id('sbListPanel'); if (!panel) return;
        panel.classList.remove('open'); panel.setAttribute('aria-hidden', 'true');
    }
    function setFollowBtn(btn, following, ownFollowing) {
        btn.textContent = following ? (ownFollowing ? 'Unfollow' : 'Following') : 'Follow';
        btn.className = 'fl-btn' + (following ? '' : ' primary');
    }
    function renderFollowList() {
        var body = $id('sbListBody'); body.innerHTML = '';
        var q = $id('sbListSearch').value.trim().toLowerCase();
        var mine = flState.userId === String(CURRENT_USER_ID);
        var items = flState.items.filter(function (u) {
            return !q || (u.username || '').toLowerCase().indexOf(q) >= 0 || (u.fullName || '').toLowerCase().indexOf(q) >= 0;
        });
        if (!items.length) {
            body.appendChild(el('div', 'text-muted small text-center p-4', q ? 'Hech narsa topilmadi' : (flState.type === 'followers' ? 'Hozircha followerlar yo‘q' : 'Hozircha hech kimni kuzatmayapsiz')));
            return;
        }
        items.forEach(function (u) {
            var row = el('div', 'fl-row');
            var link = el('a'); link.href = CONTEXT_PATH + '/user/profile?id=' + u.id;
            var img = el('img', 'fl-avatar'); img.src = resolveAvatar(u.avatar); img.alt = '';
            link.appendChild(img);
            var info = el('a', 'fl-info'); info.href = link.href;
            var fln = el('div', 'fl-name text-truncate', u.username); if (u.verified) fln.appendChild(vBadge());
            info.appendChild(fln);
            info.appendChild(el('div', 'fl-sub text-truncate', u.fullName || ''));
            row.appendChild(link); row.appendChild(info);
            if (!u.isMe) {
                var btn = el('button'); btn.type = 'button';
                if (mine && flState.type === 'followers') {
                    btn.className = 'fl-btn'; btn.textContent = 'Remove';
                    btn.onclick = function () {
                        mgConfirm('@' + u.username + ' ni followerlaringiz ro‘yxatidan olib tashlaysizmi?', 'Remove', true).then(function (ok) {
                            if (!ok) return;
                            apiPost('/follow/remove', {followerId: u.id}).then(function () {
                                flState.items = flState.items.filter(function (x) { return x.id !== u.id; });
                                renderFollowList(); refreshMe(); showToast('Follower olib tashlandi');
                            }).catch(function (e) { showToast(e.message, 'error'); });
                        });
                    };
                } else {
                    var own = mine && flState.type === 'following';
                    setFollowBtn(btn, u.iFollow, own);
                    btn.onclick = function () {
                        btn.disabled = true;
                        postJSON(CONTEXT_PATH + '/user/follow', {targetUserId: u.id})
                            .then(function (r) { return r.json(); })
                            .then(function (d) {
                                u.iFollow = d.following; setFollowBtn(btn, d.following, own); btn.disabled = false; refreshMe();
                            }).catch(function () { btn.disabled = false; showToast('Bajarilmadi', 'error'); });
                    };
                }
                row.appendChild(btn);
            }
            body.appendChild(row);
        });
    }
    function initSidebar() {
        if (!$id('mgSidebar')) return;
        try { var c = sessionStorage.getItem('mg_me'); if (c) fillMe(JSON.parse(c)); } catch (e) {}
        refreshMe();
        document.querySelectorAll('[data-stat-list]').forEach(function (b) {
            b.addEventListener('click', function () { openFollowList(b.getAttribute('data-stat-list'), CURRENT_USER_ID); });
        });
        $id('sbListBack').onclick = closeFollowList;
        $id('sbListSearch').addEventListener('input', renderFollowList);
    }

    /* ------------------------------------------------------------------ 4. Settings: tema, fon rasmi, parol */
    function initSettings() {
        var btn = $id('settingsBtn'), pop = $id('settingsPop');
        if (!btn || !pop) return;
        function layout() {
            var sr = $id('mgSidebar').getBoundingClientRect(), br = btn.getBoundingClientRect();
            var pr = $id('mgNavProfile').getBoundingClientRect();
            pop.style.bottom = (sr.bottom - br.top + 10) + 'px';
            pop.style.maxHeight = Math.max(140, br.top - pr.bottom - 22) + 'px';   // "Profile" yozuviga yetmasdan to'xtaydi
        }
        function setOpen(v) {
            if (v) layout();
            pop.classList.toggle('open', v); btn.classList.toggle('open', v);
            btn.setAttribute('aria-expanded', v ? 'true' : 'false');
        }
        btn.addEventListener('click', function (e) { e.stopPropagation(); setOpen(!pop.classList.contains('open')); });
        document.addEventListener('click', function (e) { if (!pop.contains(e.target) && !btn.contains(e.target)) setOpen(false); });
        window.addEventListener('resize', function () { if (pop.classList.contains('open')) layout(); });

        function syncTheme() {
            var dark = document.documentElement.getAttribute('data-theme') === 'dark';
            $id('spThemeLabel').textContent = dark ? 'Yorug‘ rejim' : 'Qorong‘u rejim';
            $id('spThemeIcon').className = 'fa-solid ' + (dark ? 'fa-sun' : 'fa-moon');
        }
        syncTheme();
        document.addEventListener('mg-theme', syncTheme);
        $id('spTheme').addEventListener('click', function () {
            MG.setTheme(document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
        });
        $id('spWallpaper').addEventListener('click', function () { setOpen(false); openWallpaperView(); });
        $id('spPassword').addEventListener('click', function () { setOpen(false); openPasswordModal(); });
    }

    function openWallpaperView() {
        var host = document.querySelector('.dashboard-content');
        if (!host || host.querySelector('.wp-view')) return;
        var view = el('div', 'wp-view');
        var head = el('div', 'wp-head');
        var ttl = el('div'); ttl.innerHTML = '<h3>Fon rasmi</h3><small>Tanlangan fon butun saytga qo‘llanadi</small>';
        var x = el('button', 'icon-btn'); x.type = 'button'; x.innerHTML = '<i class="fa-solid fa-xmark"></i>';
        x.onclick = function () { view.remove(); };
        head.appendChild(ttl); head.appendChild(x);
        var body = el('div', 'wp-body');
        var current = MG.getPrefs().wp || '';
        var groups = [
            ['Standart', ['white', 'black']],
            ['Yorqin fonlar', ['dawn', 'ocean', 'spring']],
            ['Qorong‘u fonlar', ['night', 'violet', 'onyx']]
        ];
        function byId(id) { for (var i = 0; i < MG.wallpapers.length; i++) if (MG.wallpapers[i].id === id) return MG.wallpapers[i]; return null; }
        var tiles = [];
        groups.forEach(function (g) {
            body.appendChild(el('div', 'wp-group', g[0]));
            var grid = el('div', 'wp-grid');
            g[1].forEach(function (id) {
                var w = byId(id); if (!w) return;
                var t = el('button', 'wp-tile' + (current === id ? ' sel' : '')); t.type = 'button'; t.title = w.name;
                var bg = el('div', 'wp-bg'); bg.style.background = w.preview;
                var msgs = el('div', 'wp-msgs'); msgs.innerHTML = '<i></i><i class="me"></i><i></i>';
                t.appendChild(bg); t.appendChild(msgs);
                t.appendChild(el('div', 'wp-name', w.name));
                var ck = el('div', 'wp-check'); ck.innerHTML = '<i class="fa-solid fa-check"></i>'; t.appendChild(ck);
                t.onclick = function () {
                    MG.applyWallpaper(id);
                    tiles.forEach(function (o) { o.classList.remove('sel'); });
                    t.classList.add('sel');
                    showToast('Fon o‘zgartirildi: ' + w.name);
                };
                tiles.push(t); grid.appendChild(t);
            });
            body.appendChild(grid);
        });
        var reset = el('button', 'btn btn-ghost', 'Asl holatga qaytarish'); reset.type = 'button';
        reset.onclick = function () { MG.applyWallpaper(''); tiles.forEach(function (o) { o.classList.remove('sel'); }); showToast('Asl fon qaytarildi'); };
        body.appendChild(reset);
        view.appendChild(head); view.appendChild(body);
        host.appendChild(view);
    }

    function pwField(label, id) {
        var f = el('div', 'mg-field');
        f.appendChild(el('label', null, label));
        var w = el('div', 'pw-wrap');
        var i = el('input', 'form-control'); i.type = 'password'; i.id = id; i.autocomplete = 'off';
        var eye = el('button', 'icon-btn pw-eye'); eye.type = 'button'; eye.tabIndex = -1; eye.innerHTML = '<i class="fa-regular fa-eye"></i>';
        eye.onclick = function () {
            var show = i.type === 'password'; i.type = show ? 'text' : 'password';
            eye.innerHTML = '<i class="fa-regular ' + (show ? 'fa-eye-slash' : 'fa-eye') + '"></i>';
        };
        w.appendChild(i); w.appendChild(eye); f.appendChild(w);
        return f;
    }
    function openPasswordModal() {
        var wrap = el('div');
        var err = el('div', 'mg-error'); err.style.display = 'none';
        wrap.appendChild(err);
        wrap.appendChild(pwField('Joriy parol', 'pwOld'));
        wrap.appendChild(pwField('Yangi parol', 'pwNew'));
        wrap.appendChild(pwField('Yangi parolni takrorlang', 'pwNew2'));
        function fail(m) { err.textContent = m; err.style.display = 'block'; }
        var md = mgModal('Parolni o‘zgartirish', wrap, [
            {text: 'Bekor qilish', onClick: function (m) { m.close(); }},
            {text: 'Saqlash', cls: 'btn-primary', key: 'save', onClick: function (m, btn) {
                    var o = $id('pwOld').value, n = $id('pwNew').value, n2 = $id('pwNew2').value;
                    err.style.display = 'none';
                    if (!o) return fail('Joriy parolni kiriting');
                    if (n.length < 6) return fail('Yangi parol kamida 6 belgidan iborat bo‘lsin');
                    if (n !== n2) return fail('Yangi parollar bir xil emas');
                    if (n === o) return fail('Yangi parol joriy paroldan farq qilsin');
                    btn.disabled = true;
                    apiPost('/password', {oldPassword: o, newPassword: n}).then(function () {
                        m.close(); showToast('Parol o‘zgartirildi');
                    }).catch(function (e) { btn.disabled = false; fail(e.message); });
                }}
        ]);
        setTimeout(function () { $id('pwOld').focus(); }, 60);
        return md;
    }

    /* ------------------------------------------------------------------ 5. Bildirishnomalar */
    var notifs = [];
    function notifSeenKey() { return 'mg_notif_seen_' + CURRENT_USER_ID; }
    function notifUnread() {
        var seen = lsGet(notifSeenKey()); var st = seen ? Number(seen) : 0;
        return notifs.filter(function (n) { var d = parseTime(n.createdAt); return d && d.getTime() > st; });
    }
    function updateBadge() {
        var cnt = notifUnread().length;
        document.querySelectorAll('.js-bell .badge').forEach(function (b) {
            b.textContent = cnt > 99 ? '99+' : cnt; b.style.display = cnt ? 'flex' : 'none';
        });
    }
    function loadNotifs() {
        if (!document.querySelector('.js-bell')) return Promise.resolve();
        return api('/notifications').then(function (l) { notifs = Array.isArray(l) ? l : []; updateBadge(); }).catch(function () {});
    }
    var NT_ICON = {LIKE: 'fa-heart', COMMENT: 'fa-comment', REPLY: 'fa-reply', FOLLOW: 'fa-user-plus'};
    function openNotifPanel(bell) {
        var old = document.querySelector('.notif-dropdown');
        if (old) { old.remove(); return; }
        var box = el('div', 'notif-dropdown');
        var r = bell.getBoundingClientRect();
        box.style.top = (r.bottom + 10) + 'px';
        box.style.left = Math.max(12, Math.min(window.innerWidth - 382, r.right - 370)) + 'px';
        var head = el('div', 'notif-head'); head.appendChild(el('span', null, 'Bildirishnomalar'));
        var list = el('div', 'notif-list');
        box.appendChild(head); box.appendChild(list);
        document.body.appendChild(box);
        function render() {
            var seen = Number(lsGet(notifSeenKey()) || 0);
            list.innerHTML = '';
            if (!notifs.length) { list.appendChild(el('div', 'nt-empty', 'Hozircha yangi bildirishnoma yo‘q.')); return; }
            notifs.forEach(function (n) {
                var d = parseTime(n.createdAt);
                var row = el('div', 'nt-row' + (d && d.getTime() > seen ? ' unread' : ''));
                var av = el('div', 'nt-av');
                var img = el('img'); img.src = resolveAvatar(n.avatar); img.alt = '';
                var tp = el('span', 'nt-type ' + n.type); tp.innerHTML = '<i class="fa-solid ' + (NT_ICON[n.type] || 'fa-bell') + '"></i>';
                av.appendChild(img); av.appendChild(tp);
                var tx = el('div', 'nt-text');
                tx.appendChild(el('b', null, n.username)); tx.appendChild(document.createTextNode(' ' + n.text));
                tx.appendChild(el('span', 'nt-time', shortTime(n.createdAt)));
                row.appendChild(av); row.appendChild(tx);
                if (n.mediaUrl && n.type !== 'FOLLOW') {
                    if (isVideoName(n.mediaUrl)) { var v = el('video', 'nt-thumb'); v.src = mediaSrc(n.mediaUrl) + '#t=0.1'; v.muted = true; v.preload = 'metadata'; row.appendChild(v); }
                    else { var t = el('img', 'nt-thumb'); t.src = mediaSrc(n.mediaUrl); t.alt = ''; row.appendChild(t); }
                }
                row.onclick = function () {
                    box.remove();
                    if (n.type === 'FOLLOW') location.href = CONTEXT_PATH + '/user/profile?id=' + n.userId;
                    else if (n.postId) { location.href = CONTEXT_PATH + '/#post-' + n.postId; if (location.pathname === CONTEXT_PATH + '/' || location.pathname === CONTEXT_PATH) highlightHash(); }
                };
                list.appendChild(row);
            });
        }
        render();
        loadNotifs().then(function () {
            var before = Number(lsGet(notifSeenKey()) || 0);
            render();
            if (notifs.length) {
                var newest = 0; notifs.forEach(function (n) { var d = parseTime(n.createdAt); if (d && d.getTime() > newest) newest = d.getTime(); });
                // yangilarni ko'rsatib bo'lgach "o'qilgan" deb belgilaymiz
                lsSet(notifSeenKey(), String(Math.max(before, newest)));
                updateBadge();
            }
        });
    }
    function initNotifications() {
        if (!document.querySelector('.js-bell')) return;
        loadNotifs();
        setInterval(function () { if (!document.hidden) loadNotifs(); }, 30000);
        document.addEventListener('click', function (e) {
            var bell = e.target.closest('.js-bell');
            var open = document.querySelector('.notif-dropdown');
            if (bell) { e.preventDefault(); openNotifPanel(bell); return; }
            if (open && !open.contains(e.target)) open.remove();
        });
    }

    /* ------------------------------------------------------------------ 6. Qidiruv */
    function initSearch() {
        var input = $id('userSearchInput'); if (!input) return;
        var dd = $id('userSearchDropdown');
        if (!dd) { dd = el('div', 'global-search-dropdown'); dd.id = 'userSearchDropdown'; input.parentNode.appendChild(dd); }
        var timer = null, firstId = null;
        input.addEventListener('input', function () {
            var q = input.value.trim();
            clearTimeout(timer);
            if (!q) { dd.style.display = 'none'; dd.innerHTML = ''; firstId = null; return; }
            timer = setTimeout(function () {
                fetch(CONTEXT_PATH + '/user/search?p=' + encodeURIComponent(q) + '&q=' + encodeURIComponent(q), {credentials: 'same-origin'})
                    .then(function (r) { return r.json(); })
                    .then(function (users) {
                        dd.innerHTML = ''; firstId = null;
                        users = (Array.isArray(users) ? users : []).filter(function (u) { return String(u.id) !== String(CURRENT_USER_ID); });
                        if (!users.length) { dd.appendChild(el('div', 'text-muted text-center small p-3', 'Foydalanuvchi topilmadi')); dd.style.display = 'block'; return; }
                        firstId = users[0].id;
                        users.forEach(function (u) {
                            var row = el('div', 'global-search-item');
                            var img = el('img'); img.src = resolveAvatar(u.avatar); img.alt = '';
                            img.style.cssText = 'width:38px;height:38px;border-radius:50%;object-fit:cover;flex-shrink:0;';
                            var info = el('div'); info.style.cssText = 'min-width:0;flex:1;';
                            var nm = el('div', 'text-truncate', u.fullName || u.username); nm.style.cssText = 'font-weight:600;font-size:13px;';
                            if (u.verified) nm.appendChild(vBadge());
                            var un = el('div', 'text-truncate', '@' + u.username); un.style.cssText = 'font-size:11px;color:var(--text-muted);';
                            info.appendChild(nm); info.appendChild(un);
                            row.appendChild(img); row.appendChild(info);
                            row.onclick = function () { location.href = CONTEXT_PATH + '/user/profile?id=' + u.id; };
                            dd.appendChild(row);
                        });
                        dd.style.display = 'block';
                    }).catch(function () { dd.style.display = 'none'; });
            }, 250);
        });
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && firstId) location.href = CONTEXT_PATH + '/user/profile?id=' + firstId;
            if (e.key === 'Escape') dd.style.display = 'none';
        });
        document.addEventListener('click', function (e) { if (!input.contains(e.target) && !dd.contains(e.target)) dd.style.display = 'none'; });
    }

    /* ------------------------------------------------------------------ 7. Post amallari */
    function getPostEl(id) { return document.querySelector('.js-post[data-post-id="' + id + '"]'); }
    function isPostLiked(id) { var p = getPostEl(id); return p ? p.dataset.liked === 'true' : false; }

    function syncPost(id, s) {
        var p = getPostEl(id);
        if (p) {
            if (s.liked !== undefined) p.dataset.liked = String(s.liked);
            if (s.likes !== undefined) p.dataset.likes = s.likes;
            if (s.saved !== undefined) p.dataset.saved = String(s.saved);
            if (s.comments !== undefined) p.dataset.comments = s.comments;
        }
        var q = '[data-post-id="' + id + '"]';
        if (s.liked !== undefined) {
            document.querySelectorAll('.js-like-btn' + q).forEach(function (b) {
                b.classList.toggle('liked', s.liked);
                var i = b.querySelector('i'); if (i) i.className = (s.liked ? 'fa-solid' : 'fa-regular') + ' fa-heart';
            });
        }
        if (s.likes !== undefined) {
            document.querySelectorAll('.js-like-count' + q).forEach(function (e) { e.textContent = s.likes + (Number(s.likes) === 1 ? ' like' : ' likes'); });
        }
        if (s.saved !== undefined) {
            document.querySelectorAll('.js-save-btn' + q).forEach(function (b) {
                var i = b.querySelector('i'); if (i) i.className = (s.saved ? 'fa-solid' : 'fa-regular') + ' fa-bookmark';
            });
        }
        if (s.comments !== undefined) {
            document.querySelectorAll('.js-comment-count' + q).forEach(function (e) { e.textContent = s.comments > 0 ? 'View all ' + s.comments + ' comments' : 'Add a comment'; });
        }
    }
    function setViews(id, n) {
        var p = getPostEl(id); if (p) p.dataset.views = n;
        document.querySelectorAll('.js-view-count[data-post-id="' + id + '"] b').forEach(function (b) { b.textContent = n; });
    }

    function toggleLike(id) {
        var p = getPostEl(id);
        var was = isPostLiked(id);
        var likes = p ? parseInt(p.dataset.likes || '0', 10) : 0;
        syncPost(id, {liked: !was, likes: Math.max(0, likes + (was ? -1 : 1))});
        postJSON(CONTEXT_PATH + '/post/like', {postId: id})
            .then(function (r) { return r.json(); })
            .then(function (d) { syncPost(id, {liked: d.liked, likes: d.count}); })
            .catch(function () { syncPost(id, {liked: was, likes: likes}); showToast('Like bajarilmadi', 'error'); });
    }

    function toggleSave(id) {
        var p = getPostEl(id);
        var was = p ? p.dataset.saved === 'true' : false;
        syncPost(id, {saved: !was});
        postJSON(CONTEXT_PATH + '/post/save', {postId: id})
            .then(function (r) { return r.json(); })
            .then(function (d) {
                syncPost(id, {saved: d.saved});
                showToast(d.saved ? 'Saqlanganlarga qo‘shildi' : 'Saqlanganlardan olib tashlandi');
                if (!d.saved) {   // "Saved" sahifasida karta yo'qoladi
                    var cards = document.querySelectorAll('[data-remove-on-unsave][data-post-id="' + id + '"]');
                    if (cards.length) {
                        cards.forEach(function (n) { n.remove(); });
                        if (pv && pv.classList.contains('open') && String(pvPostId) === String(id)) closeViewer();
                        if (window.onSavedRemoved) window.onSavedRemoved();
                    }
                }
            })
            .catch(function () { syncPost(id, {saved: was}); showToast('Saqlash bajarilmadi', 'error'); });
    }

    function sharePost(id) {
        var url = location.origin + CONTEXT_PATH + '/#post-' + id;
        copyText(url).then(function () { showToast('Havola nusxalandi'); }).catch(function () { showToast(url); });
    }

    function popHeart(container) {
        var h = container.querySelector('.heart-pop');
        if (!h) { h = el('i', 'fa-solid fa-heart heart-pop'); container.appendChild(h); }
        h.classList.remove('show'); void h.offsetWidth; h.classList.add('show');
        setTimeout(function () { h.classList.remove('show'); }, 850);
    }
    document.addEventListener('dblclick', function (e) {
        var m = e.target.closest('[data-dbl-like]'); if (!m) return;
        var host = m.closest('.js-post');
        var id = m.dataset.postId || (host ? host.dataset.postId : null);
        if (!id) return;
        popHeart(m);
        if (!isPostLiked(id)) toggleLike(id);
    });

    /* ko'rishlar (view count): har bir post sessiya davomida bir marta, muallifning o'zi hisobga olinmaydi */
    var viewed = {};
    try { viewed = JSON.parse(sessionStorage.getItem('mg_viewed') || '{}') || {}; } catch (e) { viewed = {}; }
    function registerView(id) {
        var p = getPostEl(id);
        if (!p || viewed[id]) return;
        if (String(p.dataset.authorId) === String(CURRENT_USER_ID)) return;
        viewed[id] = 1;
        try { sessionStorage.setItem('mg_viewed', JSON.stringify(viewed)); } catch (e) {}
        apiPost('/post/view', {postId: id}).then(function (d) {
            if (d && d.views !== undefined) setViews(id, d.views);
        }).catch(function () { delete viewed[id]; });
    }
    function initViews() {
        if (!('IntersectionObserver' in window)) return;
        var timers = {};
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (en) {
                var id = en.target.dataset.postId;
                if (en.isIntersecting && en.intersectionRatio >= 0.5) {
                    if (!timers[id]) timers[id] = setTimeout(function () { registerView(id); }, 900);
                } else { clearTimeout(timers[id]); timers[id] = null; }
            });
        }, {threshold: [0, 0.5, 1]});
        document.querySelectorAll('.feed-grid-layout > .js-post').forEach(function (c) { io.observe(c); });
    }

    /* post menyusi ( ... ) */
    function openPostMenu(id) {
        var p = getPostEl(id); if (!p) return;
        var mine = String(p.dataset.authorId) === String(CURRENT_USER_ID);
        var ov = el('div', 'pm-overlay'); var sheet = el('div', 'pm-sheet'); ov.appendChild(sheet);
        function close() { ov.remove(); }
        function item(text, cls, fn) { var b = el('button', 'pm-item' + (cls ? ' ' + cls : ''), text); b.type = 'button'; b.onclick = fn; sheet.appendChild(b); }
        ov.addEventListener('mousedown', function (e) { if (e.target === ov) close(); });
        if (mine) {
            item('Tahrirlash', '', function () { location.href = CONTEXT_PATH + '/post/edit?id=' + id; });
            item('O‘chirish', 'danger', function () {
                close();
                mgConfirm('Postni butunlay o‘chirishni xohlaysizmi? Bu amalni qaytarib bo‘lmaydi.', 'O‘chirish', true).then(function (ok) {
                    if (!ok) return;
                    var f = document.createElement('form'); f.method = 'post'; f.action = CONTEXT_PATH + '/post/delete';
                    var i = document.createElement('input'); i.type = 'hidden'; i.name = 'id'; i.value = id;
                    f.appendChild(i); document.body.appendChild(f); f.submit();
                });
            });
        } else {
            item('Shikoyat qilish', 'danger', function () {
                sheet.innerHTML = '';
                sheet.appendChild(el('div', 'pm-title', 'Shikoyat sababi'));
                ['Spam', 'Nomaqbul kontent', 'Zo‘ravonlik yoki nafrat', 'Yolg‘on ma’lumot', 'Boshqa'].forEach(function (r) {
                    item(r, '', function () {
                        postJSON(CONTEXT_PATH + '/post/report', {postId: id, reason: r})
                            .then(function () { showToast('Shikoyat yuborildi. Rahmat!'); })
                            .catch(function () { showToast('Shikoyat yuborilmadi', 'error'); });
                        close();
                    });
                });
                item('Bekor qilish', '', close);
            });
            item('Muallif profiliga o‘tish', '', function () { location.href = CONTEXT_PATH + '/user/profile?id=' + p.dataset.authorId; });
        }
        item('Havolani nusxalash', '', function () { sharePost(id); close(); });
        item('Bekor qilish', '', close);
        document.body.appendChild(ov);
    }

    /* ------------------------------------------------------------------ 8. Post oynasi + izohlar */
    var pv = null, pvPostId = null, pvReply = null, pvList = null;

    function ensureViewer() {
        if (pv) return;
        pv = el('div', 'pv-overlay');
        pv.innerHTML =
            '<button type="button" class="pv-close" aria-label="Yopish">&times;</button>' +
            '<div class="pv-box">' +
            '<div class="pv-media" id="pvMedia" data-dbl-like></div>' +
            '<div class="pv-side">' +
            '<div class="pv-head"><a id="pvAvatarLink"><img id="pvAvatar" class="feed-card-avatar" alt=""></a>' +
            '<a id="pvName" class="pv-name"></a>' +
            '<button type="button" class="action-btn" id="pvMore" style="margin-left:auto;font-size:18px"><i class="fa-solid fa-ellipsis"></i></button></div>' +
            '<div class="pv-comments" id="pvComments"></div>' +
            '<div class="pv-actions"><div class="left">' +
            '<button type="button" class="action-btn js-like-btn" id="pvLike"><i class="fa-regular fa-heart"></i></button>' +
            '<button type="button" class="action-btn" id="pvFocus"><i class="fa-regular fa-comment"></i></button>' +
            '<button type="button" class="action-btn" id="pvShare"><i class="fa-regular fa-paper-plane"></i></button>' +
            '<span class="view-stat js-view-count" id="pvViews" title="Ko‘rishlar"><i class="fa-regular fa-eye"></i><b>0</b></span></div>' +
            '<button type="button" class="action-btn js-save-btn" id="pvSave"><i class="fa-regular fa-bookmark"></i></button></div>' +
            '<div class="pv-likes js-like-count" id="pvLikes"></div>' +
            '<div class="pv-when"><span class="post-time" id="pvWhen"></span></div>' +
            '<div class="pv-replying" id="pvReplying" style="display:none"></div>' +
            '<form class="pv-form" id="pvForm" autocomplete="off">' +
            '<input id="pvInput" type="text" maxlength="1000" placeholder="Izoh qo‘shish...">' +
            '<button type="submit" id="pvSend" disabled>Yuborish</button></form>' +
            '</div></div>';
        document.body.appendChild(pv);
        pv.addEventListener('mousedown', function (e) { if (e.target === pv) closeViewer(); });
        pv.querySelector('.pv-close').onclick = closeViewer;
        $id('pvLike').onclick = function () { toggleLike(pvPostId); };
        $id('pvSave').onclick = function () { toggleSave(pvPostId); };
        $id('pvShare').onclick = function () { sharePost(pvPostId); };
        $id('pvFocus').onclick = function () { $id('pvInput').focus(); };
        $id('pvMore').onclick = function () { openPostMenu(pvPostId); };
        $id('pvInput').addEventListener('input', function () { $id('pvSend').disabled = !this.value.trim(); });
        $id('pvForm').addEventListener('submit', submitComment);
    }
    function closeViewer() {
        if (!pv) return;
        pv.classList.remove('open');
        $id('pvMedia').innerHTML = '';
        document.body.style.overflow = '';
        pvPostId = null;
    }

    function openPostViewer(id, focusInput) {
        var p = getPostEl(id); if (!p) return;
        ensureViewer();
        pvPostId = id; pvReply = null;
        var d = p.dataset;
        document.querySelectorAll('video[data-autoplay]').forEach(function (v) { v.pause(); });

        var media = $id('pvMedia');
        media.innerHTML = ''; media.classList.remove('no-media'); media.dataset.postId = id;
        if (d.mediaUrl) {
            if (d.mediaType === 'VIDEO') {
                var v = document.createElement('video');
                v.src = mediaSrc(d.mediaUrl); v.controls = true; v.autoplay = true; v.loop = true; v.playsInline = true;
                media.appendChild(v);
                var pr = v.play(); if (pr && pr.catch) pr.catch(function () {});
            } else {
                var im = document.createElement('img'); im.src = mediaSrc(d.mediaUrl); im.alt = ''; media.appendChild(im);
            }
        } else { media.classList.add('no-media'); media.textContent = d.content || ''; }
        media.appendChild(el('i', 'fa-solid fa-heart heart-pop'));

        var prof = CONTEXT_PATH + '/user/profile?id=' + d.authorId;
        $id('pvAvatar').src = resolveAvatar(d.avatar);
        $id('pvAvatarLink').href = prof; $id('pvName').href = prof; $id('pvName').textContent = d.author || '';
        if (d.verified === 'true') $id('pvName').appendChild(vBadge());
        ['pvLike', 'pvSave', 'pvLikes', 'pvViews'].forEach(function (x) { $id(x).dataset.postId = id; });
        $id('pvInput').value = ''; $id('pvSend').disabled = true; $id('pvReplying').style.display = 'none';
        $id('pvWhen').textContent = fullTime(d.created) + (d.created ? '  ·  ' + agoTime(d.created) : '');
        syncPost(id, {liked: d.liked === 'true', likes: parseInt(d.likes || '0', 10), saved: d.saved === 'true'});
        setViews(id, d.views || 0);

        var box = $id('pvComments'); box.innerHTML = '';
        if (d.content) box.appendChild(renderComment({id: null, username: d.author, avatar: d.avatar, content: d.content, createdAt: d.created}, null));
        pvList = el('div', 'cm-list'); box.appendChild(pvList);
        loadComments(id);
        pv.classList.add('open'); document.body.style.overflow = 'hidden';
        registerView(id);
        if (focusInput) setTimeout(function () { $id('pvInput').focus(); }, 80);
    }

    function loadComments(id) {
        var holder = pvList; holder.innerHTML = '';
        holder.appendChild(el('div', 'cm-hint', 'Izohlar yuklanmoqda...'));
        fetch(CONTEXT_PATH + '/comment?postId=' + encodeURIComponent(id), {credentials: 'same-origin', cache: 'no-store'})
            .then(function (r) { if (!r.ok) throw new Error('no list'); return r.json(); })
            .then(function (list) {
                if (String(pvPostId) !== String(id)) return;
                holder.innerHTML = '';
                if (!Array.isArray(list) || !list.length) { holder.appendChild(el('div', 'cm-hint', 'Hozircha izohlar yo‘q. Birinchi bo‘lib yozing!')); return; }
                list.forEach(function (c) { holder.appendChild(renderComment(c, null)); });
            })
            .catch(function () {
                if (String(pvPostId) !== String(id)) return;
                holder.innerHTML = ''; holder.appendChild(el('div', 'cm-hint', 'Hozircha izohlar yo‘q. Birinchi bo‘lib yozing!'));
            });
    }

    function likeBtnHtml(liked, count) { return '<i class="fa-' + (liked ? 'solid' : 'regular') + ' fa-heart"></i><span>' + (count || 0) + '</span>'; }

    /* parent == null  -> asosiy izoh; parent = {id, repliesBox, loadReplies} -> javob */
    function renderComment(c, parent) {
        var row = el('div', 'cm-row' + (parent ? ' cm-reply' : ''));
        var av = el('img', 'cm-avatar'); av.alt = ''; av.src = resolveAvatar(c.avatar);
        row.appendChild(av);
        var body = el('div', 'cm-body');
        var line = el('div', 'cm-line');
        var nm = el('b', null, c.username || 'user'); if (c.verified) nm.appendChild(vBadge()); line.appendChild(nm);
        line.appendChild(document.createTextNode(' ' + (c.content || '')));
        body.appendChild(line);
        var meta = el('div', 'cm-meta');
        var replies = el('div', 'cm-replies');
        var ctx = parent || {id: c.id, repliesBox: replies, count: c.replyCount || 0};
        if (c.id) {
            var rb = el('button', null, 'Javob berish'); rb.type = 'button';
            rb.onclick = function () { setReply({id: ctx.id, username: c.username, repliesBox: ctx.repliesBox, ctx: ctx}); };
            meta.appendChild(rb);
        }
        if (c.id && !parent && c.replyCount > 0) {
            var vr = el('button', null, 'Javoblarni ko‘rish (' + c.replyCount + ')'); vr.type = 'button';
            ctx.toggleBtn = vr;
            ctx.loadReplies = function () {
                return fetch(CONTEXT_PATH + '/comment?parrentId=' + encodeURIComponent(c.id), {credentials: 'same-origin', cache: 'no-store'})
                    .then(function (r) { return r.json(); })
                    .then(function (list) {
                        replies.innerHTML = '';
                        list.forEach(function (x) { replies.appendChild(renderComment(x, ctx)); });
                        replies.style.display = ''; vr.dataset.loaded = '1'; vr.textContent = 'Javoblarni yashirish';
                    });
            };
            vr.onclick = function () {
                if (vr.dataset.loaded === '1') {
                    var hidden = replies.style.display === 'none';
                    replies.style.display = hidden ? '' : 'none';
                    vr.textContent = hidden ? 'Javoblarni yashirish' : 'Javoblarni ko‘rish (' + list_count(ctx) + ')';
                    return;
                }
                ctx.loadReplies().catch(function () { showToast('Javoblar yuklanmadi', 'error'); });
            };
            meta.appendChild(vr);
        }
        if (meta.childNodes.length) body.appendChild(meta);
        if (!parent) body.appendChild(replies);
        row.appendChild(body);

        var side = el('div', 'cm-side');
        if (c.createdAt) { var tm = el('span', 'cm-time', shortTime(c.createdAt)); tm.title = fullTime(c.createdAt); side.appendChild(tm); }
        if (c.id) {
            var lb = el('button', 'cm-like' + (c.liked ? ' liked' : '')); lb.type = 'button'; lb.title = 'Like';
            lb.innerHTML = likeBtnHtml(c.liked, c.likeCount);
            lb.onclick = function () {
                postJSON(CONTEXT_PATH + '/comment/like', {commentId: c.id})
                    .then(function (r) { return r.json(); })
                    .then(function (d) { lb.classList.toggle('liked', d.liked); lb.innerHTML = likeBtnHtml(d.liked, d.count); })
                    .catch(function () { showToast('Xatolik', 'error'); });
            };
            side.appendChild(lb);
        }
        row.appendChild(side);
        return row;
    }
    function list_count(ctx) { return ctx.count || 0; }

    function setReply(t) {
        pvReply = t;
        var bar = $id('pvReplying'); bar.innerHTML = '';
        bar.appendChild(el('span', null, '@' + t.username + ' ga javob yozilmoqda'));
        var x = el('button', null, '×'); x.type = 'button'; x.onclick = clearReply;
        bar.appendChild(x); bar.style.display = 'flex';
        var inp = $id('pvInput'); inp.value = '@' + t.username + ' '; $id('pvSend').disabled = false; inp.focus();
    }
    function clearReply() { pvReply = null; $id('pvReplying').style.display = 'none'; }

    function submitComment(e) {
        e.preventDefault();
        var inp = $id('pvInput'); var text = inp.value.trim();
        if (!text || !pvPostId) return;
        var id = pvPostId, reply = pvReply;
        var params = {postId: id, content: text};
        if (reply) params.parentId = reply.id;
        $id('pvSend').disabled = true;
        postJSON(CONTEXT_PATH + '/comment', params).then(function () {
            inp.value = ''; clearReply();
            var p = getPostEl(id);
            syncPost(id, {comments: (p ? parseInt(p.dataset.comments || '0', 10) : 0) + 1});
            if (reply && reply.ctx) {   // javob: serverdan qayta o'qiymiz (haqiqiy vaqt va id bilan)
                reply.ctx.count = (reply.ctx.count || 0) + 1;
                if (reply.ctx.loadReplies) reply.ctx.loadReplies();
                else loadComments(id);
            } else {
                loadComments(id);
                setTimeout(function () { var b = $id('pvComments'); if (b) b.scrollTop = b.scrollHeight; }, 350);
            }
        }).catch(function () { showToast('Izoh yuborilmadi', 'error'); $id('pvSend').disabled = !inp.value.trim(); });
    }

    /* ------------------------------------------------------------------ 9. Stories */
    var storyGroups = [];
    function seenIds() { try { return JSON.parse(lsGet('mg_seen_' + CURRENT_USER_ID) || '[]'); } catch (e) { return []; } }
    function markSeen(id) {
        var a = seenIds();
        if (a.indexOf(id) < 0) { a.push(id); if (a.length > 600) a = a.slice(-600); lsSet('mg_seen_' + CURRENT_USER_ID, JSON.stringify(a)); }
    }
    function groupSeen(g) { var s = seenIds(); return g.stories.every(function (x) { return s.indexOf(x.id) >= 0; }); }

    function loadStories() {
        if (!$id('storiesBar')) return;
        api('/stories').then(function (g) { storyGroups = g || []; renderStoryBar(); })
            .catch(function () { storyGroups = []; renderStoryBar(); });
    }
    function orderedGroups() {
        var mine = storyGroups.filter(function (g) { return g.mine; });
        var others = storyGroups.filter(function (g) { return !g.mine; });
        var unseen = others.filter(function (g) { return !groupSeen(g); }), seen = others.filter(groupSeen);
        return mine.concat(unseen, seen);
    }
    function renderStoryBar() {
        var bar = $id('storiesBar'); if (!bar) return;
        bar.innerHTML = '';
        var list = orderedGroups();
        var mineG = list.length && list[0].mine ? list[0] : null;
        var my = el('div', 'story-item');
        var ring = el('div', 'story-ring ' + (mineG ? (groupSeen(mineG) ? 'seen' : '') : 'none'));
        var im = el('img'); im.alt = ''; im.src = resolveAvatar(ME ? ME.avatar : '');
        ring.appendChild(im); my.appendChild(ring);
        var add = el('span', 'story-add'); add.title = 'Hikoya qo‘shish'; add.innerHTML = '<i class="fa-solid fa-plus"></i>';
        add.onclick = function (e) { e.stopPropagation(); pickStory(); };
        my.appendChild(add); my.appendChild(el('span', 'story-name', 'Your story'));
        my.onclick = function () { if (mineG) openStoryGroups(list, 0); else pickStory(); };
        bar.appendChild(my);
        list.forEach(function (g, idx) {
            if (g.mine) return;
            var it = el('div', 'story-item');
            var rg = el('div', 'story-ring' + (groupSeen(g) ? ' seen' : ''));
            var ig = el('img'); ig.alt = ''; ig.src = resolveAvatar(g.avatar); rg.appendChild(ig);
            it.appendChild(rg); it.appendChild(el('span', 'story-name text-truncate', g.username));
            it.onclick = function () { openStoryGroups(list, idx); };
            bar.appendChild(it);
        });
        if (list.filter(function (g) { return !g.mine; }).length === 0) {
            bar.appendChild(el('div', 'story-empty', 'Kuzatayotganlaringizning hikoyalari shu yerda ko‘rinadi.'));
        }
    }

    var SV = {groups: [], gi: 0, si: 0, raf: 0, last: 0, elapsed: 0, dur: 5000, paused: false, video: null, dirty: false, holdAt: 0, held: false, root: null};
    function buildSV() {
        if (SV.root) return;
        var r = el('div', 'sv-overlay');
        r.innerHTML =
            '<button type="button" class="sv-close-x" id="svX">&times;</button>' +
            '<button type="button" class="sv-arrow prev" id="svPrevBtn"><i class="fa-solid fa-chevron-left"></i></button>' +
            '<div class="sv-frame" id="svFrame">' +
            '<div class="sv-media" id="svMedia"></div><div class="sv-shade"></div>' +
            '<div class="sv-bars" id="svBars"></div>' +
            '<div class="sv-head"><img id="svAv" alt=""><b id="svName"></b><span class="sv-time" id="svTime"></span><span class="sv-spacer"></span>' +
            '<button type="button" class="sv-btn" id="svMore" style="display:none"><i class="fa-solid fa-ellipsis"></i></button></div>' +
            '<div class="sv-zone left" id="svPrev"></div><div class="sv-zone right" id="svNext"></div>' +
            '<div class="sv-caption" id="svCap" style="display:none"></div></div>' +
            '<button type="button" class="sv-arrow next" id="svNextBtn"><i class="fa-solid fa-chevron-right"></i></button>';
        document.body.appendChild(r); SV.root = r;
        $id('svX').onclick = svClose;
        r.addEventListener('mousedown', function (e) { if (e.target === r) svClose(); });
        $id('svPrev').onclick = function () { if (!SV.held) svShow(SV.gi, SV.si - 1); };
        $id('svNext').onclick = function () { if (!SV.held) svShow(SV.gi, SV.si + 1); };
        $id('svPrevBtn').onclick = function () { svShow(SV.gi, SV.si - 1); };
        $id('svNextBtn').onclick = function () { svShow(SV.gi, SV.si + 1); };
        var fr = $id('svFrame');
        function hold() { SV.holdAt = Date.now(); SV.held = false; svPause(true); }
        function release() { if (SV.holdAt && Date.now() - SV.holdAt > 250) SV.held = true; SV.holdAt = 0; svPause(false); setTimeout(function () { SV.held = false; }, 60); }
        fr.addEventListener('mousedown', function (e) { if (!e.target.closest('button, .sv-menu')) hold(); });
        fr.addEventListener('touchstart', function (e) { if (!e.target.closest('button, .sv-menu')) hold(); }, {passive: true});
        ['mouseup', 'mouseleave', 'touchend'].forEach(function (ev) { fr.addEventListener(ev, function () { if (SV.holdAt) release(); }); });
        $id('svMore').onclick = function (e) { e.stopPropagation(); svMenu(); };
        document.addEventListener('keydown', function (e) {
            if (!SV.root.classList.contains('open')) return;
            if (e.key === 'ArrowRight') svShow(SV.gi, SV.si + 1);
            else if (e.key === 'ArrowLeft') svShow(SV.gi, SV.si - 1);
            else if (e.key === 'Escape') svClose();
        });
    }
    function svPause(p) {
        SV.paused = p;
        if (SV.video) { if (p) SV.video.pause(); else { var pr = SV.video.play(); if (pr && pr.catch) pr.catch(function () {}); } }
    }
    function openStoryGroups(groups, idx) {
        buildSV(); SV.groups = groups; SV.dirty = false;
        SV.root.classList.add('open'); document.body.style.overflow = 'hidden';
        svShow(idx, 0);
    }
    function svClose() {
        if (!SV.root) return;
        cancelAnimationFrame(SV.raf);
        if (SV.video) { SV.video.pause(); SV.video = null; }
        $id('svMedia').innerHTML = '';
        var m = SV.root.querySelector('.sv-menu'); if (m) m.remove();
        SV.root.classList.remove('open');
        if (!pv || !pv.classList.contains('open')) document.body.style.overflow = '';
        if (SV.dirty) loadStories(); else renderStoryBar();
        if (window.onStoriesChanged) window.onStoriesChanged();
    }
    function svShow(gi, si) {
        cancelAnimationFrame(SV.raf);
        var menu = SV.root.querySelector('.sv-menu'); if (menu) menu.remove();
        if (gi < 0) gi = 0;
        var g = SV.groups[gi];
        if (!g) { svClose(); return; }
        if (si >= g.stories.length) { svShow(gi + 1, 0); return; }
        if (si < 0) { if (gi > 0) { svShow(gi - 1, SV.groups[gi - 1].stories.length - 1); return; } si = 0; }
        SV.gi = gi; SV.si = si;
        var s = g.stories[si];
        var bars = $id('svBars'); bars.innerHTML = '';
        g.stories.forEach(function (x, i) {
            var b = el('div', 'sv-bar'); var f = el('i'); f.style.width = i < si ? '100%' : '0';
            b.appendChild(f); bars.appendChild(b);
        });
        $id('svAv').src = resolveAvatar(g.avatar);
        $id('svName').textContent = g.username;
        $id('svTime').textContent = shortTime(s.createdAt);
        $id('svMore').style.display = g.mine ? 'inline-block' : 'none';
        var cap = $id('svCap'); cap.textContent = s.caption || ''; cap.style.display = s.caption ? 'block' : 'none';
        var media = $id('svMedia'); media.innerHTML = '';
        if (SV.video) { SV.video.pause(); SV.video = null; }
        SV.elapsed = 0; SV.dur = 5000; SV.paused = false; SV.last = performance.now();
        if (s.mediaType === 'VIDEO') {
            var v = document.createElement('video');
            v.src = mediaSrc(s.mediaUrl); v.playsInline = true; v.autoplay = true;
            v.onended = function () { svShow(SV.gi, SV.si + 1); };
            v.onerror = function () { setTimeout(function () { svShow(SV.gi, SV.si + 1); }, 800); };
            media.appendChild(v); SV.video = v;
            var pr = v.play();
            if (pr && pr.catch) pr.catch(function () { v.muted = true; var p2 = v.play(); if (p2 && p2.catch) p2.catch(function () {}); });
        } else {
            var im = document.createElement('img'); im.src = mediaSrc(s.mediaUrl); im.alt = ''; media.appendChild(im);
        }
        markSeen(s.id);
        function tick(now) {
            var dt = now - SV.last; SV.last = now;
            var fill = bars.children[SV.si] ? bars.children[SV.si].firstChild : null;
            if (!SV.paused) {
                var pct;
                if (SV.video) { var d = SV.video.duration; pct = d && isFinite(d) ? SV.video.currentTime / d : 0; }
                else { SV.elapsed += dt; pct = SV.elapsed / SV.dur; }
                if (fill) fill.style.width = Math.min(100, pct * 100) + '%';
                if (!SV.video && pct >= 1) { svShow(SV.gi, SV.si + 1); return; }
            }
            SV.raf = requestAnimationFrame(tick);
        }
        SV.raf = requestAnimationFrame(tick);
    }
    function svMenu() {
        var g = SV.groups[SV.gi]; if (!g || !g.mine) return;
        var s = g.stories[SV.si];
        var old = SV.root.querySelector('.sv-menu');
        if (old) { old.remove(); svPause(false); return; }
        svPause(true);
        var m = el('div', 'sv-menu');
        function item(text, cls, fn) { var b = el('button', cls || '', text); b.type = 'button'; b.onclick = function (e) { e.stopPropagation(); m.remove(); fn(); }; m.appendChild(b); }
        item('Matnni tahrirlash', '', function () {
            mgPrompt('Hikoya matni', s.caption || '', 'Hikoyaga matn yozing...').then(function (v) {
                if (v === null) { svPause(false); return; }
                apiPost('/story/update', {id: s.id, caption: v}).then(function () {
                    s.caption = v; SV.dirty = true; svShow(SV.gi, SV.si); showToast('Hikoya yangilandi');
                }).catch(function (e) { svPause(false); showToast(e.message, 'error'); });
            });
        });
        item('Yangi hikoya qo‘shish', '', function () { svClose(); pickStory(); });
        item('O‘chirish', 'danger', function () {
            mgConfirm('Bu hikoyani o‘chirasizmi?', 'O‘chirish', true).then(function (ok) {
                if (!ok) { svPause(false); return; }
                apiPost('/story/delete', {id: s.id}).then(function () {
                    g.stories.splice(SV.si, 1); SV.dirty = true; showToast('Hikoya o‘chirildi');
                    if (!g.stories.length) { storyGroups = storyGroups.filter(function (x) { return x !== g; }); SV.groups = SV.groups.filter(function (x) { return x !== g; }); svShow(SV.gi, 0); }
                    else svShow(SV.gi, Math.min(SV.si, g.stories.length - 1));
                }).catch(function (e) { svPause(false); showToast(e.message, 'error'); });
            });
        });
        $id('svFrame').appendChild(m);
    }

    var storyInput = null;
    function pickStory() {
        if (!storyInput) {
            storyInput = document.createElement('input'); storyInput.type = 'file'; storyInput.accept = 'image/*,video/*'; storyInput.style.display = 'none';
            document.body.appendChild(storyInput);
            storyInput.addEventListener('change', function () { var f = storyInput.files && storyInput.files[0]; storyInput.value = ''; if (f) openStoryComposer(f); });
        }
        storyInput.click();
    }
    function openStoryComposer(file) {
        var isVideo = file.type.indexOf('video/') === 0;
        if (!isVideo && file.type.indexOf('image/') !== 0) { showToast('Faqat rasm yoki video tanlang', 'error'); return; }
        if (file.size > 48 * 1024 * 1024) { showToast('Fayl juda katta (48 MB gacha)', 'error'); return; }
        var url = URL.createObjectURL(file);
        var wrap = el('div');
        var pvw = el('div', 'sv-preview');
        var node = document.createElement(isVideo ? 'video' : 'img');
        node.src = url;
        if (isVideo) { node.muted = true; node.loop = true; node.autoplay = true; node.playsInline = true; node.controls = true; }
        pvw.appendChild(node); wrap.appendChild(pvw);
        var cap = el('input', 'form-control'); cap.type = 'text'; cap.maxLength = 300; cap.placeholder = 'Matn qo‘shish (ixtiyoriy)...';
        wrap.appendChild(cap);
        var ok = true;
        if (isVideo) node.addEventListener('loadedmetadata', function () {
            if (node.duration > 61) { ok = false; showToast('Video 60 soniyadan oshmasin', 'error'); }
        });
        mgModal('Yangi hikoya (24 soat)', wrap, [
            {text: 'Bekor qilish', onClick: function (m) { m.close(); }},
            {text: 'Ulashish', cls: 'btn-primary', onClick: function (m, btn) {
                    if (!ok) return showToast('Video 60 soniyadan oshmasin', 'error');
                    btn.disabled = true; btn.textContent = 'Yuklanmoqda...';
                    var fd = new FormData(); fd.append('media', file); fd.append('caption', cap.value.trim());
                    apiForm('/story/create', fd).then(function () {
                        m.close(); showToast('Hikoya joylandi'); loadStories();
                        if (window.onStoriesChanged) window.onStoriesChanged();
                    }).catch(function (e) { btn.disabled = false; btn.textContent = 'Ulashish'; showToast(e.message, 'error'); });
                }}
        ], {onClose: function () { URL.revokeObjectURL(url); }});
    }
    /* profildan: faqat shu foydalanuvchi hikoyalarini ochadi (o'zim yoki obuna bo'lganlarim) */
    function openUserStories(userId) {
        api('/stories?userId=' + encodeURIComponent(userId)).then(function (g) {
            if (g && g.length) openStoryGroups(g, 0); else showToast('Hozircha hikoya yo‘q');
        }).catch(function (e) { showToast(e.message, 'error'); });
    }

    /* ------------------------------------------------------------------ 10. Video kesish (3 soniya) */
    /* Uzun videoning birinchi maxSec soniyasi canvas+MediaRecorder orqali yangi faylga yoziladi. */
    MG.trimVideo = function (file, maxSec) {
        return new Promise(function (resolve, reject) {
            var url = URL.createObjectURL(file);
            var v = document.createElement('video');
            v.muted = true; v.playsInline = true; v.preload = 'auto'; v.src = url;
            function done(fn, val) { try { URL.revokeObjectURL(url); } catch (e) {} v.removeAttribute('src'); fn(val); }
            v.onerror = function () { done(reject, new Error('Videoni o‘qib bo‘lmadi')); };
            v.onloadedmetadata = function () {
                var dur = v.duration;
                if (isFinite(dur) && dur <= maxSec + 0.2) { done(resolve, {file: file, trimmed: false}); return; }
                if (!window.MediaRecorder || !HTMLCanvasElement.prototype.captureStream) {
                    done(reject, new Error('Brauzeringiz videoni kesa olmaydi. Qisqaroq (3 soniyali) video tanlang.')); return;
                }
                var w = v.videoWidth || 640, h = v.videoHeight || 360;
                var sc = Math.min(1, 720 / Math.max(w, h));
                var cw = Math.max(2, Math.round(w * sc / 2) * 2), ch = Math.max(2, Math.round(h * sc / 2) * 2);
                var c = document.createElement('canvas'); c.width = cw; c.height = ch;
                var ctx = c.getContext('2d');
                var stream = c.captureStream(30);
                var types = ['video/webm;codecs=vp9', 'video/webm;codecs=vp8', 'video/webm', 'video/mp4'];
                var type = ''; for (var i = 0; i < types.length; i++) { if (MediaRecorder.isTypeSupported(types[i])) { type = types[i]; break; } }
                var rec;
                try { rec = new MediaRecorder(stream, type ? {mimeType: type, videoBitsPerSecond: 2500000} : {}); }
                catch (e) { done(reject, new Error('Videoni kesib bo‘lmadi')); return; }
                var chunks = [];
                rec.ondataavailable = function (e) { if (e.data && e.data.size) chunks.push(e.data); };
                rec.onstop = function () {
                    var mt = (rec.mimeType || type || 'video/webm').split(';')[0];
                    var blob = new Blob(chunks, {type: mt});
                    var f = new File([blob], 'cover.' + (mt.indexOf('mp4') >= 0 ? 'mp4' : 'webm'), {type: mt});
                    done(resolve, {file: f, trimmed: true});
                };
                v.currentTime = 0;
                var pr = v.play();
                var started = false;
                function loop() {
                    ctx.drawImage(v, 0, 0, cw, ch);
                    if (v.currentTime >= maxSec || v.ended) { v.pause(); if (rec.state !== 'inactive') rec.stop(); return; }
                    requestAnimationFrame(loop);
                }
                function go() { if (started) return; started = true; rec.start(); loop(); }
                if (pr && pr.then) pr.then(go).catch(function () { done(reject, new Error('Videoni ishga tushirib bo‘lmadi')); }); else go();
            };
        });
    };
    /* rasm yoki video -> {file, url, isVideo}; video 3 soniyaga kesiladi */
    MG.processCover = function (file, busy) {
        if (file.type.indexOf('image/') === 0) return Promise.resolve({file: file, isVideo: false, url: URL.createObjectURL(file)});
        if (file.type.indexOf('video/') === 0) {
            if (busy) busy(true);
            return MG.trimVideo(file, 3).then(function (r) {
                if (busy) busy(false);
                return {file: r.file, isVideo: true, url: URL.createObjectURL(r.file), trimmed: r.trimmed};
            }, function (e) { if (busy) busy(false); throw e; });
        }
        return Promise.reject(new Error('Faqat rasm yoki video tanlang'));
    };

    /* ------------------------------------------------------------------ 11. Follow (profil sahifasi) + ishga tushirish */
    function toggleFollow(userId, onDone) {
        postJSON(CONTEXT_PATH + '/user/follow', {targetUserId: userId})
            .then(function (r) { return r.json(); })
            .then(function (d) { refreshMe(); if (onDone) onDone(d); })
            .catch(function () { showToast('Follow bajarilmadi', 'error'); });
    }
    function initVideos() {
        var vids = document.querySelectorAll('.feed-card-media video[data-autoplay]');
        if (!vids.length || !('IntersectionObserver' in window)) return;
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (en) {
                var v = en.target;
                if (en.isIntersecting && en.intersectionRatio >= 0.6) { var pr = v.play(); if (pr && pr.catch) pr.catch(function () {}); } else v.pause();
            });
        }, {threshold: [0, 0.6, 1]});
        vids.forEach(function (v) {
            io.observe(v);
            var btn = el('button', 'vid-sound-btn'); btn.type = 'button'; btn.innerHTML = '<i class="fa-solid fa-volume-xmark"></i>';
            btn.onclick = function (ev) { ev.stopPropagation(); v.muted = !v.muted; btn.innerHTML = '<i class="fa-solid ' + (v.muted ? 'fa-volume-xmark' : 'fa-volume-high') + '"></i>'; };
            v.parentNode.appendChild(btn);
            v.addEventListener('click', function () { if (v.paused) { var pr = v.play(); if (pr && pr.catch) pr.catch(function () {}); } else v.pause(); });
        });
    }
    function highlightHash() {
        if (!/^#post-\d+$/.test(location.hash)) return;
        var t = document.querySelector(location.hash); if (!t) return;
        t.scrollIntoView({block: 'center'});
        t.classList.add('post-highlight');
        setTimeout(function () { t.classList.remove('post-highlight'); }, 2500);
    }
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        var pm = document.querySelector('.pm-overlay'); if (pm) { pm.remove(); return; }
        if (SV.root && SV.root.classList.contains('open')) return;
        var wp = document.querySelector('.wp-view'); if (wp) { wp.remove(); return; }
        var mo = document.querySelector('.mg-modal-overlay'); if (mo) { mo.remove(); return; }
        var sb = $id('sbListPanel'); if (sb && sb.classList.contains('open')) { closeFollowList(); return; }
        if (pv && pv.classList.contains('open')) closeViewer();
    });
    window.addEventListener('hashchange', highlightHash);

    /* Hashtaglarni bosiladigan havolaga aylantirish (matn xavfsiz: faqat textContent ishlatiladi) */
    function linkifyTags(root) {
        (root || document).querySelectorAll('.js-caption').forEach(function (box) {
            if (box.dataset.linked) return; box.dataset.linked = '1';
            Array.prototype.slice.call(box.childNodes).forEach(function (n) {
                if (n.nodeType !== 3 || n.nodeValue.indexOf('#') < 0) return;
                var parts = n.nodeValue.split(/(#[\p{L}\p{N}_]{2,40})/u), frag = document.createDocumentFragment();
                parts.forEach(function (t) {
                    if (/^#[\p{L}\p{N}_]{2,40}$/u.test(t)) {
                        var a = el('a', 'mg-tag', t); a.href = CONTEXT_PATH + '/explore?tag=' + encodeURIComponent(t.slice(1)); frag.appendChild(a);
                    } else if (t) frag.appendChild(document.createTextNode(t));
                });
                n.parentNode.replaceChild(frag, n);
            });
        });
    }
    function initExplore() {
        document.querySelectorAll('[data-open-post]').forEach(function (a) {
            a.addEventListener('click', function (e) { e.preventDefault(); openPostViewer(a.dataset.openPost); });
        });
        document.querySelectorAll('[data-follow-id]').forEach(function (b) {
            b.addEventListener('click', function () {
                b.disabled = true;
                toggleFollow(b.dataset.followId, function (d) {
                    b.disabled = false;
                    b.classList.toggle('on', !!d.following);
                    b.textContent = d.following ? 'Kuzatilmoqda' : 'Kuzatish';
                });
            });
        });
    }

    onReady(function () {
        initSidebar();
        linkifyTags();
        initExplore();
        initSettings();
        initNotifications();
        initSearch();
        initVideos();
        initViews();
        loadPostMeta();
        setInterval(refreshTimes, 60000);
        loadStories();
        highlightHash();
    });
</script>
