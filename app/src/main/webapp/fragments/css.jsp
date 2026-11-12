<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
    /* ============ Dizayn tokenlari ============ */
    :root {
        --page-bg: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #d946ef 100%);
        --bg-glass: rgba(255, 255, 255, 0.9);
        --bg-sidebar: rgba(255, 255, 255, 0.6);
        --bg-header: rgba(255, 255, 255, 0.4);
        --surface: #FFFFFF;
        --surface-2: #F8FAFC;
        --hover: #F1F5F9;
        --text-main: #0F172A;
        --text-muted: #64748B;
        --accent-pink: #FF3366;
        --accent-blue: #0095F6;
        --border-color: #E2E8F0;
        --bubble-in: #FFFFFF;
        --overlay: rgba(15, 23, 42, 0.62);
        --shadow-sm: 0 4px 12px rgba(0, 0, 0, 0.04);
        --shadow-lg: 0 18px 44px rgba(0, 0, 0, 0.22);
        --ring-seen: #c7c7cc;
        color-scheme: light;
    }
    html[data-theme="dark"] {
        --page-bg: linear-gradient(135deg, #1b1a4a 0%, #2e2477 50%, #4a1d7a 100%);
        --bg-glass: rgba(18, 20, 34, 0.93);
        --bg-sidebar: rgba(255, 255, 255, 0.025);
        --bg-header: rgba(255, 255, 255, 0.03);
        --surface: #1a1e33;
        --surface-2: #222742;
        --hover: #2a3050;
        --text-main: #E9ECF6;
        --text-muted: #8F97B6;
        --border-color: #2b3150;
        --bubble-in: #262b47;
        --overlay: rgba(2, 4, 12, 0.7);
        --shadow-sm: 0 4px 14px rgba(0, 0, 0, 0.3);
        --shadow-lg: 0 18px 44px rgba(0, 0, 0, 0.55);
        --ring-seen: #4a5073;
        color-scheme: dark;
    }

    *, *::before, *::after { box-sizing: border-box; }
    html { background: #6366f1; }
    body {
        margin: 0; padding: 24px; min-height: 100vh;
        background: var(--page-bg) fixed;
        font-family: 'Inter', sans-serif; color: var(--text-main);
        transition: background .3s;
    }
    a { color: inherit; }
    button { font-family: inherit; }
    img, video { max-width: 100%; }
    ::-webkit-scrollbar { width: 8px; height: 8px; }
    ::-webkit-scrollbar-thumb { background: rgba(120, 130, 160, .35); border-radius: 8px; }

    .text-muted { color: var(--text-muted); }
    .text-center { text-align: center; }
    .small { font-size: 12.5px; }
    .p-3 { padding: 12px; } .p-4 { padding: 20px; } .py-5 { padding-top: 40px; padding-bottom: 40px; }
    .w-100 { width: 100%; }
    .text-truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .brand-gradient { background: linear-gradient(135deg, #6366f1, #a855f7 55%, #d946ef); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; color: transparent; }

    /* ============ Asosiy maket ============ */
    .dashboard-container {
        width: 100%; max-width: 1320px; height: 92vh; margin: 0 auto;
        background: var(--bg-glass); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
        border-radius: 28px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
        display: grid; grid-template-columns: 280px minmax(0, 1fr); overflow: hidden;
        border: 1px solid rgba(255, 255, 255, 0.18);
    }
    .dashboard-content { position: relative; display: flex; flex-direction: column; overflow: hidden; min-width: 0; }
    .scrollable-main-area { flex: 1; overflow-y: auto; padding: 24px 32px; }
    .page-title { display: inline-block; margin: 0 0 18px; padding: 7px 16px; border-radius: 14px; background: var(--bg-glass); font-weight: 700; font-size: 16px; }

    /* ============ Yon panel ============ */
    .dashboard-sidebar {
        position: relative; display: flex; flex-direction: column; overflow: hidden;
        background: var(--bg-sidebar); border-right: 1px solid var(--border-color);
    }
    .sb-top { flex: 1; overflow-y: auto; padding: 28px 24px 8px; }
    .sb-bottom { padding: 12px 24px 24px; flex-shrink: 0; }

    .brand-logo-area { display: flex; align-items: center; gap: 10px; font-size: 22px; font-weight: 800; margin-bottom: 22px; text-decoration: none; }
    .logo-mark { width: 38px; height: 38px; display: inline-flex; flex-shrink: 0; filter: drop-shadow(0 4px 8px rgba(124, 58, 237, .35)); }
    .logo-mark .logo-svg { width: 100%; height: 100%; }

    .sidebar-profile-box { text-align: center; margin-bottom: 18px; }
    .sidebar-avatar-link { text-decoration: none; color: inherit; display: block; }
    .sidebar-avatar { width: 84px; height: 84px; border-radius: 50%; object-fit: cover; border: 3px solid var(--surface); box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12); margin: 0 auto 10px; display: block; background: var(--hover); }
    .sidebar-name { font-weight: 700; font-size: 16px; margin: 0; }
    .sidebar-handle { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

    .sidebar-stats { display: flex; justify-content: space-around; text-align: center; margin: 14px 0 18px; padding: 8px 0; border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color); }
    .stat-item { background: none; border: none; color: inherit; text-decoration: none; cursor: pointer; padding: 6px 8px; border-radius: 10px; transition: background .15s; }
    .stat-item:hover { background: var(--hover); }
    .stat-num { font-weight: 700; font-size: 15px; display: block; }
    .stat-label { font-size: 11px; color: var(--text-muted); }

    .sidebar-nav { display: flex; flex-direction: column; gap: 6px; }
    .nav-link-item { display: flex; align-items: center; gap: 14px; padding: 11px 14px; border-radius: 12px; color: var(--text-muted); font-weight: 500; text-decoration: none; transition: all 0.2s; }
    .nav-link-item i { font-size: 18px; width: 22px; text-align: center; }
    .nav-link-item:hover, .nav-link-item.active { background: var(--surface); color: var(--text-main); box-shadow: var(--shadow-sm); }

    /* Settings tugmasi: + POST ning "teskarisi" — qizil hoshiya, ichi oq */
    .settings-btn {
        width: 100%; display: inline-flex; align-items: center; justify-content: center; gap: 8px;
        padding: 10px 20px; border-radius: 20px; font-weight: 600; font-size: 13px; cursor: pointer;
        background: var(--surface); color: var(--accent-pink); border: 2px solid var(--accent-pink);
        box-shadow: 0 4px 14px rgba(255, 51, 102, 0.22); transition: all .2s;
    }
    .settings-btn:hover, .settings-btn.open { background: var(--accent-pink); color: #fff; }
    .settings-btn i { transition: transform .4s; }
    .settings-btn.open i { transform: rotate(90deg); }

    /* Settings paneli: pastdan tepaga qarab ochiladi, yon panel ichida qoladi */
    .settings-pop {
        position: absolute; left: 14px; right: 14px; bottom: 78px; z-index: 30;
        background: var(--surface); border: 1px solid var(--border-color); border-radius: 18px;
        box-shadow: var(--shadow-lg); overflow-y: auto; padding: 6px;
        visibility: hidden; opacity: 0; transform: translateY(16px); clip-path: inset(100% 0 0 0 round 18px);
        transition: clip-path .4s cubic-bezier(.2, .8, .2, 1), transform .4s cubic-bezier(.2, .8, .2, 1), opacity .25s, visibility 0s .4s;
    }
    .settings-pop.open { visibility: visible; opacity: 1; transform: none; clip-path: inset(0 0 0 0 round 18px); transition-delay: 0s; }
    .sp-item { display: flex; align-items: center; gap: 12px; width: 100%; padding: 11px 12px; border: none; background: none; border-radius: 12px; color: var(--text-main); font-size: 13.5px; font-weight: 500; cursor: pointer; text-align: left; }
    .sp-item:hover { background: var(--hover); }
    .sp-item > i:first-child { width: 20px; text-align: center; color: var(--text-muted); font-size: 16px; }
    .sp-item .sp-chev { margin-left: auto; color: var(--text-muted); font-size: 11px; }
    .sp-item.danger, .sp-item.danger > i:first-child { color: var(--accent-pink); }
    .sp-sep { height: 1px; background: var(--border-color); margin: 6px 8px; }
    .sp-switch { margin-left: auto; width: 36px; height: 20px; border-radius: 20px; background: var(--border-color); position: relative; transition: background .25s; flex-shrink: 0; }
    .sp-switch::after { content: ''; position: absolute; top: 2px; left: 2px; width: 16px; height: 16px; border-radius: 50%; background: #fff; box-shadow: 0 1px 3px rgba(0, 0, 0, .3); transition: transform .25s; }
    html[data-theme="dark"] .sp-switch { background: var(--accent-blue); }
    html[data-theme="dark"] .sp-switch::after { transform: translateX(16px); }

    /* Yon panel ichidagi ro'yxat (Following / Followers) */
    .sb-list-panel { position: absolute; inset: 0; z-index: 40; background: var(--surface); display: flex; flex-direction: column; transform: translateX(100%); visibility: hidden; transition: transform .32s cubic-bezier(.2, .8, .2, 1), visibility 0s .32s; }
    .sb-list-panel.open { transform: none; visibility: visible; transition-delay: 0s; }
    .sb-list-head { display: flex; align-items: center; gap: 10px; padding: 16px 14px; border-bottom: 1px solid var(--border-color); font-weight: 700; font-size: 15px; }
    .icon-btn { width: 34px; height: 34px; border-radius: 50%; border: none; background: transparent; color: var(--text-main); cursor: pointer; font-size: 16px; display: inline-flex; align-items: center; justify-content: center; }
    .icon-btn:hover { background: var(--hover); }
    .sb-list-search { position: relative; padding: 10px 12px 4px; }
    .sb-list-search i { position: absolute; left: 24px; top: 50%; transform: translateY(-30%); font-size: 12px; color: var(--text-muted); }
    .sb-list-search input { width: 100%; padding: 8px 12px 8px 34px; border-radius: 12px; border: none; background: var(--hover); color: var(--text-main); font-size: 13px; outline: none; font-family: inherit; }
    .sb-list-body { flex: 1; overflow-y: auto; padding: 6px 8px 12px; }
    .fl-row { display: flex; align-items: center; gap: 10px; padding: 8px; border-radius: 12px; }
    .fl-row:hover { background: var(--hover); }
    .fl-avatar { width: 42px; height: 42px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: var(--hover); }
    .fl-info { flex: 1; min-width: 0; text-decoration: none; color: inherit; }
    .fl-name { font-weight: 600; font-size: 13.5px; }
    .fl-sub { font-size: 11.5px; color: var(--text-muted); }
    .fl-btn { flex-shrink: 0; padding: 6px 12px; border-radius: 9px; border: none; font-size: 12px; font-weight: 600; cursor: pointer; background: var(--hover); color: var(--text-main); border: 1px solid var(--border-color); }
    .fl-btn.primary { background: var(--accent-blue); border-color: var(--accent-blue); color: #fff; }
    .fl-btn:disabled { opacity: .6; cursor: default; }

    /* ============ Yuqori panel ============ */
    .top-header-bar { padding: 18px 32px; display: flex; align-items: center; justify-content: space-between; gap: 16px; border-bottom: 1px solid var(--border-color); background: var(--bg-header); flex-shrink: 0; }
    .top-search-box { position: relative; width: 380px; max-width: 100%; }
    .top-search-box input { width: 100%; padding: 10px 16px 10px 42px; background: var(--surface); color: var(--text-main); border: 1px solid var(--border-color); border-radius: 20px; font-size: 13px; outline: none; font-family: inherit; }
    .top-search-box input:focus { border-color: var(--accent-blue); }
    .top-search-box > i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: var(--text-muted); pointer-events: none; }
    .top-actions-right { display: flex; align-items: center; gap: 14px; }
    .top-icon-btn { position: relative; width: 40px; height: 40px; border-radius: 50%; background: var(--surface); border: 1px solid var(--border-color); display: flex; align-items: center; justify-content: center; color: var(--text-main); cursor: pointer; text-decoration: none; transition: transform .15s; }
    .top-icon-btn:hover { transform: scale(1.07); }
    .top-icon-btn .badge { position: absolute; top: -4px; right: -4px; min-width: 18px; height: 18px; padding: 0 5px; border-radius: 9px; background: var(--accent-pink); color: #fff; font-size: 10.5px; font-weight: 700; display: flex; align-items: center; justify-content: center; border: 2px solid var(--surface); }
    .create-post-btn { background: linear-gradient(135deg, #FF3366 0%, #FF5E62 100%); color: #fff; padding: 10px 20px; border-radius: 20px; font-weight: 700; font-size: 13px; letter-spacing: .3px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 4px 14px rgba(255, 51, 102, 0.35); white-space: nowrap; }

    .global-search-dropdown { position: absolute; top: calc(100% + 8px); left: 0; width: 100%; background: var(--surface); border: 1px solid var(--border-color); border-radius: 16px; box-shadow: var(--shadow-lg); display: none; z-index: 5000; max-height: 350px; overflow-y: auto; padding: 8px; }
    .global-search-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; cursor: pointer; transition: background 0.15s; text-decoration: none; color: var(--text-main); }
    .global-search-item:hover { background: var(--hover); }

    /* ============ Forma elementlari ============ */
    .form-control { width: 100%; padding: 11px 14px; font-size: 14px; background: var(--surface); color: var(--text-main); border: 1px solid var(--border-color); border-radius: 12px; outline: none; font-family: inherit; transition: border-color .15s, box-shadow .15s; }
    .form-control:focus { border-color: var(--accent-blue); box-shadow: 0 0 0 3px rgba(0, 149, 246, .14); }
    textarea.form-control { resize: vertical; }
    .btn { padding: 10px 20px; border-radius: 12px; font-weight: 600; cursor: pointer; border: none; font-size: 14px; }
    .btn-primary { background: var(--accent-blue); color: #fff; }
    .btn-danger { background: var(--accent-pink); color: #fff; }
    .btn-ghost { background: var(--hover); color: var(--text-main); }
    .btn:disabled { opacity: .55; cursor: default; }
    .mg-field { margin-bottom: 14px; }
    .mg-field label { font-size: 12.5px; font-weight: 600; margin-bottom: 6px; display: block; color: var(--text-muted); }
    .mg-error { color: var(--accent-pink); font-size: 13px; background: rgba(255, 51, 102, .1); padding: 9px 12px; border-radius: 10px; margin-bottom: 12px; }

    .mg-toast-container { position: fixed; bottom: 24px; right: 24px; z-index: 9000; display: flex; flex-direction: column; gap: 8px; }
    .mg-toast { background: #0F172A; color: #fff; padding: 10px 18px; border-radius: 10px; font-size: 13px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25); animation: toastIn .25s ease; }
    .mg-toast.is-error { background: var(--accent-pink); }
    .mg-toast.is-success { background: #10B981; }
    @keyframes toastIn { from { transform: translateY(10px); opacity: 0; } to { transform: none; opacity: 1; } }

    /* Modal */
    .mg-modal-overlay { position: fixed; inset: 0; background: var(--overlay); backdrop-filter: blur(4px); z-index: 4500; display: flex; align-items: center; justify-content: center; padding: 16px; animation: fadeIn .18s ease; }
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    .mg-modal { background: var(--surface); color: var(--text-main); border-radius: 20px; width: min(440px, 100%); max-height: 92vh; overflow-y: auto; box-shadow: var(--shadow-lg); animation: popIn .22s ease; }
    .mg-modal.wide { width: min(560px, 100%); }
    @keyframes popIn { from { transform: scale(.96) translateY(8px); opacity: 0; } to { transform: none; opacity: 1; } }
    .mg-modal-head { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid var(--border-color); font-weight: 700; font-size: 15px; }
    .mg-modal-body { padding: 18px 20px; }
    .mg-modal-foot { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 20px; border-top: 1px solid var(--border-color); }
    .pw-wrap { position: relative; }
    .pw-wrap .form-control { padding-right: 42px; }
    .pw-eye { position: absolute; right: 6px; top: 50%; transform: translateY(-50%); }

    /* ============ Stories ============ */
    .stories-container { display: flex; gap: 16px; overflow-x: auto; padding: 14px 18px; margin-bottom: 22px; background: var(--bg-glass); border-radius: 18px; border: 1px solid var(--border-color); }
    .story-item { display: flex; flex-direction: column; align-items: center; gap: 6px; cursor: pointer; flex-shrink: 0; width: 70px; position: relative; }
    .story-ring { width: 64px; height: 64px; border-radius: 50%; padding: 2.5px; background: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888); display: flex; align-items: center; justify-content: center; transition: transform .15s; }
    .story-ring.none { background: var(--border-color); }
    .story-ring.seen { background: var(--ring-seen); }
    .story-item:hover .story-ring { transform: scale(1.06); }
    .story-ring img { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; border: 2.5px solid var(--surface); background: var(--hover); }
    .story-name { font-size: 11px; font-weight: 500; max-width: 70px; text-align: center; }
    .story-add { position: absolute; top: 44px; right: 2px; width: 22px; height: 22px; border-radius: 50%; background: var(--accent-blue); color: #fff; border: 2px solid var(--surface); display: flex; align-items: center; justify-content: center; font-size: 10px; cursor: pointer; }
    .story-empty { color: var(--text-muted); font-size: 12px; align-self: center; padding-left: 6px; }

    .sv-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, .93); z-index: 6000; display: none; align-items: center; justify-content: center; }
    .sv-overlay.open { display: flex; }
    .sv-frame { position: relative; width: min(390px, 94vw); height: min(700px, 90vh); border-radius: 18px; overflow: hidden; background: #000; user-select: none; }
    .sv-media { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; }
    .sv-media img, .sv-media video { width: 100%; height: 100%; object-fit: contain; }
    .sv-shade { position: absolute; left: 0; right: 0; top: 0; height: 120px; background: linear-gradient(rgba(0, 0, 0, .55), transparent); z-index: 2; pointer-events: none; }
    .sv-bars { position: absolute; top: 10px; left: 10px; right: 10px; display: flex; gap: 4px; z-index: 3; }
    .sv-bar { flex: 1; height: 3px; background: rgba(255, 255, 255, .35); border-radius: 2px; overflow: hidden; }
    .sv-bar i { display: block; height: 100%; width: 0; background: #fff; }
    .sv-head { position: absolute; top: 22px; left: 12px; right: 10px; display: flex; align-items: center; gap: 10px; color: #fff; font-size: 13px; z-index: 4; text-shadow: 0 1px 4px rgba(0, 0, 0, .6); }
    .sv-head img { width: 34px; height: 34px; border-radius: 50%; object-fit: cover; border: 1.5px solid #fff; }
    .sv-head .sv-time { opacity: .75; font-weight: 400; }
    .sv-head .sv-spacer { flex: 1; }
    .sv-btn { background: none; border: none; color: #fff; font-size: 20px; cursor: pointer; padding: 4px 8px; }
    .sv-zone { position: absolute; top: 70px; bottom: 80px; z-index: 3; cursor: pointer; }
    .sv-zone.left { left: 0; width: 35%; } .sv-zone.right { right: 0; width: 65%; }
    .sv-caption { position: absolute; left: 0; right: 0; bottom: 0; padding: 40px 18px 22px; background: linear-gradient(transparent, rgba(0, 0, 0, .7)); color: #fff; font-size: 14px; text-align: center; z-index: 2; word-break: break-word; }
    .sv-menu { position: absolute; top: 62px; right: 10px; z-index: 6; background: var(--surface); color: var(--text-main); border-radius: 12px; box-shadow: var(--shadow-lg); overflow: hidden; min-width: 170px; }
    .sv-menu button { display: block; width: 100%; padding: 11px 16px; border: none; background: none; text-align: left; cursor: pointer; font-size: 13.5px; color: inherit; }
    .sv-menu button:hover { background: var(--hover); }
    .sv-menu button.danger { color: var(--accent-pink); font-weight: 600; }
    .sv-arrow { position: absolute; top: 50%; transform: translateY(-50%); width: 40px; height: 40px; border-radius: 50%; border: none; background: rgba(255, 255, 255, .18); color: #fff; font-size: 16px; cursor: pointer; display: none; }
    @media (min-width: 700px) { .sv-arrow { display: block; } }
    .sv-arrow.prev { left: calc(50% - 250px); } .sv-arrow.next { right: calc(50% - 250px); }
    .sv-close-x { position: absolute; top: 14px; right: 18px; background: none; border: none; color: #fff; font-size: 32px; cursor: pointer; line-height: 1; }
    .sv-preview { width: 100%; aspect-ratio: 9 / 14; max-height: 52vh; background: #000; border-radius: 14px; overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 12px; }
    .sv-preview img, .sv-preview video { width: 100%; height: 100%; object-fit: contain; }

    /* ============ Feed kartalari ============ */
    .feed-grid-layout { display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 20px; align-items: start; }
    .feed-post-card { background: var(--surface); border-radius: 16px; border: 1px solid var(--border-color); overflow: hidden; box-shadow: var(--shadow-sm); }
    .feed-post-card.post-highlight { animation: postFlash 2.4s ease; }
    @keyframes postFlash { 0%, 60% { box-shadow: 0 0 0 3px var(--accent-blue); } 100% { box-shadow: var(--shadow-sm); } }
    .feed-card-header { padding: 12px 16px; display: flex; align-items: center; gap: 10px; }
    .feed-card-header .post-more { margin-left: auto; font-size: 16px; color: var(--text-muted); }
    .feed-card-avatar { width: 34px; height: 34px; border-radius: 50%; object-fit: cover; display: block; background: var(--hover); }
    .post-author-link { color: inherit; text-decoration: none; }
    .post-author-link:hover { text-decoration: underline; }
    .feed-card-media { position: relative; width: 100%; max-height: 340px; background: #000; display: flex; align-items: center; justify-content: center; overflow: hidden; user-select: none; }
    .feed-card-media img, .feed-card-media video { width: 100%; max-height: 340px; min-height: 180px; object-fit: cover; display: block; }
    .feed-card-media video { cursor: pointer; }
    .feed-card-actions { padding: 12px 16px 4px; display: flex; align-items: center; justify-content: space-between; font-size: 20px; }
    .feed-card-actions .left { display: flex; align-items: center; gap: 14px; }
    .feed-card-info { padding: 0 16px 14px; font-size: 13px; }
    .action-btn { background: transparent; border: none; cursor: pointer; color: var(--text-main); font-size: 20px; padding: 0; transition: transform .12s; }
    .action-btn:active { transform: scale(.82); }
    .action-btn:hover { opacity: .75; }
    .action-btn.liked { color: var(--accent-pink); }
    .view-stat { display: inline-flex; align-items: center; gap: 5px; font-size: 13px; color: var(--text-muted); font-weight: 600; margin-left: 2px; }
    .view-stat i { font-size: 15px; }
    .comment-link { background: none; border: none; padding: 0; margin-top: 6px; font-size: 13px; color: var(--text-muted); cursor: pointer; display: block; }
    .comment-link:hover { color: var(--text-main); }
    .post-time { display: block; margin-top: 6px; font-size: 10.5px; letter-spacing: .4px; text-transform: uppercase; color: var(--text-muted); }

    .heart-pop { position: absolute; left: 50%; top: 50%; font-size: 84px; color: #fff; transform: translate(-50%, -50%) scale(0); opacity: 0; pointer-events: none; filter: drop-shadow(0 4px 16px rgba(0, 0, 0, .45)); }
    .heart-pop.show { animation: heartPop .8s ease; }
    @keyframes heartPop { 0% { transform: translate(-50%, -50%) scale(0); opacity: 0; } 25% { transform: translate(-50%, -50%) scale(1.15); opacity: 1; } 60% { transform: translate(-50%, -50%) scale(.95); opacity: 1; } 100% { transform: translate(-50%, -50%) scale(1.1); opacity: 0; } }
    .vid-sound-btn { position: absolute; right: 10px; bottom: 10px; width: 30px; height: 30px; border-radius: 50%; border: none; background: rgba(0, 0, 0, .6); color: #fff; cursor: pointer; font-size: 13px; display: flex; align-items: center; justify-content: center; z-index: 3; }

    /* ============ Post oynasi (viewer) + izohlar ============ */
    .pv-overlay { position: fixed; inset: 0; background: var(--overlay); backdrop-filter: blur(6px); z-index: 4000; display: none; align-items: center; justify-content: center; padding: 24px; }
    .pv-overlay.open { display: flex; }
    .pv-close { position: absolute; top: 14px; right: 24px; background: none; border: none; color: #fff; font-size: 34px; cursor: pointer; line-height: 1; }
    .pv-box { background: var(--surface); color: var(--text-main); border-radius: 20px; overflow: hidden; display: grid; grid-template-columns: minmax(0, 1.3fr) minmax(330px, 1fr); width: min(1000px, 100%); height: min(660px, 90vh); box-shadow: var(--shadow-lg); }
    .pv-media { position: relative; background: #000; display: flex; align-items: center; justify-content: center; min-height: 0; overflow: hidden; }
    .pv-media img, .pv-media video { width: 100%; height: 100%; object-fit: contain; display: block; }
    .pv-media.no-media { background: var(--page-bg); color: #fff; padding: 32px; text-align: center; font-size: 20px; font-weight: 600; word-break: break-word; }
    .pv-side { display: flex; flex-direction: column; min-height: 0; min-width: 0; }
    .pv-head { display: flex; align-items: center; gap: 10px; padding: 12px 16px; border-bottom: 1px solid var(--border-color); }
    .pv-name { font-weight: 600; font-size: 13.5px; color: var(--text-main); text-decoration: none; }
    .pv-comments { flex: 1; overflow-y: auto; padding: 14px 16px; display: flex; flex-direction: column; gap: 14px; font-size: 13px; min-height: 0; }
    .pv-actions { display: flex; justify-content: space-between; align-items: center; padding: 10px 16px 0; border-top: 1px solid var(--border-color); font-size: 22px; }
    .pv-actions .left { display: flex; align-items: center; gap: 14px; }
    .pv-likes { padding: 6px 16px 0; font-weight: 600; font-size: 13px; }
    .pv-when { padding: 2px 16px 10px; }
    .pv-when .post-time { margin-top: 2px; }
    .pv-replying { padding: 6px 16px; font-size: 12px; background: var(--surface-2); color: var(--text-muted); border-top: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
    .pv-replying button { background: none; border: none; cursor: pointer; color: var(--text-muted); font-size: 16px; }
    .pv-form { display: flex; gap: 8px; padding: 10px 16px; border-top: 1px solid var(--border-color); align-items: center; }
    .pv-form input { flex: 1; border: none; outline: none; font-size: 13.5px; font-family: inherit; background: transparent; color: var(--text-main); }
    .pv-form button { background: none; border: none; color: var(--accent-blue); font-weight: 700; cursor: pointer; font-size: 13.5px; }
    .pv-form button:disabled { opacity: .4; cursor: default; }
    .cm-row { display: flex; gap: 10px; align-items: flex-start; }
    .cm-row.cm-reply { margin-top: 12px; }
    .cm-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: var(--hover); }
    .cm-body { flex: 1; min-width: 0; }
    .cm-line { line-height: 1.42; word-break: break-word; }
    .cm-meta { display: flex; gap: 14px; font-size: 11.5px; color: var(--text-muted); margin-top: 4px; }
    .cm-meta button { background: none; border: none; padding: 0; cursor: pointer; color: var(--text-muted); font-weight: 600; font-size: 11.5px; }
    .cm-meta button:hover { color: var(--text-main); }
    .cm-side { display: flex; flex-direction: column; align-items: center; gap: 6px; flex-shrink: 0; min-width: 34px; }
    .cm-time { font-size: 10.5px; color: var(--text-muted); white-space: nowrap; }
    .cm-like { background: none; border: none; cursor: pointer; color: var(--text-muted); font-size: 12px; display: flex; flex-direction: column; align-items: center; gap: 1px; padding: 0 2px; }
    .cm-like span { font-size: 10.5px; }
    .cm-like.liked { color: var(--accent-pink); }
    .cm-hint { color: var(--text-muted); text-align: center; padding: 20px 0; font-size: 13px; }
    .cm-list { display: flex; flex-direction: column; gap: 14px; }

    /* post menyusi */
    .pm-overlay { position: fixed; inset: 0; background: var(--overlay); z-index: 4600; display: flex; align-items: center; justify-content: center; padding: 16px; }
    .pm-sheet { background: var(--surface); border-radius: 16px; width: min(360px, 92vw); overflow: hidden; box-shadow: var(--shadow-lg); }
    .pm-title { padding: 14px; text-align: center; font-weight: 700; font-size: 14px; border-bottom: 1px solid var(--border-color); }
    .pm-item { display: block; width: 100%; padding: 14px; border: none; background: none; border-bottom: 1px solid var(--border-color); text-align: center; font-size: 14px; cursor: pointer; color: var(--text-main); }
    .pm-item:last-child { border-bottom: none; }
    .pm-item:hover { background: var(--hover); }
    .pm-item.danger { color: var(--accent-pink); font-weight: 700; }

    /* ============ Bildirishnomalar ============ */
    .notif-dropdown { position: fixed; width: 370px; max-width: calc(100vw - 24px); background: var(--surface); border: 1px solid var(--border-color); border-radius: 18px; box-shadow: var(--shadow-lg); z-index: 5000; overflow: hidden; animation: popIn .2s ease; }
    .notif-head { padding: 14px 16px; font-weight: 700; font-size: 15px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; }
    .notif-list { max-height: 430px; overflow-y: auto; }
    .nt-row { display: flex; align-items: center; gap: 12px; padding: 11px 16px; cursor: pointer; position: relative; }
    .nt-row:hover { background: var(--hover); }
    .nt-row.unread { background: rgba(0, 149, 246, .08); }
    .nt-av { position: relative; flex-shrink: 0; }
    .nt-av img { width: 42px; height: 42px; border-radius: 50%; object-fit: cover; display: block; background: var(--hover); }
    .nt-type { position: absolute; right: -4px; bottom: -4px; width: 20px; height: 20px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 9px; border: 2px solid var(--surface); }
    .nt-type.LIKE { background: var(--accent-pink); } .nt-type.COMMENT, .nt-type.REPLY { background: var(--accent-blue); } .nt-type.FOLLOW { background: #8b5cf6; }
    .nt-text { flex: 1; min-width: 0; font-size: 13px; line-height: 1.35; }
    .nt-text .nt-time { display: block; color: var(--text-muted); font-size: 11px; margin-top: 2px; }
    .nt-thumb { width: 42px; height: 42px; border-radius: 8px; object-fit: cover; flex-shrink: 0; background: #000; }
    .nt-empty { padding: 36px 20px; text-align: center; color: var(--text-muted); font-size: 13px; }

    /* ============ Fon rasmi (Wallpaper) ============ */
    .wp-view { position: absolute; inset: 0; z-index: 60; background: var(--bg-glass); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); display: flex; flex-direction: column; animation: fadeIn .2s ease; }
    .wp-head { display: flex; align-items: center; justify-content: space-between; padding: 20px 32px; border-bottom: 1px solid var(--border-color); }
    .wp-head h3 { margin: 0; font-size: 18px; }
    .wp-head small { color: var(--text-muted); display: block; margin-top: 2px; font-weight: 400; }
    .wp-body { flex: 1; overflow-y: auto; padding: 22px 32px 32px; }
    .wp-group { font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: .8px; margin: 6px 0 12px; }
    .wp-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 16px; margin-bottom: 26px; }
    .wp-tile { position: relative; aspect-ratio: 3 / 4; border-radius: 18px; overflow: hidden; border: 3px solid transparent; cursor: pointer; box-shadow: var(--shadow-sm); transition: transform .18s, border-color .18s; padding: 0; background: none; }
    .wp-tile:hover { transform: translateY(-3px); }
    .wp-tile.sel { border-color: var(--accent-blue); }
    .wp-tile .wp-bg { position: absolute; inset: 0; }
    .wp-tile .wp-msgs { position: absolute; left: 10px; right: 10px; top: 14px; display: flex; flex-direction: column; gap: 6px; }
    .wp-msgs i { display: block; height: 16px; border-radius: 10px; background: rgba(255, 255, 255, .92); width: 62%; }
    .wp-msgs i.me { background: #0095F6; align-self: flex-end; width: 48%; }
    .wp-tile .wp-name { position: absolute; left: 0; right: 0; bottom: 0; padding: 18px 10px 9px; font-size: 12px; font-weight: 600; color: #fff; text-align: left; background: linear-gradient(transparent, rgba(0, 0, 0, .6)); }
    .wp-tile .wp-check { position: absolute; top: 8px; right: 8px; width: 24px; height: 24px; border-radius: 50%; background: var(--accent-blue); color: #fff; font-size: 11px; display: none; align-items: center; justify-content: center; }
    .wp-tile.sel .wp-check { display: flex; }

    /* ============ Profil ============ */
    .pf-card { background: var(--surface); border: 1px solid var(--border-color); border-radius: 22px; overflow: hidden; margin-bottom: 26px; box-shadow: var(--shadow-sm); }
    .pf-cover { position: relative; height: 190px; background: var(--page-bg); overflow: hidden; }
    .pf-cover img, .pf-cover video { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }
    .pf-cover::after { content: ''; position: absolute; inset: 0; background: linear-gradient(transparent 45%, rgba(0, 0, 0, .35)); pointer-events: none; }
    .pf-body { display: flex; gap: 28px; padding: 0 30px 26px; align-items: flex-start; flex-wrap: wrap; }
    .avatar-ring { display: inline-flex; padding: 4px; border-radius: 50%; margin-top: -58px; position: relative; z-index: 2; flex-shrink: 0; background: var(--surface); }
    .avatar-ring.has-story { background: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888); cursor: pointer; }
    .avatar-ring.has-story.seen { background: var(--ring-seen); }
    .avatar-ring img { width: 112px; height: 112px; border-radius: 50%; object-fit: cover; border: 4px solid var(--surface); background: var(--hover); display: block; }
    .pf-info { flex: 1; min-width: 240px; padding-top: 14px; }
    .pf-line1 { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 14px; }
    .pf-line1 h2 { margin: 0; font-size: 22px; font-weight: 800; }
    .pf-btn { padding: 7px 18px; font-size: 13px; font-weight: 600; border-radius: 9px; cursor: pointer; border: 1px solid var(--border-color); text-decoration: none; display: inline-block; background: var(--hover); color: var(--text-main); }
    .pf-btn.blue { background: var(--accent-blue); border-color: var(--accent-blue); color: #fff; }
    .pf-stats { display: flex; gap: 28px; margin-bottom: 14px; font-size: 14px; }
    .pf-stats button { background: none; border: none; padding: 0; font: inherit; color: inherit; cursor: pointer; }
    .pf-stats strong { font-weight: 700; }
    .pf-stats span { color: var(--text-muted); }
    .pf-name { font-weight: 700; font-size: 14px; }
    .pf-bio { font-size: 13.5px; margin-top: 3px; white-space: pre-wrap; word-break: break-word; }
    .pf-loc { font-size: 12.5px; color: var(--text-muted); margin-top: 4px; }
    .pf-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
    .pf-cell { position: relative; aspect-ratio: 1; background: #000; border-radius: 12px; overflow: hidden; cursor: pointer; }
    .pf-cell img, .pf-cell video { width: 100%; height: 100%; object-fit: cover; display: block; }
    .pf-cell .pf-text { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; padding: 14px; text-align: center; color: #fff; font-weight: 600; font-size: 13px; background: var(--page-bg); word-break: break-word; }
    .pf-cell .pf-ov { position: absolute; inset: 0; background: rgba(0, 0, 0, .42); color: #fff; display: flex; align-items: center; justify-content: center; gap: 18px; font-weight: 700; opacity: 0; transition: opacity .18s; }
    .pf-cell:hover .pf-ov { opacity: 1; }
    .pf-cell .pf-vid { position: absolute; top: 8px; right: 10px; color: #fff; text-shadow: 0 1px 4px rgba(0, 0, 0, .6); }
    .pf-empty { grid-column: 1 / -1; text-align: center; padding: 44px; background: var(--surface); border-radius: 16px; border: 1px solid var(--border-color); color: var(--text-muted); }

    /* Fayl tanlash (avatar / fon) */
    .pick-cover { position: relative; height: 130px; border-radius: 14px; overflow: hidden; background: var(--page-bg); cursor: pointer; border: 2px dashed transparent; }
    .pick-cover:hover { border-color: var(--accent-blue); }
    .pick-cover img, .pick-cover video { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; }
    .pick-cover .pick-label { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; color: #fff; font-size: 12.5px; font-weight: 600; text-shadow: 0 1px 6px rgba(0, 0, 0, .45); background: rgba(0, 0, 0, .18); text-align: center; padding: 0 12px; }
    .pick-cover .pick-label i { font-size: 20px; }
    .pick-avatar { position: relative; width: 92px; height: 92px; border-radius: 50%; cursor: pointer; margin: -46px auto 0; border: 4px solid var(--surface); background: var(--hover); overflow: hidden; z-index: 2; }
    .pick-avatar img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .pick-avatar .pick-cam { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; background: rgba(0, 0, 0, .35); color: #fff; font-size: 20px; opacity: 0; transition: opacity .15s; }
    .pick-avatar:hover .pick-cam { opacity: 1; }
    .pick-busy { position: absolute; inset: 0; background: rgba(0, 0, 0, .55); color: #fff; display: none; align-items: center; justify-content: center; font-size: 12.5px; font-weight: 600; z-index: 3; text-align: center; padding: 8px; }
    .pick-busy.on { display: flex; }

    /* ============ Post yaratish ============ */
    .cp-layout { display: grid; grid-template-columns: minmax(0, 1.15fr) minmax(300px, 1fr); background: var(--surface); border: 1px solid var(--border-color); border-radius: 22px; overflow: hidden; max-width: 920px; margin: 0 auto; min-height: 500px; box-shadow: var(--shadow-sm); }
    .cp-drop { position: relative; background: var(--surface-2); display: flex; align-items: center; justify-content: center; min-height: 320px; border-right: 1px solid var(--border-color); overflow: hidden; }
    .cp-drop.drag { background: rgba(0, 149, 246, .1); }
    .cp-empty { text-align: center; padding: 30px; color: var(--text-muted); }
    .cp-empty .cp-icon { font-size: 54px; background: linear-gradient(135deg, #6366f1, #d946ef); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 12px; }
    .cp-empty h4 { margin: 0 0 6px; color: var(--text-main); font-size: 17px; }
    .cp-empty p { margin: 0 0 16px; font-size: 13px; }
    .cp-preview { position: absolute; inset: 0; display: none; background: #000; }
    .cp-preview img, .cp-preview video { width: 100%; height: 100%; object-fit: contain; }
    .cp-preview.on { display: block; }
    .cp-clear { position: absolute; top: 12px; right: 12px; z-index: 3; width: 34px; height: 34px; border-radius: 50%; border: none; background: rgba(0, 0, 0, .6); color: #fff; cursor: pointer; }
    .cp-form { display: flex; flex-direction: column; padding: 20px 22px; gap: 14px; min-width: 0; }
    .cp-user { display: flex; align-items: center; gap: 10px; font-weight: 600; font-size: 14px; }
    .cp-count { text-align: right; font-size: 11.5px; color: var(--text-muted); margin-top: 4px; }
    .cp-emoji { display: flex; flex-wrap: wrap; gap: 4px; }
    .cp-emoji button { background: none; border: none; font-size: 20px; cursor: pointer; padding: 3px 5px; border-radius: 8px; }
    .cp-emoji button:hover { background: var(--hover); }
    .cp-submit { margin-top: auto; width: 100%; padding: 12px; font-size: 14.5px; border-radius: 14px; background: linear-gradient(135deg, #6366f1, #d946ef); color: #fff; border: none; font-weight: 700; cursor: pointer; box-shadow: 0 6px 18px rgba(124, 58, 237, .35); }
    .cp-submit:disabled { opacity: .6; cursor: default; }

    /* ============ Kirish / Ro'yxatdan o'tish ============ */
    .auth-wrap { min-height: calc(100vh - 48px); display: flex; align-items: center; justify-content: center; }
    .auth-card { background: var(--bg-glass); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border-radius: 26px; box-shadow: 0 25px 50px rgba(0, 0, 0, .25); width: 100%; max-width: 420px; border: 1px solid rgba(255, 255, 255, .25); overflow: hidden; }
    .auth-card.wide { max-width: 470px; }
    .auth-brand { display: flex; align-items: center; justify-content: center; gap: 10px; padding: 26px 20px 6px; }
    .auth-brand .logo-mark { width: 46px; height: 46px; }
    .auth-brand h1 { margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -.3px; }
    .auth-body { padding: 18px 34px 30px; }
    .auth-sub { text-align: center; color: var(--text-muted); font-size: 13px; margin: 0 0 18px; }
    .auth-foot { margin-top: 18px; text-align: center; font-size: 13px; color: var(--text-muted); }
    .auth-foot a { color: var(--accent-blue); font-weight: 600; text-decoration: none; }
    .auth-submit { width: 100%; padding: 12px; border-radius: 14px; border: none; color: #fff; font-weight: 700; font-size: 14.5px; cursor: pointer; background: linear-gradient(135deg, #6366f1, #d946ef); box-shadow: 0 8px 20px rgba(124, 58, 237, .35); margin-top: 6px; }
    .auth-submit:disabled { opacity: .6; cursor: default; }
    .rg-head { position: relative; }
    .rg-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 12px; }
    .rg-hint { font-size: 11.5px; color: var(--text-muted); margin-top: 4px; }

    @media (max-width: 1000px) {
        .dashboard-container { grid-template-columns: 1fr; }
        .dashboard-sidebar { display: none; }
        .pv-box { grid-template-columns: 1fr; grid-template-rows: 38% 1fr; }
        .cp-layout { grid-template-columns: 1fr; }
    }

    /* ---------- Tasdiqlangan belgi ---------- */
    .mg-verified { width: 15px; height: 15px; margin-left: 4px; vertical-align: -2px; display: inline-block; flex-shrink: 0; }
    h2 .mg-verified { width: 20px; height: 20px; vertical-align: -3px; margin-left: 6px; }
    .mg-tag { color: var(--accent-blue); font-weight: 500; text-decoration: none; }
    .mg-tag:hover { text-decoration: underline; }
    .feed-more { display: flex; justify-content: center; padding: 8px 0 28px; }
    .feed-more-btn { padding: 11px 22px; border-radius: 12px; background: var(--surface); border: 1px solid var(--border-color); color: var(--text-main); font-weight: 600; text-decoration: none; }
    .feed-more-btn:hover { border-color: var(--accent-blue); color: var(--accent-blue); }

    /* ---------- Explore ---------- */
    .ex-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 16px; }
    .ex-title { margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -.02em; color: var(--text-main); }
    .ex-sub { margin: 4px 0 0; color: var(--text-muted); font-size: 14px; }
    .ex-clear { font-weight: 600; color: var(--accent-blue); text-decoration: none; white-space: nowrap; }
    .ex-tags { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 22px; }
    .ex-tag { display: inline-flex; align-items: center; gap: 8px; padding: 7px 12px; border-radius: 999px; background: var(--surface); border: 1px solid var(--border-color); color: var(--text-main); font-weight: 600; font-size: 13px; text-decoration: none; }
    .ex-tag span { font-weight: 500; color: var(--text-muted); font-size: 12px; }
    .ex-tag:hover { border-color: var(--accent-blue); }
    .ex-tag.on { background: var(--accent-blue); border-color: var(--accent-blue); color: #fff; }
    .ex-tag.on span { color: rgba(255,255,255,.8); }
    .ex-h2 { font-size: 15px; font-weight: 700; margin: 0 0 12px; color: var(--text-main); }
    .ex-people { margin-bottom: 26px; }
    .ex-people-row { display: grid; grid-auto-flow: column; grid-auto-columns: 148px; gap: 12px; overflow-x: auto; padding-bottom: 6px; scrollbar-width: thin; }
    .ex-person { background: var(--surface); border: 1px solid var(--border-color); border-radius: 16px; padding: 16px 12px 12px; text-align: center; display: flex; flex-direction: column; gap: 10px; }
    .ex-person-link { display: flex; flex-direction: column; align-items: center; gap: 4px; text-decoration: none; color: var(--text-main); min-width: 0; }
    .ex-person img { width: 64px; height: 64px; border-radius: 50%; object-fit: cover; margin-bottom: 4px; }
    .ex-person b { font-size: 13px; max-width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: flex; align-items: center; justify-content: center; }
    .ex-person span { font-size: 12px; color: var(--text-muted); }
    .ex-follow { height: 32px; border-radius: 9px; border: 0; background: var(--accent-blue); color: #fff; font-weight: 600; font-size: 13px; cursor: pointer; }
    .ex-follow.on { background: transparent; border: 1px solid var(--border-color); color: var(--text-main); }
    .ex-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 6px; grid-auto-flow: dense; }
    .ex-item.big { grid-column: span 2; grid-row: span 2; }
    .ex-link { display: block; position: relative; aspect-ratio: 1/1; height: 100%; background: #000; overflow: hidden; border-radius: 10px; text-decoration: none; }
    .ex-link img, .ex-link video { width: 100%; height: 100%; object-fit: cover; display: block; transition: transform .35s; }
    .ex-link:hover img, .ex-link:hover video { transform: scale(1.04); }
    .ex-text { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; padding: 18px; text-align: center; color: #fff; font-weight: 600; font-size: 14px; line-height: 1.45; background: linear-gradient(150deg, #4f46e5, #9333ea 55%, #db2777); overflow: hidden; word-break: break-word; }
    .ex-item.big .ex-text { font-size: 20px; padding: 32px; }
    .ex-badge { position: absolute; right: 10px; top: 10px; color: #fff; text-shadow: 0 1px 4px rgba(0,0,0,.6); }
    .ex-overlay { position: absolute; inset: 0; background: rgba(0,0,0,.4); display: flex; align-items: center; justify-content: center; gap: 22px; color: #fff; font-weight: 700; opacity: 0; transition: opacity .2s; }
    .ex-link:hover .ex-overlay, .ex-link:focus-visible .ex-overlay { opacity: 1; }
    @media (max-width: 640px) { .ex-grid { gap: 3px; } .ex-link { border-radius: 4px; } .ex-title { font-size: 22px; } .ex-text { font-size: 11px; padding: 8px; } .ex-item.big .ex-text { font-size: 15px; } }
</style>
