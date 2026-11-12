<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %><%!
    private static String esc(Object o) {
        if (o == null) return "";
        return o.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%><%
    String nonce = esc(request.getAttribute("cspNonce"));
    String adminName = esc(session.getAttribute("adminName"));
    String csrf = esc(session.getAttribute("adminCsrf"));
    boolean isSuper = Boolean.TRUE.equals(session.getAttribute("adminSuper"));
    String ctx = esc(request.getContextPath());
%><!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex,nofollow">
  <title>Boshqaruv paneli — MilliyGram</title>
  <script nonce="<%= nonce %>">try{var t=localStorage.getItem('mg_admin_theme');if(t)document.documentElement.setAttribute('data-theme',t)}catch(e){}</script>
  <style>
    <%@ include file="style.jspf" %>
    .app{display:grid;grid-template-columns:252px minmax(0,1fr);min-height:100vh}
    /* ---------- yon panel ---------- */
    .nav{position:sticky;top:0;height:100vh;display:flex;flex-direction:column;background:var(--surface);border-right:1px solid var(--line)}
    .nav-head{position:relative;padding:22px 20px 20px;overflow:hidden}
    .nav-head::before{content:"";position:absolute;inset:0 0 auto 0;height:6px;background:var(--ikat)}
    .brand{display:flex;align-items:center;gap:10px;font-weight:700;font-size:16px;margin-top:6px}
    .brand-mark{width:30px;height:30px;border-radius:9px;background:var(--ikat);box-shadow:inset 0 0 0 1px rgba(255,255,255,.15)}
    .brand small{display:block;font-weight:500;font-size:12px;color:var(--faint)}
    .nav-list{list-style:none;margin:6px 0 0;padding:0 12px;flex:1;overflow:auto}
    .nav-group{font-size:12px;color:var(--faint);padding:16px 10px 6px}
    .nav-item{display:flex;align-items:center;gap:11px;width:100%;padding:9px 10px;border:0;background:none;border-radius:10px;color:var(--muted);cursor:pointer;text-align:left;font-weight:500}
    .nav-item:hover{background:var(--raised);color:var(--text)}
    .nav-item[aria-current="page"]{background:var(--raised);color:var(--text);box-shadow:inset 3px 0 0 var(--violet)}
    .nav-item .count{margin-left:auto;min-width:22px;height:20px;padding:0 6px;border-radius:10px;background:var(--pom);color:#fff;font-size:11.5px;font-weight:700;display:none;align-items:center;justify-content:center}
    .nav-foot{padding:14px 16px;border-top:1px solid var(--line);display:flex;align-items:center;gap:10px}
    .me-av{width:34px;height:34px;border-radius:50%;background:var(--raised);display:grid;place-items:center;font-weight:700;color:var(--violet-2);border:1px solid var(--line)}
    .me-name{font-weight:600;font-size:13.5px;line-height:1.2}
    .me-role{font-size:12px;color:var(--faint)}
    .icon-btn{width:36px;height:36px;display:grid;place-items:center;border-radius:10px;border:1px solid var(--line);background:var(--raised);cursor:pointer;color:var(--muted)}
    .icon-btn:hover{color:var(--text);border-color:var(--violet)}
    /* ---------- asosiy qism ---------- */
    .main{min-width:0;display:flex;flex-direction:column}
    .top{position:sticky;top:0;z-index:5;display:flex;align-items:center;gap:12px;padding:16px 28px;background:color-mix(in srgb,var(--ink) 88%,transparent);backdrop-filter:blur(10px);border-bottom:1px solid var(--line-soft)}
    .top h1{font-size:20px;margin:0;letter-spacing:-.01em}
    .top .sub{color:var(--faint);font-size:13px}
    .top .spacer{flex:1}
    .menu-btn{display:none}
    .page{padding:24px 28px 48px;max-width:1360px;width:100%}
    /* ---------- dashboard ---------- */
    .kpis{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);overflow:hidden}
    .kpi{padding:18px 20px;border-right:1px solid var(--line-soft)}
    .kpi:last-child{border-right:0}
    .kpi .v{font-size:30px;font-weight:700;letter-spacing:-.02em;line-height:1.1}
    .kpi .l{color:var(--muted);font-size:13px;margin-top:4px}
    .kpi .d{font-size:12.5px;margin-top:8px;color:var(--faint)}
    .kpi .d b{color:var(--turq);font-weight:600}
    .kpi.warn .v{color:var(--saffron)}
    .kpi.bad .v{color:var(--pom)}
    .grid2{display:grid;grid-template-columns:minmax(0,2fr) minmax(0,1fr);gap:18px;margin-top:18px}
    .panel{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);padding:18px 20px;min-width:0}
    .panel-h{display:flex;align-items:center;gap:10px;margin-bottom:14px}
    .panel-h h2{font-size:15px;margin:0}
    .panel-h .spacer{flex:1}
    .legend{display:flex;gap:14px;font-size:12.5px;color:var(--muted)}
    .legend i{display:inline-block;width:10px;height:10px;border-radius:3px;margin-right:6px;vertical-align:-1px}
    .chart{position:relative}
    .chart svg{display:block;width:100%;height:240px}
    .tip{position:absolute;pointer-events:none;background:var(--raised);border:1px solid var(--line);border-radius:10px;padding:8px 10px;font-size:12.5px;white-space:nowrap;transform:translate(-50%,-110%);display:none;box-shadow:0 8px 24px rgba(0,0,0,.25)}
    .mini-stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-top:14px}
    .mini-stats div{background:var(--raised);border-radius:var(--radius);padding:10px 12px}
    .mini-stats b{display:block;font-size:18px}
    .mini-stats span{font-size:12px;color:var(--muted)}
    .people{list-style:none;margin:0;padding:0}
    .people li{display:flex;align-items:center;gap:11px;padding:9px 0;border-bottom:1px solid var(--line-soft)}
    .people li:last-child{border-bottom:0}
    .av{width:36px;height:36px;border-radius:50%;object-fit:cover;background:var(--raised);flex:none;border:1px solid var(--line)}
    .who{min-width:0;flex:1}
    .who b{display:flex;align-items:center;gap:5px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .who span{display:block;font-size:12.5px;color:var(--faint);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .vbadge{width:15px;height:15px;flex:none}
    /* ---------- jadval ---------- */
    .toolbar{display:flex;gap:10px;flex-wrap:wrap;align-items:center;margin-bottom:14px}
    .search{position:relative;flex:1;min-width:220px;max-width:420px}
    .search .ico{position:absolute;left:12px;top:11px;color:var(--faint)}
    .search .input{padding-left:38px;height:40px}
    .seg{display:inline-flex;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:3px}
    .seg button{border:0;background:none;padding:6px 12px;border-radius:9px;cursor:pointer;color:var(--muted);font-weight:500}
    .seg button[aria-pressed="true"]{background:var(--raised);color:var(--text)}
    .table-wrap{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);overflow:auto}
    table{width:100%;border-collapse:collapse;min-width:760px}
    th{text-align:left;font-weight:600;font-size:12.5px;color:var(--muted);padding:11px 14px;border-bottom:1px solid var(--line);background:var(--surface);position:sticky;top:0}
    td{padding:11px 14px;border-bottom:1px solid var(--line-soft);vertical-align:middle}
    tr:last-child td{border-bottom:0}
    tr:hover td{background:color-mix(in srgb,var(--raised) 55%,transparent)}
    td.num{text-align:right;font-variant-numeric:tabular-nums}
    th.num{text-align:right}
    .actions{display:flex;gap:6px;justify-content:flex-end;flex-wrap:wrap}
    .pill{display:inline-flex;align-items:center;gap:5px;height:22px;padding:0 9px;border-radius:11px;font-size:12px;font-weight:600}
    .pill.ok{background:color-mix(in srgb,var(--turq) 16%,transparent);color:var(--turq)}
    .pill.bad{background:color-mix(in srgb,var(--pom) 16%,transparent);color:var(--pom)}
    .pill.warn{background:color-mix(in srgb,var(--saffron) 18%,transparent);color:var(--saffron)}
    .pill.mute{background:var(--raised);color:var(--muted)}
    .clip{max-width:420px;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;color:var(--muted)}
    .clip b{color:var(--text)}
    .thumb{width:46px;height:46px;border-radius:10px;object-fit:cover;background:var(--raised);display:block}
    .thumb.txt{display:grid;place-items:center;color:var(--faint);font-size:11px}
    .pager{display:flex;align-items:center;gap:10px;justify-content:flex-end;margin-top:14px;color:var(--muted);font-size:13px}
    .empty{padding:44px 20px;text-align:center;color:var(--muted)}
    .empty b{display:block;color:var(--text);font-size:15px;margin-bottom:4px}
    /* ---------- shikoyatlar ---------- */
    .cases{display:grid;gap:12px}
    .case{display:grid;grid-template-columns:88px minmax(0,1fr) auto;gap:16px;align-items:start;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);padding:14px}
    .case .media{width:88px;height:88px;border-radius:12px;object-fit:cover;background:var(--raised)}
    .case .media.txt{display:grid;place-items:center;padding:8px;font-size:11.5px;color:var(--muted);overflow:hidden}
    .case h3{margin:0 0 4px;font-size:15px}
    .case .meta{font-size:12.5px;color:var(--faint);margin-bottom:8px}
    .reasons{display:flex;gap:6px;flex-wrap:wrap}
    .reasons span{background:var(--raised);border:1px solid var(--line-soft);border-radius:8px;padding:3px 9px;font-size:12.5px;color:var(--muted)}
    .case .cnt{font-size:24px;font-weight:700;color:var(--saffron);text-align:right;line-height:1}
    .case .cnt small{display:block;font-size:12px;font-weight:500;color:var(--faint)}
    .case .actions{margin-top:12px}
    /* ---------- tizim ---------- */
    .sys{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}
    .meter{height:8px;border-radius:5px;background:var(--raised);overflow:hidden;margin-top:10px}
    .meter i{display:block;height:100%;background:var(--turq);border-radius:5px}
    .meter.hi i{background:var(--saffron)}
    .kv{display:grid;grid-template-columns:auto 1fr;gap:8px 16px;font-size:13.5px}
    .kv dt{color:var(--muted)}
    .kv dd{margin:0;text-align:right;font-weight:500;word-break:break-word}
    .big{font-size:26px;font-weight:700;letter-spacing:-.02em}
    .lbl{color:var(--muted);font-size:13px}
    /* ---------- modal va toast ---------- */
    .modal-bg{position:fixed;inset:0;background:rgba(8,6,20,.62);display:none;align-items:center;justify-content:center;z-index:50;padding:16px}
    .modal-bg.open{display:flex}
    .modal{width:100%;max-width:440px;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);padding:22px;box-shadow:0 24px 60px rgba(0,0,0,.4)}
    .modal h3{margin:0 0 6px;font-size:17px}
    .modal p{margin:0 0 16px;color:var(--muted)}
    .modal .row{display:flex;gap:10px;justify-content:flex-end;margin-top:6px}
    .modal .qr{display:inline-block;padding:10px;background:#fff;border-radius:12px;margin:6px 0 10px}
    .modal code{display:block;padding:9px 12px;border-radius:8px;background:var(--raised);letter-spacing:.06em;word-break:break-all;margin-bottom:14px}
    .toasts{position:fixed;right:20px;bottom:20px;display:grid;gap:8px;z-index:60}
    .toast{background:var(--raised);border:1px solid var(--line);border-left:3px solid var(--turq);border-radius:10px;padding:10px 14px;min-width:240px;box-shadow:0 10px 30px rgba(0,0,0,.3)}
    .toast.err{border-left-color:var(--pom)}
    .skel{height:14px;border-radius:6px;background:linear-gradient(90deg,var(--raised),var(--line-soft),var(--raised));background-size:200% 100%;animation:sk 1.2s infinite}
    @keyframes sk{to{background-position:-200% 0}}
    @media (max-width:1100px){.grid2{grid-template-columns:1fr}.sys{grid-template-columns:1fr 1fr}}
    @media (max-width:860px){
      .app{grid-template-columns:1fr}
      .nav{position:fixed;left:0;top:0;z-index:40;width:270px;transform:translateX(-100%);transition:transform .2s}
      .nav.open{transform:none;box-shadow:0 0 0 100vmax rgba(8,6,20,.5)}
      .menu-btn{display:grid}
      .top{padding:12px 16px}
      .page{padding:16px 16px 40px}
      .kpis{grid-template-columns:1fr 1fr}
      .kpi:nth-child(2){border-right:0}
      .kpi:nth-child(-n+2){border-bottom:1px solid var(--line-soft)}
      .sys{grid-template-columns:1fr}
      .case{grid-template-columns:64px minmax(0,1fr)}
      .case .media{width:64px;height:64px}
      .case .cnt{grid-column:2;text-align:left}
    }
  </style>
</head>
<body>
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <symbol id="i-dash" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></symbol>
  <symbol id="i-users" viewBox="0 0 24 24"><circle cx="9" cy="8" r="4"/><path d="M2 21c0-3.9 3.1-7 7-7s7 3.1 7 7"/><path d="M16 3.5a4 4 0 0 1 0 7.5M22 21c0-3-1.8-5.5-4.5-6.5"/></symbol>
  <symbol id="i-post" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="9" cy="9" r="2"/><path d="M21 16l-5-5-9 9"/></symbol>
  <symbol id="i-comment" viewBox="0 0 24 24"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12z"/></symbol>
  <symbol id="i-flag" viewBox="0 0 24 24"><path d="M5 21V4M5 4h11l-2 4 2 4H5"/></symbol>
  <symbol id="i-log" viewBox="0 0 24 24"><path d="M12 3l8 3v6c0 4.5-3.4 8.3-8 9-4.6-.7-8-4.5-8-9V6z"/><path d="M9 12l2 2 4-4"/></symbol>
  <symbol id="i-server" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="7" rx="2"/><rect x="3" y="13" width="18" height="7" rx="2"/><path d="M7 7.5h.01M7 16.5h.01"/></symbol>
  <symbol id="i-key" viewBox="0 0 24 24"><circle cx="8" cy="15" r="4"/><path d="M11 12l9-9M17 6l3 3M14 9l2 2"/></symbol>
  <symbol id="i-admins" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/><path d="M12 13l1.2 2.5 2.8.4-2 2 .5 2.8L12 19.4"/></symbol>
  <symbol id="i-out" viewBox="0 0 24 24"><path d="M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3M10 17l5-5-5-5M15 12H3"/></symbol>
  <symbol id="i-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/></symbol>
  <symbol id="i-moon" viewBox="0 0 24 24"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/></symbol>
  <symbol id="i-menu" viewBox="0 0 24 24"><path d="M4 6h16M4 12h16M4 18h16"/></symbol>
  <symbol id="i-refresh" viewBox="0 0 24 24"><path d="M20 11a8 8 0 0 0-14.9-3M4 4v4h4M4 13a8 8 0 0 0 14.9 3M20 20v-4h-4"/></symbol>
  <symbol id="i-site" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.7 3.8 5.7 3.8 9s-1.3 6.3-3.8 9c-2.5-2.7-3.8-5.7-3.8-9S9.5 5.7 12 3z"/></symbol>
  <symbol id="i-verified" viewBox="0 0 24 24"><path fill="#3b9bff" stroke="none" d="M12 1.8l2.6 1.9 3.2-.2 1 3 2.6 1.9-1 3.1 1 3.1-2.6 1.9-1 3-3.2-.2L12 22.2l-2.6-1.9-3.2.2-1-3-2.6-1.9 1-3.1-1-3.1 2.6-1.9 1-3 3.2.2z"/><path stroke="#fff" stroke-width="2.2" fill="none" d="M8 12.2l2.7 2.7L16.2 9.4"/></symbol>
</svg>

<div class="app">
  <aside class="nav" id="nav" aria-label="Bo'limlar">
    <div class="nav-head">
      <div class="brand"><span class="brand-mark"></span><span>MilliyGram<small>Boshqaruv paneli</small></span></div>
    </div>
    <ul class="nav-list" id="navList">
      <li><button class="nav-item" data-route="dashboard"><svg class="ico"><use href="#i-dash"/></svg>Umumiy ko'rinish</button></li>
      <li class="nav-group">Boshqaruv</li>
      <li><button class="nav-item" data-route="users"><svg class="ico"><use href="#i-users"/></svg>Foydalanuvchilar</button></li>
      <li><button class="nav-item" data-route="posts"><svg class="ico"><use href="#i-post"/></svg>Postlar</button></li>
      <li><button class="nav-item" data-route="comments"><svg class="ico"><use href="#i-comment"/></svg>Izohlar</button></li>
      <li><button class="nav-item" data-route="complaints"><svg class="ico"><use href="#i-flag"/></svg>Shikoyatlar<span class="count" id="cCount"></span></button></li>
      <li class="nav-group">Xavfsizlik</li>
      <li><button class="nav-item" data-route="logs"><svg class="ico"><use href="#i-log"/></svg>Jurnal</button></li>
      <li><button class="nav-item" data-route="system"><svg class="ico"><use href="#i-server"/></svg>Server holati</button></li>
      <% if (isSuper) { %><li><button class="nav-item" data-route="admins"><svg class="ico"><use href="#i-admins"/></svg>Adminlar</button></li><% } %>
      <li><button class="nav-item" data-route="settings"><svg class="ico"><use href="#i-key"/></svg>Parolni o'zgartirish</button></li>
    </ul>
    <div class="nav-foot">
      <div class="me-av"><%= adminName.isEmpty() ? "A" : adminName.substring(0, 1).toUpperCase() %></div>
      <div style="flex:1;min-width:0"><div class="me-name"><%= adminName %></div><div class="me-role"><%= isSuper ? "Bosh admin" : "Admin" %></div></div>
      <form method="post" action="<%= ctx %>/mgadmin/logout" style="margin:0">
        <input type="hidden" name="csrf" value="<%= csrf %>">
        <button class="icon-btn" type="submit" title="Chiqish" aria-label="Chiqish"><svg class="ico"><use href="#i-out"/></svg></button>
      </form>
    </div>
  </aside>

  <div class="main">
    <header class="top">
      <button class="icon-btn menu-btn" id="menuBtn" aria-label="Menyu"><svg class="ico"><use href="#i-menu"/></svg></button>
      <div><h1 id="pageTitle">Umumiy ko'rinish</h1><div class="sub" id="pageSub"></div></div>
      <div class="spacer"></div>
      <a class="icon-btn" href="<%= ctx %>/" target="_blank" rel="noopener" title="Saytni ochish" aria-label="Saytni ochish"><svg class="ico"><use href="#i-site"/></svg></a>
      <button class="icon-btn" id="refreshBtn" title="Yangilash" aria-label="Yangilash"><svg class="ico"><use href="#i-refresh"/></svg></button>
      <button class="icon-btn" id="themeBtn" title="Yorug'/qorong'u rejim" aria-label="Rejimni almashtirish"><svg class="ico"><use href="#i-moon"/></svg></button>
    </header>
    <main class="page" id="page"></main>
  </div>
</div>

<div class="modal-bg" id="modalBg" role="dialog" aria-modal="true"><div class="modal" id="modal"></div></div>
<div class="toasts" id="toasts" aria-live="polite"></div>

<script nonce="<%= nonce %>">
(function () {
  'use strict';
  const CTX = '<%= ctx %>';
  const CSRF = '<%= csrf %>';
  const IS_SUPER = <%= isSuper %>;
  const $ = (s, r = document) => r.querySelector(s);
  const page = $('#page');

  /* ---------------- yordamchilar ---------------- */
  function h(tag, attrs, ...kids) {
    const e = document.createElement(tag);
    if (attrs) for (const [k, v] of Object.entries(attrs)) {
      if (v == null || v === false) continue;
      if (k === 'class') e.className = v;
      else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
      else if (k === 'text') e.textContent = v;
      else e.setAttribute(k, v === true ? '' : v);
    }
    for (const k of kids.flat()) if (k != null && k !== false) e.append(k.nodeType ? k : document.createTextNode(String(k)));
    return e;
  }
  const svgNS = 'http://www.w3.org/2000/svg';
  function icon(id, cls = 'ico') { const s = document.createElementNS(svgNS, 'svg'); s.setAttribute('class', cls); const u = document.createElementNS(svgNS, 'use'); u.setAttribute('href', '#' + id); s.append(u); return s; }
  const vbadge = () => icon('i-verified', 'vbadge');
  const fmt = n => (n == null ? '0' : Number(n).toLocaleString('uz-UZ').replace(/,/g, ' '));
  const bytes = b => { b = Number(b) || 0; const u = ['B', 'KB', 'MB', 'GB', 'TB']; let i = 0; while (b >= 1024 && i < u.length - 1) { b /= 1024; i++; } return b.toFixed(i ? 1 : 0) + ' ' + u[i]; };
  const media = n => CTX + '/mgadmin/media?name=' + encodeURIComponent(n);
  const avatar = n => n ? media(n) : "data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23342e63'/%3E%3Ccircle cx='40' cy='31' r='14' fill='%237470a0'/%3E%3Crect x='16' y='52' width='48' height='30' rx='15' fill='%237470a0'/%3E%3C/svg%3E";
  const isVideo = t => t === 'VIDEO';

  async function api(path, body, background) {
    const opt = { headers: { 'Accept': 'application/json' }, credentials: 'same-origin' };
    if (background) opt.headers['X-Background'] = '1';
    if (body) {
      opt.method = 'POST';
      opt.headers['X-CSRF-Token'] = CSRF;
      opt.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      opt.body = new URLSearchParams(body).toString();
    }
    const r = await fetch(CTX + '/mgadmin/api' + path, opt);
    if (r.status === 401) { location.href = CTX + '/mgadmin/login'; throw new Error('401'); }
    let data = {};
    try { data = await r.json(); } catch (e) { }
    if (!r.ok) throw new Error(data.error || ('Xato: ' + r.status));
    return data;
  }

  function toast(msg, bad) {
    const t = h('div', { class: 'toast' + (bad ? ' err' : ''), role: 'status' }, msg);
    $('#toasts').append(t);
    setTimeout(() => t.remove(), 3800);
  }

  /* ---------------- modal oynalar ---------------- */
  const bg = $('#modalBg'), modal = $('#modal');
  function closeModal() { bg.classList.remove('open'); modal.replaceChildren(); }
  bg.addEventListener('click', e => { if (e.target === bg) closeModal(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && bg.classList.contains('open')) closeModal(); });

  /** Tasdiqlash oynasi. opts: {title, text, ok, danger, reason, confirmWord} → Promise<{reason}|null> */
  function confirmBox(opts) {
    return new Promise(res => {
      const reason = opts.reason ? h('textarea', { class: 'input', rows: 3, maxlength: 500, placeholder: 'Sabab (jurnalga yoziladi, ixtiyoriy)', style: 'height:auto;padding:10px 14px' }) : null;
      const word = opts.confirmWord ? h('input', { class: 'input', placeholder: opts.confirmWord, autocomplete: 'off' }) : null;
      const okBtn = h('button', { class: 'btn ' + (opts.danger ? 'danger' : 'primary'), type: 'button' }, opts.ok || 'Tasdiqlash');
      if (word) { okBtn.disabled = true; word.addEventListener('input', () => okBtn.disabled = word.value.trim().toLowerCase() !== opts.confirmWord.toLowerCase()); }
      okBtn.addEventListener('click', () => { const v = { reason: reason ? reason.value.trim() : '', word: word ? word.value.trim() : '' }; closeModal(); res(v); });
      modal.replaceChildren(
        h('h3', null, opts.title), h('p', null, opts.text),
        word ? h('div', { class: 'field' }, h('label', null, 'Tasdiqlash uchun username ni yozing: ' + opts.confirmWord), word) : null,
        reason ? h('div', { class: 'field' }, reason) : null,
        h('div', { class: 'row' }, h('button', { class: 'btn', type: 'button', onclick: () => { closeModal(); res(null); } }, 'Bekor qilish'), okBtn));
      bg.classList.add('open');
      (word || reason || okBtn).focus();
    });
  }

  /* ---------------- marshrutlash ---------------- */
  const routes = {
    dashboard: ['Umumiy ko\'rinish', 'Saytning oxirgi 30 kundagi holati', renderDashboard],
    users: ['Foydalanuvchilar', 'Qidirish, bloklash, tasdiqlash va o\'chirish', renderUsers],
    posts: ['Postlar', 'Barcha postlar, eng yangilari birinchi', renderPosts],
    comments: ['Izohlar', 'Barcha izohlar, eng yangilari birinchi', renderComments],
    complaints: ['Shikoyatlar', 'Foydalanuvchilar shikoyat qilgan postlar', renderComplaints],
    logs: ['Jurnal', 'Admin harakatlari va kirish urinishlari', renderLogs],
    system: ['Server holati', 'Xotira, disk, baza va xavfsizlik ko\'rsatkichlari', renderSystem],
    admins: ['Adminlar', 'Admin panelga kira oladiganlar', renderAdmins],
    settings: ['Parolni o\'zgartirish', 'Admin akkauntingiz xavfsizligi', renderSettings]
  };
  let current = null;
  function go() {
    let r = (location.hash || '#dashboard').slice(1).split('?')[0];
    if (!routes[r] || (r === 'admins' && !IS_SUPER)) r = 'dashboard';
    current = r;
    const [title, sub, fn] = routes[r];
    $('#pageTitle').textContent = title;
    $('#pageSub').textContent = sub;
    document.title = title + ' — MilliyGram Admin';
    document.querySelectorAll('.nav-item').forEach(b => b.toggleAttribute('aria-current', b.dataset.route === r) || b.removeAttribute('aria-current'));
    document.querySelectorAll('.nav-item').forEach(b => { if (b.dataset.route === r) b.setAttribute('aria-current', 'page'); });
    $('#nav').classList.remove('open');
    page.replaceChildren(h('div', { class: 'panel' }, h('div', { class: 'skel', style: 'width:40%' }), h('div', { class: 'skel', style: 'width:70%;margin-top:12px' }), h('div', { class: 'skel', style: 'width:55%;margin-top:12px' })));
    fn().catch(e => { if (e.message !== '401') page.replaceChildren(h('div', { class: 'panel empty' }, h('b', null, 'Ma\'lumotni yuklab bo\'lmadi'), e.message)); });
  }
  document.querySelectorAll('.nav-item').forEach(b => b.addEventListener('click', () => { location.hash = b.dataset.route; }));
  window.addEventListener('hashchange', go);
  $('#refreshBtn').addEventListener('click', go);
  $('#menuBtn').addEventListener('click', () => $('#nav').classList.toggle('open'));
  $('#themeBtn').addEventListener('click', () => {
    const t = document.documentElement.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', t);
    try { localStorage.setItem('mg_admin_theme', t); } catch (e) { }
    if (current === 'dashboard') go();
  });
  function setComplaintBadge(n) { const c = $('#cCount'); c.textContent = n > 99 ? '99+' : n; c.style.display = n > 0 ? 'inline-flex' : 'none'; }

  /* ================= Umumiy ko'rinish ================= */
  async function renderDashboard() {
    const d = await api('/stats');
    const t = d.totals;
    setComplaintBadge(t.complaintsOpen);
    const kpi = (v, l, d2, cls) => h('div', { class: 'kpi ' + (cls || '') }, h('div', { class: 'v' }, fmt(v)), h('div', { class: 'l' }, l), d2 ? h('div', { class: 'd' }, d2) : null);
    const plus = (n, w) => [h('b', null, '+' + fmt(n)), ' ' + w];
    const kpis = h('section', { class: 'kpis', 'aria-label': 'Asosiy ko\'rsatkichlar' },
      kpi(t.users, 'Foydalanuvchilar', plus(t.usersToday, 'oxirgi 24 soatda')),
      kpi(t.posts, 'Postlar', plus(t.postsToday, 'oxirgi 24 soatda')),
      kpi(t.complaintsOpen, 'Ko\'rib chiqilmagan shikoyat', t.complaintsOpen ? 'Shikoyatlar bo\'limida ko\'ring' : 'Hammasi ko\'rib chiqilgan', t.complaintsOpen ? 'warn' : ''),
      kpi(d.failedLogins24h, 'Admin panelga xato urinish', 'oxirgi 24 soatda', d.failedLogins24h > 10 ? 'bad' : ''));

    const chartBox = h('div', { class: 'chart' });
    const chartPanel = h('section', { class: 'panel' },
      h('div', { class: 'panel-h' }, h('h2', null, 'Faollik, 30 kun'), h('div', { class: 'spacer' }),
        h('div', { class: 'legend' }, h('span', null, h('i', { style: 'background:var(--violet)' }), 'Yangi foydalanuvchilar'), h('span', null, h('i', { style: 'background:var(--turq)' }), 'Yangi postlar'))),
      chartBox,
      h('div', { class: 'mini-stats' },
        h('div', null, h('b', null, fmt(t.comments)), h('span', null, 'izoh')),
        h('div', null, h('b', null, fmt(t.likes)), h('span', null, 'like')),
        h('div', null, h('b', null, fmt(t.messages)), h('span', null, 'chat xabari'))));

    const recent = h('section', { class: 'panel' }, h('div', { class: 'panel-h' }, h('h2', null, 'Yangi foydalanuvchilar'), h('div', { class: 'spacer' }), h('a', { href: '#users' }, 'Hammasi')),
      d.recentUsers.length ? h('ul', { class: 'people' }, d.recentUsers.map(u => h('li', null,
        h('img', { class: 'av', src: avatar(u.avatar), alt: '' }),
        h('div', { class: 'who' }, h('b', null, u.fullName || u.username, u.verified ? vbadge() : null), h('span', null, '@' + u.username + ', ' + (u.createdAt || ''))),
        u.status === 'BLOK' ? h('span', { class: 'pill bad' }, 'Bloklangan') : null))) : h('div', { class: 'empty' }, 'Hali foydalanuvchi yo\'q'));

    const top = h('section', { class: 'panel' }, h('div', { class: 'panel-h' }, h('h2', null, 'Eng ko\'p kuzatiladigan akkauntlar')),
      h('ul', { class: 'people' }, d.topUsers.map(u => h('li', null,
        h('img', { class: 'av', src: avatar(u.avatar), alt: '' }),
        h('div', { class: 'who' }, h('b', null, u.fullName || u.username, u.verified ? vbadge() : null), h('span', null, '@' + u.username)),
        h('div', { style: 'text-align:right;font-size:12.5px;color:var(--muted)' }, h('b', { style: 'display:block;color:var(--text);font-size:14px' }, fmt(u.followers)), 'kuzatuvchi')))));

    const side = h('div', { style: 'display:grid;gap:18px;align-content:start' }, recent);
    page.replaceChildren(kpis, h('div', { class: 'grid2' }, chartPanel, side), h('div', { class: 'grid2' }, top,
      h('section', { class: 'panel' }, h('div', { class: 'panel-h' }, h('h2', null, 'Qisqacha')),
        h('dl', { class: 'kv' },
          h('dt', null, 'Tasdiqlangan akkauntlar'), h('dd', null, fmt(t.verified)),
          h('dt', null, 'Bloklangan akkauntlar'), h('dd', null, fmt(t.blocked)),
          h('dt', null, 'Faol hikoyalar (24 soat)'), h('dd', null, fmt(t.storiesActive)),
          h('dt', null, 'Bugun chat yozganlar'), h('dd', null, fmt(t.chattersToday)),
          h('dt', null, 'Obunalar'), h('dd', null, fmt(t.follows))))));
    drawChart(chartBox, d.series.users, d.series.posts);
  }

  function drawChart(box, a, b) {
    const W = Math.max(300, Math.round(box.clientWidth || 760)), H = 240, P = { l: 34, r: 10, t: 14, b: 26 };
    const n = a.length, max = Math.max(4, ...a.map(x => x[1]), ...b.map(x => x[1]));
    const step = Math.ceil(max / 4), top = step * 4;
    const X = i => P.l + (W - P.l - P.r) * (n === 1 ? 0.5 : i / (n - 1));
    const Y = v => P.t + (H - P.t - P.b) * (1 - v / top);
    const css = getComputedStyle(document.documentElement);
    const col = { v: css.getPropertyValue('--violet').trim(), t: css.getPropertyValue('--turq').trim(), line: css.getPropertyValue('--line-soft').trim(), faint: css.getPropertyValue('--faint').trim() };
    const s = document.createElementNS(svgNS, 'svg');
    s.setAttribute('viewBox', `0 0 ${W} ${H}`); s.setAttribute('role', 'img');
    s.setAttribute('aria-label', 'Oxirgi 30 kunda yangi foydalanuvchilar va postlar soni');
    const add = (tag, at) => { const e = document.createElementNS(svgNS, tag); for (const k in at) e.setAttribute(k, at[k]); s.append(e); return e; };
    for (let i = 0; i <= 4; i++) {
      const y = Y(step * i);
      add('line', { x1: P.l, x2: W - P.r, y1: y, y2: y, stroke: col.line, 'stroke-width': 1 });
      const tx = add('text', { x: P.l - 8, y: y + 4, 'text-anchor': 'end', 'font-size': 11, fill: col.faint }); tx.textContent = step * i;
    }
    [0, Math.floor(n / 2), n - 1].forEach(i => { const tx = add('text', { x: X(i), y: H - 6, 'text-anchor': i === 0 ? 'start' : i === n - 1 ? 'end' : 'middle', 'font-size': 11, fill: col.faint }); tx.textContent = a[i][0].slice(5).replace('-', '.'); });
    const defs = add('defs', {});
    [['gv', col.v], ['gt', col.t]].forEach(([id, c]) => {
      const g = document.createElementNS(svgNS, 'linearGradient'); g.id = id; g.setAttribute('x1', 0); g.setAttribute('x2', 0); g.setAttribute('y1', 0); g.setAttribute('y2', 1);
      g.innerHTML = `<stop offset="0" stop-color="${c}" stop-opacity=".32"/><stop offset="1" stop-color="${c}" stop-opacity="0"/>`; defs.append(g);
    });
    const path = arr => arr.map((p, i) => (i ? 'L' : 'M') + X(i).toFixed(1) + ' ' + Y(p[1]).toFixed(1)).join(' ');
    [[b, col.t, 'gt'], [a, col.v, 'gv']].forEach(([arr, c, g]) => {
      add('path', { d: path(arr) + ` L${X(n - 1)} ${Y(0)} L${X(0)} ${Y(0)} Z`, fill: `url(#${g})` });
      add('path', { d: path(arr), fill: 'none', stroke: c, 'stroke-width': 2.2, 'stroke-linejoin': 'round', 'vector-effect': 'non-scaling-stroke' });
    });
    const guide = add('line', { y1: P.t, y2: H - P.b, stroke: col.faint, 'stroke-dasharray': '3 3', opacity: 0 });
    const tip = h('div', { class: 'tip' });
    box.replaceChildren(s, tip);
    s.addEventListener('mousemove', e => {
      const r = s.getBoundingClientRect(), x = (e.clientX - r.left) / r.width * W;
      const i = Math.max(0, Math.min(n - 1, Math.round((x - P.l) / (W - P.l - P.r) * (n - 1))));
      guide.setAttribute('x1', X(i)); guide.setAttribute('x2', X(i)); guide.setAttribute('opacity', 1);
      tip.replaceChildren(h('b', null, a[i][0]), h('br'), 'Foydalanuvchi: ' + a[i][1], h('br'), 'Post: ' + b[i][1]);
      tip.style.display = 'block'; tip.style.left = (X(i) / W * r.width) + 'px'; tip.style.top = (Math.min(Y(a[i][1]), Y(b[i][1])) / H * r.height) + 'px';
    });
    s.addEventListener('mouseleave', () => { tip.style.display = 'none'; guide.setAttribute('opacity', 0); });
  }

  /* ================= umumiy jadval ================= */
  function listView({ endpoint, filters, placeholder, columns, row, emptyText }) {
    const state = { q: '', page: 0, filter: filters ? filters[0][0] : null };
    const search = h('input', { class: 'input', type: 'search', placeholder, 'aria-label': placeholder });
    const tableWrap = h('div', { class: 'table-wrap' });
    const pager = h('div', { class: 'pager' });
    let timer = null;
    search.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(() => { state.q = search.value.trim(); state.page = 0; load(); }, 300); });
    const seg = filters ? h('div', { class: 'seg', role: 'group' }, filters.map(([k, l]) => h('button', { type: 'button', 'aria-pressed': String(k === state.filter), onclick: e => {
      state.filter = k; state.page = 0; seg.querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', 'false')); e.currentTarget.setAttribute('aria-pressed', 'true'); load(); } }, l))) : null;
    page.replaceChildren(h('div', { class: 'toolbar' }, h('label', { class: 'search' }, icon('i-search'), search), seg), tableWrap, pager);
    async function load() {
      const qs = new URLSearchParams({ q: state.q, page: state.page }); if (state.filter) qs.set('filter', state.filter);
      const d = await api(endpoint + '?' + qs);
      if (!d.items.length) { tableWrap.replaceChildren(h('div', { class: 'empty' }, h('b', null, emptyText), state.q ? 'Boshqa so\'z bilan qidirib ko\'ring.' : '')); pager.replaceChildren(); return; }
      tableWrap.replaceChildren(h('table', null, h('thead', null, h('tr', null, columns.map(c => h('th', { class: c.num ? 'num' : null, scope: 'col' }, c.t)))),
        h('tbody', null, d.items.map(it => row(it, load)))));
      const pages = Math.max(1, Math.ceil(d.total / d.size));
      pager.replaceChildren(h('span', null, `Jami ${fmt(d.total)} ta, ${state.page + 1}/${pages}-sahifa`),
        h('button', { class: 'btn sm', disabled: state.page === 0, onclick: () => { state.page--; load(); } }, 'Oldingi'),
        h('button', { class: 'btn sm', disabled: state.page + 1 >= pages, onclick: () => { state.page++; load(); } }, 'Keyingi'));
    }
    return load();
  }

  async function act(path, params, okMsg, reload) {
    try { await api(path, params); toast(okMsg); if (reload) reload(); } catch (e) { toast(e.message, true); }
  }

  /* ================= Foydalanuvchilar ================= */
  function renderUsers() {
    return listView({
      endpoint: '/users', placeholder: 'Username yoki ism bo\'yicha qidirish', emptyText: 'Foydalanuvchi topilmadi',
      filters: [['all', 'Hammasi'], ['active', 'Faol'], ['blocked', 'Bloklangan'], ['verified', 'Tasdiqlangan']],
      columns: [{ t: 'Foydalanuvchi' }, { t: 'Holat' }, { t: 'Post', num: 1 }, { t: 'Kuzatuvchi', num: 1 }, { t: 'Ro\'yxatdan o\'tgan' }, { t: '' }],
      row: (u, reload) => {
        const blocked = u.status === 'BLOK';
        return h('tr', null,
          h('td', null, h('div', { style: 'display:flex;align-items:center;gap:10px' }, h('img', { class: 'av', src: avatar(u.avatar), alt: '' }),
            h('div', { class: 'who' }, h('b', null, u.fullName || u.username, u.verified ? vbadge() : null), h('span', null, '@' + u.username + ', #' + u.id)))),
          h('td', null, blocked ? h('span', { class: 'pill bad' }, 'Bloklangan') : h('span', { class: 'pill ok' }, 'Faol')),
          h('td', { class: 'num' }, fmt(u.posts)), h('td', { class: 'num' }, fmt(u.followers)),
          h('td', { style: 'color:var(--muted)' }, u.createdAt || ''),
          h('td', null, h('div', { class: 'actions' },
            h('button', { class: 'btn sm', onclick: () => act(u.verified ? '/user/unverify' : '/user/verify', { id: u.id }, u.verified ? 'Belgi olib tashlandi' : 'Tasdiqlangan belgi berildi', reload) }, u.verified ? 'Belgini olish' : 'Tasdiqlash'),
            blocked
              ? h('button', { class: 'btn sm ok', onclick: () => act('/user/unblock', { id: u.id }, 'Blokdan chiqarildi', reload) }, 'Blokdan chiqarish')
              : h('button', { class: 'btn sm danger', onclick: async () => {
                  const r = await confirmBox({ title: '@' + u.username + ' ni bloklash', text: 'Foydalanuvchi darhol tizimdan chiqariladi va qayta kira olmaydi. Keyin blokdan chiqarish mumkin.', ok: 'Bloklash', danger: 1, reason: 1 });
                  if (r) act('/user/block', { id: u.id, reason: r.reason }, 'Foydalanuvchi bloklandi', reload);
                } }, 'Bloklash'),
            h('button', { class: 'btn sm danger', title: 'Butunlay o\'chirish', onclick: async () => {
              const r = await confirmBox({ title: '@' + u.username + ' ni butunlay o\'chirish', text: 'Barcha postlari, izohlari, xabarlari va fayllari o\'chadi. Bu amalni qaytarib bo\'lmaydi.', ok: 'Butunlay o\'chirish', danger: 1, reason: 1, confirmWord: u.username });
              if (r) act('/user/delete', { id: u.id, confirm: r.word, reason: r.reason }, 'Foydalanuvchi o\'chirildi', reload);
            } }, 'O\'chirish'))));
      }
    });
  }

  /* ================= Postlar ================= */
  function postThumb(p) {
    if (p.mediaUrl && !isVideo(p.mediaType)) return h('img', { class: 'thumb', src: media(p.mediaUrl), alt: '', loading: 'lazy' });
    if (p.mediaUrl) return h('video', { class: 'thumb', src: media(p.mediaUrl) + '#t=0.1', muted: true, preload: 'metadata' });
    return h('div', { class: 'thumb txt' }, 'Matn');
  }
  function renderPosts() {
    return listView({
      endpoint: '/posts', placeholder: 'Sarlavha, matn yoki muallif bo\'yicha qidirish', emptyText: 'Post topilmadi',
      columns: [{ t: '' }, { t: 'Post' }, { t: 'Muallif' }, { t: 'Like', num: 1 }, { t: 'Izoh', num: 1 }, { t: 'Ko\'rish', num: 1 }, { t: 'Sana' }, { t: '' }],
      row: (p, reload) => h('tr', null,
        h('td', { style: 'width:62px' }, postThumb(p)),
        h('td', null, h('div', { class: 'clip' }, h('b', null, p.title || ''), ' ', p.content || ''),
          p.complaints ? h('span', { class: 'pill warn', style: 'margin-top:6px' }, p.complaints + ' ta shikoyat') : null),
        h('td', null, '@' + (p.username || 'o\'chirilgan')),
        h('td', { class: 'num' }, fmt(p.likes)), h('td', { class: 'num' }, fmt(p.comments)), h('td', { class: 'num' }, fmt(p.views)),
        h('td', { style: 'color:var(--muted);white-space:nowrap' }, p.createdAt),
        h('td', null, h('div', { class: 'actions' }, h('button', { class: 'btn sm danger', onclick: async () => {
          const r = await confirmBox({ title: 'Postni o\'chirish', text: 'Post, uning izohlari va like\'lari o\'chadi. Muallifga xabar berilmaydi.', ok: 'O\'chirish', danger: 1, reason: 1 });
          if (r) act('/post/delete', { id: p.id, reason: r.reason }, 'Post o\'chirildi', reload);
        } }, 'O\'chirish'))))
    });
  }

  /* ================= Izohlar ================= */
  function renderComments() {
    return listView({
      endpoint: '/comments', placeholder: 'Izoh matni yoki muallif bo\'yicha qidirish', emptyText: 'Izoh topilmadi',
      columns: [{ t: 'Izoh' }, { t: 'Muallif' }, { t: 'Post' }, { t: 'Like', num: 1 }, { t: 'Sana' }, { t: '' }],
      row: (c, reload) => h('tr', null,
        h('td', null, h('div', { class: 'clip' }, c.content)),
        h('td', null, '@' + (c.username || 'o\'chirilgan')),
        h('td', { style: 'color:var(--muted)' }, '#' + c.postId),
        h('td', { class: 'num' }, fmt(c.likes)),
        h('td', { style: 'color:var(--muted);white-space:nowrap' }, c.createdAt),
        h('td', null, h('div', { class: 'actions' }, h('button', { class: 'btn sm danger', onclick: async () => {
          const r = await confirmBox({ title: 'Izohni o\'chirish', text: 'Izoh va unga yozilgan javoblar o\'chadi.', ok: 'O\'chirish', danger: 1, reason: 1 });
          if (r) act('/comment/delete', { id: c.id, reason: r.reason }, 'Izoh o\'chirildi', reload);
        } }, 'O\'chirish'))))
    });
  }

  /* ================= Shikoyatlar ================= */
  async function renderComplaints() {
    let status = 'open';
    const seg = h('div', { class: 'seg', role: 'group' },
      h('button', { type: 'button', 'aria-pressed': 'true', onclick: e => sw('open', e) }, 'Ko\'rib chiqilmagan'),
      h('button', { type: 'button', 'aria-pressed': 'false', onclick: e => sw('closed', e) }, 'Yopilgan'));
    const list = h('div', { class: 'cases' });
    page.replaceChildren(h('div', { class: 'toolbar' }, seg), list);
    function sw(s, e) { status = s; seg.querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', 'false')); e.currentTarget.setAttribute('aria-pressed', 'true'); load(); }
    async function load() {
      const d = await api('/complaints?status=' + status);
      if (status === 'open') setComplaintBadge(d.items.reduce((a, x) => a + Number(x.count), 0));
      if (!d.items.length) { list.replaceChildren(h('div', { class: 'panel empty' }, h('b', null, status === 'open' ? 'Yangi shikoyat yo\'q' : 'Yopilgan shikoyat yo\'q'), status === 'open' ? 'Foydalanuvchilar post ustidan shikoyat qilsa, shu yerda paydo bo\'ladi.' : '')); return; }
      list.replaceChildren(...d.items.map(c => {
        const m = c.mediaUrl && !isVideo(c.mediaType) ? h('img', { class: 'media', src: media(c.mediaUrl), alt: '' })
          : c.mediaUrl ? h('video', { class: 'media', src: media(c.mediaUrl) + '#t=0.1', muted: true, preload: 'metadata' })
          : h('div', { class: 'media txt' }, c.postExists ? (c.content || '').slice(0, 80) : 'Post o\'chirilgan');
        const reasons = String(c.reasons || '').split(' ¦ ').filter(Boolean);
        return h('article', { class: 'case' }, m,
          h('div', null, h('h3', null, c.postExists ? (c.title || 'Sarlavhasiz post') : 'Post #' + c.postId + ' (o\'chirilgan)'),
            h('div', { class: 'meta' }, (c.author ? 'Muallif @' + c.author + ', ' : '') + 'oxirgi shikoyat ' + c.lastAt),
            c.postExists && c.content ? h('div', { class: 'clip', style: 'margin-bottom:10px' }, c.content) : null,
            h('div', { class: 'reasons' }, reasons.map(r => h('span', null, r))),
            status === 'open' ? h('div', { class: 'actions', style: 'justify-content:flex-start' },
              c.postExists ? h('button', { class: 'btn sm danger', onclick: async () => {
                const r = await confirmBox({ title: 'Postni o\'chirish', text: 'Post o\'chiriladi va barcha shikoyatlar "hal qilindi" deb belgilanadi.', ok: 'Postni o\'chirish', danger: 1 });
                if (r) act('/complaint/resolve', { id: c.postId }, 'Post o\'chirildi, shikoyat yopildi', load);
              } }, 'Postni o\'chirish') : null,
              h('button', { class: 'btn sm', onclick: () => act('/complaint/dismiss', { id: c.postId }, 'Shikoyat rad etildi', load) }, 'Rad etish'),
              c.authorId ? h('button', { class: 'btn sm', onclick: () => { location.hash = 'users'; } }, 'Muallifni ko\'rish') : null)
              : h('span', { class: 'pill ' + (c.status === 'RESOLVED' ? 'ok' : 'mute'), style: 'margin-top:10px' }, c.status === 'RESOLVED' ? 'Post o\'chirilgan' : 'Rad etilgan')),
          h('div', { class: 'cnt' }, c.count, h('small', null, 'shikoyat')));
      }));
    }
    return load();
  }

  /* ================= Jurnal ================= */
  async function renderLogs() {
    let type = '', pg = 0;
    const seg = h('div', { class: 'seg', role: 'group' }, [['', 'Hammasi'], ['LOGIN', 'Kirishlar'], ['ACTION', 'Harakatlar'], ['SECURITY', 'Xavfsizlik']].map(([k, l], i) =>
      h('button', { type: 'button', 'aria-pressed': String(i === 0), onclick: e => { type = k; pg = 0; seg.querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', 'false')); e.currentTarget.setAttribute('aria-pressed', 'true'); load(); } }, l)));
    const wrap = h('div', { class: 'table-wrap' }), pager = h('div', { class: 'pager' });
    page.replaceChildren(h('div', { class: 'toolbar' }, seg), wrap, pager);
    const label = { PASSWORD: 'Parol bosqichi', SUCCESS: 'Kirdi', LOGOUT: 'Chiqdi', LOCKED: 'Bloklangan akkaunt', IP_BLOCKED: 'IP bloklangan', TOTP: '2FA kodi', USER_BLOCK: 'Foydalanuvchini blokladi',
      USER_UNBLOCK: 'Blokdan chiqardi', USER_VERIFY: 'Tasdiq belgisi berdi', USER_UNVERIFY: 'Tasdiq belgisini oldi', USER_DELETE: 'Foydalanuvchini o\'chirdi', POST_DELETE: 'Postni o\'chirdi',
      COMMENT_DELETE: 'Izohni o\'chirdi', COMPLAINT_DISMISS: 'Shikoyatni rad etdi', COMPLAINT_RESOLVE: 'Shikoyat bo\'yicha postni o\'chirdi', PASSWORD_CHANGE: 'Parolni o\'zgartirish',
      ADMIN_CREATE: 'Admin yaratdi', ADMIN_ENABLE: 'Adminni yoqdi', ADMIN_DISABLE: 'Adminni o\'chirdi', ACCOUNT_LOCKED: 'Akkaunt bloklandi', SETUP: 'Bosh admin yaratildi' };
    async function load() {
      const d = await api('/logs?' + new URLSearchParams({ type, page: pg }));
      if (!d.items.length) { wrap.replaceChildren(h('div', { class: 'empty' }, h('b', null, 'Yozuv yo\'q'))); pager.replaceChildren(); return; }
      wrap.replaceChildren(h('table', null, h('thead', null, h('tr', null, ['Vaqt', 'Admin', 'Harakat', 'Obyekt', 'Tafsilot', 'IP'].map(t => h('th', { scope: 'col' }, t)))),
        h('tbody', null, d.items.map(l => h('tr', null,
          h('td', { style: 'white-space:nowrap;color:var(--muted)' }, l.at),
          h('td', null, l.admin || '—'),
          h('td', null, h('span', { class: 'pill ' + (l.success ? (l.type === 'SECURITY' ? 'warn' : 'ok') : 'bad') }, label[l.action] || l.action)),
          h('td', null, l.target || ''),
          h('td', null, h('div', { class: 'clip', title: l.ua || '' }, l.details || '')),
          h('td', { style: 'white-space:nowrap;color:var(--muted)' }, l.ip || ''))))));
      const pages = Math.max(1, Math.ceil(d.total / d.size));
      pager.replaceChildren(h('span', null, `Jami ${fmt(d.total)} ta yozuv, ${pg + 1}/${pages}-sahifa`),
        h('button', { class: 'btn sm', disabled: pg === 0, onclick: () => { pg--; load(); } }, 'Oldingi'),
        h('button', { class: 'btn sm', disabled: pg + 1 >= pages, onclick: () => { pg++; load(); } }, 'Keyingi'));
    }
    return load();
  }

  /* ================= Server holati ================= */
  async function renderSystem() {
    const s = await api('/system');
    const memPct = s.memMax ? Math.round(s.memUsed / s.memMax * 100) : 0;
    const diskUsed = s.diskTotal - s.diskFree, diskPct = s.diskTotal ? Math.round(diskUsed / s.diskTotal * 100) : 0;
    const up = Math.floor(s.uptimeMs / 60000), upTxt = up >= 1440 ? Math.floor(up / 1440) + ' kun ' + Math.floor(up % 1440 / 60) + ' soat' : Math.floor(up / 60) + ' soat ' + (up % 60) + ' daqiqa';
    const meter = p => h('div', { class: 'meter' + (p > 80 ? ' hi' : '') }, h('i', { style: 'width:' + p + '%' }));
    page.replaceChildren(
      h('div', { class: 'sys' },
        h('section', { class: 'panel' }, h('div', { class: 'lbl' }, 'Java xotirasi'), h('div', { class: 'big' }, memPct + '%'), meter(memPct), h('div', { class: 'lbl', style: 'margin-top:8px' }, bytes(s.memUsed) + ' / ' + bytes(s.memMax))),
        h('section', { class: 'panel' }, h('div', { class: 'lbl' }, 'Disk'), h('div', { class: 'big' }, diskPct + '%'), meter(diskPct), h('div', { class: 'lbl', style: 'margin-top:8px' }, bytes(s.diskFree) + ' bo\'sh, jami ' + bytes(s.diskTotal))),
        h('section', { class: 'panel' }, h('div', { class: 'lbl' }, 'Ishlab turibdi'), h('div', { class: 'big' }, upTxt), h('div', { class: 'lbl', style: 'margin-top:8px' }, 'Server yuklamasi: ' + (s.load >= 0 ? s.load.toFixed(2) : '—') + ', ' + s.cpus + ' ta protsessor'))),
      h('div', { class: 'grid2' },
        h('section', { class: 'panel' }, h('div', { class: 'panel-h' }, h('h2', null, 'Dasturlar')),
          h('dl', { class: 'kv' }, h('dt', null, 'Java'), h('dd', null, s.javaVersion), h('dt', null, 'Server'), h('dd', null, s.server), h('dt', null, 'Operatsion tizim'), h('dd', null, s.os),
            h('dt', null, 'Baza'), h('dd', null, s.dbVersion), h('dt', null, 'Baza hajmi'), h('dd', null, s.dbSize), h('dt', null, 'Bazaga ulanishlar'), h('dd', null, s.connections))),
        h('section', { class: 'panel' }, h('div', { class: 'panel-h' }, h('h2', null, 'Fayllar va xavfsizlik')),
          h('dl', { class: 'kv' }, h('dt', null, 'Yuklangan fayllar'), h('dd', null, fmt(s.uploadFiles) + ' ta'), h('dt', null, 'Ularning hajmi'), h('dd', null, bytes(s.uploadBytes)),
            h('dt', null, 'Xato kirish urinishlari (24 soat)'), h('dd', { style: s.failedLogins24h > 10 ? 'color:var(--pom)' : '' }, fmt(s.failedLogins24h)),
            h('dt', null, 'Sizning IP manzilingiz'), h('dd', null, s.ip), h('dt', null, 'Sessiya muddati'), h('dd', null, '30 daqiqa harakatsizlikdan keyin tugaydi')))));
  }

  /* ================= Adminlar ================= */
  async function renderAdmins() {
    const d = await api('/admins');
    const u = h('input', { class: 'input', placeholder: 'Login', maxlength: 40, autocomplete: 'off' });
    const p = h('input', { class: 'input', type: 'password', placeholder: 'Parol (kamida 12 belgi)', maxlength: 200, autocomplete: 'new-password' });
    const create = h('button', { class: 'btn primary', type: 'submit' }, 'Admin qo\'shish');
    const form = h('form', { class: 'panel', style: 'display:grid;grid-template-columns:1fr 1fr auto;gap:10px;align-items:end;margin-bottom:18px' },
      h('div', { class: 'field', style: 'margin:0' }, h('label', null, 'Yangi admin logini'), u), h('div', { class: 'field', style: 'margin:0' }, h('label', null, 'Vaqtinchalik parol'), p), create);
    form.addEventListener('submit', async e => {
      e.preventDefault(); create.disabled = true;
      try {
        const r = await api('/admins/create', { username: u.value.trim(), password: p.value });
        const qr = h('div', { class: 'qr' }); qr.innerHTML = r.qrSvg;   // server yaratgan SVG
        modal.replaceChildren(h('h3', null, 'Admin yaratildi'), h('p', null, 'Yangi admin bu QR kodni Google Authenticator ilovasida skanerlashi kerak. QR kod faqat hozir ko\'rsatiladi.'), qr,
          h('code', null, r.secret), h('div', { class: 'row' }, h('button', { class: 'btn primary', onclick: () => { closeModal(); go(); } }, 'Tayyor')));
        bg.classList.add('open');
      } catch (er) { toast(er.message, true); } finally { create.disabled = false; }
    });
    page.replaceChildren(form, h('div', { class: 'table-wrap' }, h('table', null,
      h('thead', null, h('tr', null, ['Login', 'Rol', 'Holat', 'Oxirgi kirish', 'IP', ''].map(t => h('th', { scope: 'col' }, t)))),
      h('tbody', null, d.items.map(a => h('tr', null,
        h('td', null, h('b', null, a.username), a.me ? h('span', { class: 'pill mute', style: 'margin-left:8px' }, 'Siz') : null),
        h('td', null, a.superAdmin ? 'Bosh admin' : 'Admin'),
        h('td', null, !a.enabled ? h('span', { class: 'pill bad' }, 'O\'chirilgan') : a.locked ? h('span', { class: 'pill warn' }, 'Vaqtincha bloklangan') : h('span', { class: 'pill ok' }, 'Faol')),
        h('td', { style: 'color:var(--muted)' }, a.lastLoginAt || 'Hali kirmagan'),
        h('td', { style: 'color:var(--muted)' }, a.lastLoginIp || ''),
        h('td', null, a.me ? null : h('div', { class: 'actions' }, h('button', { class: 'btn sm ' + (a.enabled ? 'danger' : 'ok'), onclick: () => act('/admins/toggle', { id: a.id }, a.enabled ? 'Admin o\'chirildi' : 'Admin yoqildi', go) }, a.enabled ? 'O\'chirish' : 'Yoqish')))))))));
  }

  /* ================= Parol ================= */
  async function renderSettings() {
    const cur = h('input', { class: 'input', type: 'password', autocomplete: 'current-password', required: true });
    const nw = h('input', { class: 'input', type: 'password', autocomplete: 'new-password', minlength: 12, required: true });
    const nw2 = h('input', { class: 'input', type: 'password', autocomplete: 'new-password', minlength: 12, required: true });
    const code = h('input', { class: 'input code', inputmode: 'numeric', maxlength: 7, autocomplete: 'one-time-code', required: true });
    const btn = h('button', { class: 'btn primary', type: 'submit' }, 'Parolni o\'zgartirish');
    const f = h('form', { class: 'panel', style: 'max-width:460px' },
      h('div', { class: 'field' }, h('label', null, 'Joriy parol'), cur),
      h('div', { class: 'field' }, h('label', null, 'Yangi parol: kamida 12 belgi, katta-kichik harf, raqam va belgi'), nw),
      h('div', { class: 'field' }, h('label', null, 'Yangi parolni takrorlang'), nw2),
      h('div', { class: 'field' }, h('label', null, 'Google Authenticator kodi'), code), btn);
    f.addEventListener('submit', async e => {
      e.preventDefault();
      if (nw.value !== nw2.value) { toast('Yangi parollar bir xil emas', true); return; }
      btn.disabled = true;
      try { await api('/me/password', { current: cur.value, new: nw.value, code: code.value }); toast('Parol o\'zgartirildi'); f.reset(); }
      catch (er) { toast(er.message, true); } finally { btn.disabled = false; }
    });
    page.replaceChildren(f);
  }

  go();
  // shikoyatlar sonini har 2 daqiqada yangilab turamiz
  setInterval(() => { if (document.visibilityState === 'visible') api('/stats', null, true).then(d => setComplaintBadge(d.totals.complaintsOpen)).catch(() => { }); }, 120000);
})();
</script>
</body>
</html>
