<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />
<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MilliyGram — Chat</title>
  <jsp:include page="/fragments/head.jsp"/>
  <style>
    .dashboard-content { overflow: hidden !important; }
    .scrollable-main-area {
      overflow: hidden !important;
      padding: 16px 24px !important;
      height: calc(92vh - 85px) !important;
      display: flex !important;
      flex-direction: column !important;
    }

    .chat-layout-grid {
      display: flex !important; flex-direction: row !important; gap: 16px !important;
      height: 100% !important; background: transparent !important; overflow: hidden !important;
      border: none !important; flex: 1 !important; min-height: 0;
    }

    .chat-sidebar-left {
      width: 320px !important; min-width: 320px !important; background: var(--surface) !important;
      border-radius: 20px !important; border: 1px solid var(--border-color) !important;
      display: flex !important; flex-direction: column !important; height: 100% !important;
      overflow: hidden !important; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    .chat-contacts-scroll { flex: 1 !important; overflow-y: auto !important; overflow-x: hidden !important; padding: 12px; }

    .chat-main-right {
      flex: 1 !important; background: var(--surface) !important; border-radius: 20px !important;
      border: 1px solid var(--border-color) !important; display: flex !important; flex-direction: column !important;
      height: 100% !important; overflow: hidden !important; min-width: 0; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    .chat-messages-box {
      flex: 1 !important; overflow-y: auto !important; overflow-x: hidden !important; padding: 24px;
      display: flex; flex-direction: column; gap: 12px; background: transparent; min-height: 0;
    }

    /* VIDEO MUAMMOSI SABABI: .chat-messages-box flex-column va bubble'lar siqilib ketardi
       (overflow:hidden bo'lgani uchun min-height 0 bo'lib, "bir chiziq" bo'lib qolardi).
       flex-shrink:0 buni to'liq tuzatadi. */
    .msg-bubble {
      max-width: 65%; padding: 8px 14px; border-radius: 16px; font-size: 14px; word-break: break-word;
      position: relative; box-shadow: 0 1px 2px rgba(0,0,0,0.08);
      flex-shrink: 0 !important;
    }
    .msg-bubble.incoming { background: var(--surface); border: 1px solid var(--border-color); align-self: flex-start; border-bottom-left-radius: 4px; }
    .msg-bubble.outgoing { background: #0095F6; color: #fff; align-self: flex-end; border-bottom-right-radius: 4px; }

    .msg-bubble.media-only { padding: 4px !important; overflow: hidden; background-color: #0095F6; }
    .msg-bubble.incoming.media-only { background-color: var(--hover); }
    .msg-bubble.has-media-text { padding: 4px 4px 8px 4px !important; display: flex; flex-direction: column; gap: 6px; }
    .media-caption-text { padding: 2px 6px; font-size: 14px; line-height: 1.4; }

    .chat-media-wrapper {
      margin: 0; border-radius: 12px; overflow: hidden; background: #000; position: relative;
      cursor: pointer; flex-shrink: 0 !important; display: block;
    }
    .chat-media-wrapper img { width: 270px; height: 170px; object-fit: cover; border-radius: 12px; display: block; }
    .chat-media-wrapper.video-message { width: 220px; height: 300px; }
    .chat-media-wrapper video.video-foreground {
      position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; display: block; background: #000; pointer-events: none;
    }
    .chat-audio { width: 240px; max-width: 100%; display: block; }
    .chat-file-link { color: inherit; text-decoration: underline; font-size: 13px; padding: 4px 8px; display: inline-block; }

    .video-play-badge {
      position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
      background: rgba(0, 0, 0, 0.25); color: #fff; font-size: 34px; pointer-events: none; transition: background 0.2s; z-index: 2;
    }
    .chat-media-wrapper:hover .video-play-badge { background: rgba(0, 0, 0, 0.45); }

    /* xabar menyusi (tahrirlash / o'chirish) */
    .msg-menu-btn {
      position: absolute; top: 4px; left: -30px; width: 24px; height: 24px; border-radius: 50%;
      border: none; background: rgba(15,23,42,.55); color: #fff; font-size: 11px; cursor: pointer;
      display: none; align-items: center; justify-content: center; z-index: 5;
    }
    .msg-bubble.outgoing:hover .msg-menu-btn { display: flex; }
    .msg-menu {
      position: fixed; background: var(--surface); border: 1px solid var(--border-color); border-radius: 12px;
      box-shadow: 0 12px 30px rgba(0,0,0,.18); z-index: 6000; overflow: hidden; min-width: 150px;
    }
    .msg-menu button { display: block; width: 100%; padding: 10px 16px; border: none; background: none; text-align: left; font-size: 13.5px; cursor: pointer; color: var(--text-main); }
    .msg-menu button:hover { background: var(--hover); }
    .msg-menu button.danger { color: var(--accent-pink); font-weight: 600; }

    .tg-chat-input-wrapper {
      background: var(--surface); border-top: 1px solid var(--border-color); display: flex; flex-direction: column;
      position: relative; flex-shrink: 0; border-bottom-left-radius: 20px; border-bottom-right-radius: 20px;
    }
    .tg-input-preview-bar { display: none; align-items: center; justify-content: space-between; padding: 8px 18px; background: var(--surface-2); border-bottom: 1px solid #E2E8F0; }
    .tg-preview-left { display: flex; align-items: center; gap: 12px; }
    .tg-preview-bar-indicator { width: 3px; height: 36px; background-color: #EF4444; border-radius: 2px; }
    .tg-preview-thumb { width: 36px; height: 36px; border-radius: 6px; object-fit: cover; border: 1px solid #CBD5E1; background: #000; }
    .tg-preview-icon { width: 36px; height: 36px; border-radius: 6px; background: #E2E8F0; color: #475569; display: none; align-items: center; justify-content: center; font-size: 16px; }
    .tg-preview-meta { display: flex; flex-direction: column; }
    .tg-preview-title { font-size: 13px; font-weight: 700; color: #EF4444; }
    .tg-preview-desc { font-size: 12px; color: var(--text-muted); }
    .tg-preview-close-btn { background: none; border: none; color: var(--text-muted); font-size: 18px; cursor: pointer; padding: 4px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
    .tg-preview-close-btn:hover { color: var(--text-main); background: #E2E8F0; }

    .tg-main-input-row { display: flex; align-items: center; padding: 10px 18px; gap: 12px; }
    .tg-input-icon-btn { background: transparent; border: none; color: var(--text-muted); cursor: pointer; padding: 6px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; transition: color 0.15s; }
    .tg-input-icon-btn:hover { color: var(--text-main); }
    .tg-text-field { flex: 1; border: none; outline: none; background: transparent; font-size: 14.5px; color: var(--text-main); padding: 6px 0; font-family: inherit; }
    .tg-text-field::placeholder { color: #94A3B8; }
    .tg-send-action-btn {
      width: 38px; height: 38px; border-radius: 50%; border: none; background-color: #0095F6; color: #FFFFFF; cursor: pointer;
      display: flex; align-items: center; justify-content: center; font-size: 16px; box-shadow: 0 4px 10px rgba(0, 149, 246, 0.3); transition: transform 0.15s;
    }
    .tg-send-action-btn:hover { transform: scale(1.04); }
    .tg-send-action-btn:disabled { opacity: .6; cursor: default; }

    .emoji-picker-popup {
      position: absolute; bottom: 65px; right: 50px; background: var(--surface); border: 1px solid var(--border-color);
      border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); padding: 12px; display: none;
      grid-template-columns: repeat(6, 1fr); gap: 8px; z-index: 2500;
    }
    .emoji-item { font-size: 20px; cursor: pointer; padding: 6px; text-align: center; border-radius: 8px; transition: background 0.15s; }
    .emoji-item:hover { background: var(--hover); }

    .chat-media-lightbox { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.88); backdrop-filter: blur(8px); z-index: 5000; display: none; align-items: center; justify-content: center; padding: 24px; }
    .lightbox-content-box { position: relative; max-width: 90vw; max-height: 85vh; display: flex; align-items: center; justify-content: center; }
    .lightbox-content-box img, .lightbox-content-box video { max-width: 100%; max-height: 85vh; border-radius: 12px; box-shadow: 0 20px 50px rgba(0,0,0,0.5); }
    .lightbox-close-btn { position: absolute; top: -40px; right: 0; background: transparent; border: none; color: #fff; font-size: 28px; cursor: pointer; }

    .chat-search-dropdown {
      position: absolute; top: calc(100% + 8px); right: 0; width: 320px; background: var(--surface); border: 1px solid var(--border-color);
      border-radius: 16px; box-shadow: 0 15px 35px rgba(0,0,0,0.15); display: none; z-index: 3000; max-height: 350px; overflow-y: auto; padding: 8px;
    }
    .search-result-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; cursor: pointer; transition: background 0.15s; }
    .search-result-item:hover { background: var(--hover); }
    .chat-contact-row { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 12px; cursor: pointer; transition: background 0.15s; text-decoration: none; color: var(--text-main); margin-bottom: 4px; }
    .chat-contact-row:hover, .chat-contact-row.active { background: var(--hover); }
  </style>
</head>
<body>

<div class="dashboard-container">
  <jsp:include page="/fragments/navbar.jsp"/>

  <main class="dashboard-content">
    <header class="top-header-bar" style="position: relative;">
      <h3 style="margin: 0; font-weight: 700; font-size: 18px;" id="profileOwnerFullName">
        <c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}"/>
      </h3>

      <div style="position: relative; width: 320px;">
        <div style="position: relative; display: flex; align-items: center;">
          <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 14px; color: var(--text-muted); font-size: 13px;"></i>
          <input type="text" id="chatUserSearchInput" class="form-control"
                 style="padding-left: 38px; border-radius: 20px; font-size: 13px;"
                 placeholder="Suhbatdosh qidirish..." autocomplete="off">
        </div>
        <div id="chatSearchDropdown" class="chat-search-dropdown"></div>
      </div>
    </header>

    <div class="scrollable-main-area">
      <div class="chat-layout-grid">

        <!-- Chap Ustun: Faol chatlar -->
        <div class="chat-sidebar-left">
          <div style="padding: 16px; font-weight: 700; font-size: 14px; border-bottom: 1px solid var(--border-color); background: var(--surface); flex-shrink: 0; border-top-left-radius: 20px; border-top-right-radius: 20px;">
            Faol chatlar
          </div>
          <div class="chat-contacts-scroll" id="chatContactsList">
            <div class="text-muted small text-center p-4">Chatlar yuklanmoqda...</div>
          </div>
        </div>

        <!-- O'ng Ustun: Suhbat oynasi -->
        <div class="chat-main-right" id="activeChatPane">
          <div style="padding: 12px 20px; border-bottom: 1px solid var(--border-color); background: var(--surface); display: flex; align-items: center; gap: 12px; flex-shrink: 0; border-top-left-radius: 20px; border-top-right-radius: 20px;" id="activeChatHeaderBar">
            <a id="activeChatProfileLink" style="display: none;">
              <img id="activeChatUserAvatar" src="${defAvatar}"
                   style="width: 42px; height: 42px; border-radius: 50%; object-fit: cover; display: block;" alt="Avatar">
            </a>
            <div>
              <div style="font-weight: 700; font-size: 15px; color: var(--text-main);" id="activeChatHeaderName">Suhbat tanlanmagan</div>
              <div style="font-size: 11px; color: var(--text-muted); display: none;" id="activeChatHeaderSub">online</div>
            </div>
          </div>

          <div class="chat-messages-box" id="activeChatMessagesList">
            <div style="margin: auto; text-align: center; color: var(--text-muted); background: var(--bg-glass); padding: 24px; border-radius: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
              <i class="fa-regular fa-comments" style="font-size: 42px; margin-bottom: 10px; color: #0095F6;"></i>
              <p style="margin: 0; font-size: 14px;">Suhbatni boshlash uchun suhbatdoshni tanlang.</p>
            </div>
          </div>

          <!-- Input Paneli -->
          <form id="chatSendForm" class="tg-chat-input-wrapper" style="display: none;" enctype="multipart/form-data">
            <input type="hidden" id="targetUserIdField" name="receiverId">
            <input type="file" id="chatMediaInput" name="media" style="display: none !important;" accept="image/*,video/*,audio/*">

            <div id="mediaPreviewBar" class="tg-input-preview-bar">
              <div class="tg-preview-left">
                <div class="tg-preview-bar-indicator"></div>
                <img id="mediaPreviewImg" class="tg-preview-thumb" src="" alt="Preview">
                <div id="mediaPreviewIcon" class="tg-preview-icon"><i class="fa-solid fa-film"></i></div>
                <div class="tg-preview-meta">
                  <span class="tg-preview-title" id="mediaPreviewTitle">Fayl biriktirildi</span>
                  <span class="tg-preview-desc" id="mediaPreviewFilename">file.ext</span>
                </div>
              </div>
              <button type="button" class="tg-preview-close-btn" id="cancelMediaBtn" title="Bekor qilish">
                <i class="fa-solid fa-xmark"></i>
              </button>
            </div>

            <div class="tg-main-input-row">
              <button type="button" class="tg-input-icon-btn" id="attachFileBtn" title="Fayl biriktirish">
                <i class="fa-solid fa-paperclip"></i>
              </button>

              <input type="text" id="chatMessageContent" name="content" class="tg-text-field" placeholder="Write a message..." autocomplete="off">

              <button type="button" class="tg-input-icon-btn" id="emojiToggleBtn" title="Emoji">
                <i class="fa-regular fa-face-smile"></i>
              </button>

              <button type="submit" class="tg-send-action-btn" id="sendActionBtn" title="Yuborish">
                <i class="fa-solid fa-paper-plane"></i>
              </button>
            </div>

            <div id="emojiPickerPopup" class="emoji-picker-popup">
              <span class="emoji-item">😀</span><span class="emoji-item">😂</span><span class="emoji-item">😍</span><span class="emoji-item">🔥</span><span class="emoji-item">👍</span><span class="emoji-item">🎉</span>
              <span class="emoji-item">❤️</span><span class="emoji-item">😎</span><span class="emoji-item">✨</span><span class="emoji-item">🚀</span><span class="emoji-item">🙏</span><span class="emoji-item">😊</span>
            </div>
          </form>
        </div>

      </div>
    </div>
  </main>
</div>

<div id="chatMediaLightbox" class="chat-media-lightbox" onclick="closeLightbox(event)">
  <div class="lightbox-content-box" id="lightboxContentBox">
    <button type="button" class="lightbox-close-btn" onclick="closeLightbox({target: {id: 'chatMediaLightbox'}})">&times;</button>
  </div>
</div>

<jsp:include page="/fragments/scripts.jsp"/>
<script>
  (function () {
    var searchInput = document.getElementById('chatUserSearchInput');
    var searchDropdown = document.getElementById('chatSearchDropdown');
    var contactsList = document.getElementById('chatContactsList');
    var messagesList = document.getElementById('activeChatMessagesList');
    var headerName = document.getElementById('activeChatHeaderName');
    var headerSub = document.getElementById('activeChatHeaderSub');
    var headerAvatar = document.getElementById('activeChatUserAvatar');
    var headerLink = document.getElementById('activeChatProfileLink');
    var sendForm = document.getElementById('chatSendForm');
    var sendBtn = document.getElementById('sendActionBtn');
    var targetInput = document.getElementById('targetUserIdField');
    var msgContentInput = document.getElementById('chatMessageContent');
    var chatMediaInput = document.getElementById('chatMediaInput');
    var attachFileBtn = document.getElementById('attachFileBtn');
    var mediaPreviewBar = document.getElementById('mediaPreviewBar');
    var mediaPreviewImg = document.getElementById('mediaPreviewImg');
    var mediaPreviewIcon = document.getElementById('mediaPreviewIcon');
    var mediaPreviewFilename = document.getElementById('mediaPreviewFilename');
    var cancelMediaBtn = document.getElementById('cancelMediaBtn');
    var emojiToggleBtn = document.getElementById('emojiToggleBtn');
    var emojiPopup = document.getElementById('emojiPickerPopup');

    var activeTargetUser = null;
    var pollTimer = null;
    var searchTimer = null;
    var cachedMessagesJson = '';
    var sending = false;

    /* ---------- fayl biriktirish ---------- */
    attachFileBtn.addEventListener('click', function () { chatMediaInput.click(); });

    chatMediaInput.addEventListener('change', function () {
      if (!(chatMediaInput.files && chatMediaInput.files[0])) return;
      var file = chatMediaInput.files[0];
      mediaPreviewFilename.textContent = file.name;
      if (file.type.indexOf('image/') === 0) {
        var reader = new FileReader();
        reader.onload = function (e) {
          mediaPreviewImg.src = e.target.result;
          mediaPreviewImg.style.display = 'block';
          mediaPreviewIcon.style.display = 'none';
        };
        reader.readAsDataURL(file);
      } else {
        mediaPreviewImg.style.display = 'none';
        mediaPreviewIcon.innerHTML = '<i class="fa-solid ' + (file.type.indexOf('audio/') === 0 ? 'fa-music' : 'fa-film') + '"></i>';
        mediaPreviewIcon.style.display = 'flex';
      }
      mediaPreviewBar.style.display = 'flex';
    });

    cancelMediaBtn.addEventListener('click', function () {
      chatMediaInput.value = '';
      mediaPreviewBar.style.display = 'none';
    });

    /* ---------- emoji ---------- */
    emojiToggleBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      emojiPopup.style.display = emojiPopup.style.display === 'grid' ? 'none' : 'grid';
    });
    document.querySelectorAll('.emoji-item').forEach(function (item) {
      item.addEventListener('click', function () {
        msgContentInput.value += item.textContent;
        emojiPopup.style.display = 'none';
        msgContentInput.focus();
      });
    });
    document.addEventListener('click', function (e) {
      if (!emojiPopup.contains(e.target) && !emojiToggleBtn.contains(e.target)) emojiPopup.style.display = 'none';
    });

    /* ---------- lightbox ---------- */
    window.openLightbox = function (url, isVideo) {
      var lb = document.getElementById('chatMediaLightbox');
      var box = document.getElementById('lightboxContentBox');
      box.querySelectorAll('img, video').forEach(function (n) { n.remove(); });
      if (isVideo) {
        var vid = document.createElement('video');
        vid.src = url; vid.controls = true; vid.autoplay = true; vid.playsInline = true;
        box.appendChild(vid);
      } else {
        var img = document.createElement('img');
        img.src = url;
        box.appendChild(img);
      }
      lb.style.display = 'flex';
    };
    window.closeLightbox = function (e) {
      if (e.target.id === 'chatMediaLightbox') {
        var lb = document.getElementById('chatMediaLightbox');
        lb.querySelectorAll('video').forEach(function (v) { v.pause(); });
        lb.style.display = 'none';
      }
    };
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeLightbox({target: {id: 'chatMediaLightbox'}});
    });

    /* ---------- suhbatdosh qidirish ---------- */
    searchInput.addEventListener('input', function () {
      var q = searchInput.value.trim();
      clearTimeout(searchTimer);
      if (!q) { searchDropdown.style.display = 'none'; searchDropdown.innerHTML = ''; return; }
      searchTimer = setTimeout(function () {
        fetch(CONTEXT_PATH + '/user/search?p=' + encodeURIComponent(q) + '&q=' + encodeURIComponent(q))
                .then(function (res) { return res.json(); })
                .then(function (users) {
                  searchDropdown.innerHTML = '';
                  users = (Array.isArray(users) ? users : []).filter(function (u) { return String(u.id) !== String(CURRENT_USER_ID); });
                  if (!users.length) {
                    searchDropdown.appendChild(el('div', 'p-3 text-muted text-center small', 'Foydalanuvchi topilmadi'));
                    searchDropdown.style.display = 'block';
                    return;
                  }
                  users.forEach(function (u) {
                    var row = el('div', 'search-result-item');
                    var img = el('img'); img.src = resolveAvatar(u.avatar); img.alt = '';
                    img.style.cssText = 'width:38px;height:38px;border-radius:50%;object-fit:cover;flex-shrink:0;';
                    var info = el('div'); info.style.cssText = 'min-width:0;flex:1;';
                    var nameDiv = el('div', 'text-truncate', u.fullName || u.username); nameDiv.style.cssText = 'font-weight:600;font-size:13px;';
                    var userDiv = el('div', 'text-truncate', '@' + u.username); userDiv.style.cssText = 'font-size:11px;color:var(--text-muted);';
                    info.appendChild(nameDiv); info.appendChild(userDiv);
                    row.appendChild(img); row.appendChild(info);
                    row.onclick = function () {
                      searchDropdown.style.display = 'none';
                      searchInput.value = '';
                      var userObj = {id: u.id, username: u.username, fullName: u.fullName || u.username, avatar: u.avatar};
                      saveRecentContact(userObj);
                      loadRecentContacts();
                      selectChatUser(userObj);
                    };
                    searchDropdown.appendChild(row);
                  });
                  searchDropdown.style.display = 'block';
                }).catch(function () { searchDropdown.style.display = 'none'; });
      }, 250);
    });
    document.addEventListener('click', function (e) {
      if (!searchInput.contains(e.target) && !searchDropdown.contains(e.target)) searchDropdown.style.display = 'none';
    });

    /* ---------- so'nggi suhbatlar (brauzerda saqlanadi) ---------- */
    function getRecentContacts() {
      try { var r = localStorage.getItem('mg_chat_contacts_' + CURRENT_USER_ID); return r ? JSON.parse(r) : []; }
      catch (e) { return []; }
    }
    function saveRecentContact(u) {
      if (!u || !u.id) return;
      var list = getRecentContacts().filter(function (x) { return String(x.id) !== String(u.id); });
      list.unshift({id: u.id, username: u.username, fullName: u.fullName || u.username, avatar: u.avatar || ''});
      try { localStorage.setItem('mg_chat_contacts_' + CURRENT_USER_ID, JSON.stringify(list.slice(0, 20))); } catch (e) {}
    }
    function removeRecentContact(id) {
      var list = getRecentContacts().filter(function (x) { return String(x.id) !== String(id); });
      try { localStorage.setItem('mg_chat_contacts_' + CURRENT_USER_ID, JSON.stringify(list)); } catch (e) {}
    }
    function loadRecentContacts() {
      var list = getRecentContacts();
      contactsList.innerHTML = '';
      if (!list.length) {
        contactsList.appendChild(el('div', 'text-muted small text-center p-4', 'Hozircha chatlar yo‘q. Yuqoridan qidirib boshlang.'));
        return;
      }
      list.forEach(function (u) {
        var item = el('div', 'chat-contact-row' + (activeTargetUser && String(activeTargetUser.id) === String(u.id) ? ' active' : ''));
        var img = el('img'); img.src = resolveAvatar(u.avatar); img.alt = '';
        img.style.cssText = 'width:40px;height:40px;border-radius:50%;object-fit:cover;flex-shrink:0;';
        var info = el('div'); info.style.cssText = 'min-width:0;flex:1;';
        var nameDiv = el('div', 'text-truncate', u.fullName || u.username); nameDiv.style.cssText = 'font-weight:600;font-size:13px;';
        var userDiv = el('div', 'text-truncate', '@' + u.username); userDiv.style.cssText = 'font-size:11px;color:var(--text-muted);';
        info.appendChild(nameDiv); info.appendChild(userDiv);
        item.appendChild(img); item.appendChild(info);
        item.onclick = function () { selectChatUser(u); };
        contactsList.appendChild(item);
      });
    }

    function selectChatUser(u) {
      activeTargetUser = u;
      cachedMessagesJson = '';
      targetInput.value = u.id;
      headerName.textContent = u.fullName || u.username;
      headerSub.textContent = '@' + u.username;
      headerSub.style.display = 'block';
      headerAvatar.src = resolveAvatar(u.avatar);
      headerLink.href = CONTEXT_PATH + '/user/profile?id=' + u.id;
      headerLink.style.display = 'block';
      sendForm.style.display = 'flex';
      loadMessages(true);
      loadRecentContacts();
      if (pollTimer) clearInterval(pollTimer);
      pollTimer = setInterval(function () { if (!document.hidden) loadMessages(false); }, 3000);
      msgContentInput.focus();
    }

    /* ---------- media qurish (VIDEO tuzatilgan) ---------- */
    var IMAGE_EXT = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'avif'];
    var VIDEO_EXT = ['mp4', 'webm', 'mov', 'm4v', 'ogv', 'mkv', '3gp'];
    var AUDIO_EXT = ['mp3', 'wav', 'ogg', 'm4a', 'aac', 'weba'];

    function mediaKind(m) {
      var t = String(m.type || '').toUpperCase();
      var ext = String(m.mediaUrl || '').split('?')[0].toLowerCase().split('.').pop();
      if (t === 'VIDEO' || VIDEO_EXT.indexOf(ext) >= 0) return 'video';
      if (t === 'IMAGE' || IMAGE_EXT.indexOf(ext) >= 0) return 'image';
      if (t === 'AUDIO' || AUDIO_EXT.indexOf(ext) >= 0) return 'audio';
      return 'file';
    }

    function buildMedia(m, kind) {
      var url = mediaSrc(m.mediaUrl);
      if (kind === 'audio') {
        var a = document.createElement('audio');
        a.className = 'chat-audio'; a.controls = true; a.preload = 'metadata'; a.src = url;
        return a;
      }
      if (kind === 'file') {
        var l = el('a', 'chat-file-link', 'Faylni yuklab olish');
        l.href = url; l.target = '_blank'; l.rel = 'noopener';
        return l;
      }
      var wrap = el('div', 'chat-media-wrapper');
      if (kind === 'video') {
        wrap.classList.add('video-message');
        /* Boshlang'ich o'lcham beriladi — metadata kelguncha ham "chiziq" bo'lib qolmaydi */
        wrap.style.width = '220px';
        wrap.style.height = '300px';
        var video = document.createElement('video');
        video.className = 'video-foreground';
        video.src = url + '#t=0.1';
        video.preload = 'metadata';
        video.muted = true;
        video.playsInline = true;
        video.addEventListener('loadedmetadata', function () {
          var w = video.videoWidth, h = video.videoHeight;
          if (!w || !h) return;
          var s = Math.min(280 / w, 320 / h);
          wrap.style.width = Math.max(140, Math.round(w * s)) + 'px';
          wrap.style.height = Math.max(100, Math.round(h * s)) + 'px';
        });
        wrap.appendChild(video);
        var badge = el('div', 'video-play-badge');
        badge.innerHTML = '<i class="fa-solid fa-play"></i>';
        wrap.appendChild(badge);
        wrap.onclick = function () { openLightbox(url, true); };
      } else {
        var img = document.createElement('img');
        img.src = url; img.loading = 'lazy'; img.alt = '';
        wrap.appendChild(img);
        wrap.onclick = function () { openLightbox(url, false); };
      }
      return wrap;
    }

    /* ---------- xabar menyusi: tahrirlash / o'chirish ---------- */
    function closeMsgMenu() { document.querySelectorAll('.msg-menu').forEach(function (n) { n.remove(); }); }
    document.addEventListener('click', function (e) { if (!e.target.closest('.msg-menu-btn')) closeMsgMenu(); });

    function refreshMessages() { cachedMessagesJson = ''; loadMessages(false); }

    function openMsgMenu(btn, m, canEdit) {
      closeMsgMenu();
      var menu = el('div', 'msg-menu');
      if (canEdit) {
        var eb = el('button', null, 'Tahrirlash'); eb.type = 'button';
        eb.onclick = function () {
          closeMsgMenu();
          mgPrompt('Xabarni tahrirlash', m.content || '').then(function (nv) {
            if (nv === null || !nv.trim()) return;
            postJSON(CONTEXT_PATH + '/chat/action', {action: 'edit', messageId: m.id, content: nv.trim()})
                    .then(refreshMessages)
                    .catch(function () { showToast('Tahrirlab bo‘lmadi', 'error'); });
          });
        };
        menu.appendChild(eb);
      }
      var db = el('button', 'danger', 'O‘chirish'); db.type = 'button';
      db.onclick = function () {
        closeMsgMenu();
        mgConfirm('Xabarni o‘chirishni xohlaysizmi?', 'O‘chirish', true).then(function (ok) {
          if (!ok) return;
          postJSON(CONTEXT_PATH + '/chat/action', {action: 'delete', messageId: m.id})
                  .then(refreshMessages)
                  .catch(function () { showToast('O‘chirib bo‘lmadi', 'error'); });
        });
      };
      menu.appendChild(db);
      var r = btn.getBoundingClientRect();
      menu.style.top = (r.bottom + 6) + 'px';
      menu.style.left = Math.max(8, r.left - 120) + 'px';
      document.body.appendChild(menu);
    }

    /* ---------- xabarlarni yuklash ---------- */
    function loadMessages(forceScrollBottom) {
      if (!activeTargetUser) return;
      var requestedFor = activeTargetUser.id;
      fetch(CONTEXT_PATH + '/chat/send?targetUserId=' + encodeURIComponent(requestedFor))
              .then(function (res) { return res.json(); })
              .then(function (msgs) {
                if (!activeTargetUser || activeTargetUser.id !== requestedFor) return;
                var newJson = JSON.stringify(msgs);
                if (newJson === cachedMessagesJson) return;
                cachedMessagesJson = newJson;

                var prevTop = messagesList.scrollTop;
                var isNearBottom = messagesList.scrollHeight - messagesList.scrollTop - messagesList.clientHeight < 120;
                messagesList.innerHTML = '';

                if (!Array.isArray(msgs) || !msgs.length) {
                  messagesList.appendChild(el('div', 'text-muted text-center small', 'Xabarlar yo‘q. Birinchi bo‘lib yozing!'));
                  messagesList.lastChild.style.margin = 'auto';
                  return;
                }

                msgs.forEach(function (m) {
                  var isMine = String(m.senderId) === String(CURRENT_USER_ID);
                  var hasMedia = !!(m.mediaUrl && m.mediaUrl !== 'null');
                  var hasContent = !!(m.content && m.content.trim().length);
                  var dir = isMine ? 'outgoing' : 'incoming';
                  var bubble = document.createElement('div');

                  if (m.isDeleted) {
                    bubble.className = 'msg-bubble ' + dir;
                    bubble.textContent = 'Xabar o‘chirilgan';
                    bubble.style.fontStyle = 'italic';
                    bubble.style.opacity = '0.7';
                    messagesList.appendChild(bubble);
                    return;
                  }

                  var kind = hasMedia ? mediaKind(m) : null;
                  var mediaBubble = hasMedia && (kind === 'video' || kind === 'image');
                  if (mediaBubble && !hasContent) bubble.className = 'msg-bubble media-only ' + dir;
                  else if (mediaBubble && hasContent) bubble.className = 'msg-bubble has-media-text ' + dir;
                  else bubble.className = 'msg-bubble ' + dir;

                  if (hasMedia) bubble.appendChild(buildMedia(m, kind));
                  if (hasContent) {
                    var t = el('div', mediaBubble ? 'media-caption-text' : '', m.content);
                    bubble.appendChild(t);
                  }

                  if (isMine) {
                    var mb = el('button', 'msg-menu-btn'); mb.type = 'button'; mb.title = 'Amallar';
                    mb.innerHTML = '<i class="fa-solid fa-ellipsis-vertical"></i>';
                    mb.onclick = function (e) { e.stopPropagation(); openMsgMenu(mb, m, hasContent || !hasMedia); };
                    bubble.appendChild(mb);
                  }
                  messagesList.appendChild(bubble);
                });

                if (forceScrollBottom || isNearBottom) {
                  setTimeout(function () { messagesList.scrollTop = messagesList.scrollHeight; }, 50);
                } else {
                  messagesList.scrollTop = prevTop;
                }
              }).catch(function () {});
    }

    /* ---------- yuborish ---------- */
    sendForm.addEventListener('submit', function (e) {
      e.preventDefault();
      if (sending) return;
      if (!msgContentInput.value.trim() && !chatMediaInput.files.length) return;
      sending = true; sendBtn.disabled = true;
      var fd = new FormData(sendForm);
      fetch(CONTEXT_PATH + '/chat/send', {method: 'POST', body: fd})
              .then(function (res) {
                if (res.ok) {
                  msgContentInput.value = '';
                  chatMediaInput.value = '';
                  mediaPreviewBar.style.display = 'none';
                  cachedMessagesJson = '';
                  loadMessages(true);
                  saveRecentContact(activeTargetUser);
                  loadRecentContacts();
                } else {
                  showToast('Xabar yuborilmadi', 'error');
                }
              })
              .catch(function () { showToast('Tarmoq xatosi', 'error'); })
              .finally(function () { sending = false; sendBtn.disabled = false; });
    });

    /* ---------- boshlash ---------- */
    loadRecentContacts();

    /* Profil sahifasidagi "Message" tugmasidan kelganda: ?to=ID&username=..&name=..&avatar=.. */
    var qs = new URLSearchParams(location.search);
    if (qs.get('to')) {
      var uo = {
        id: qs.get('to'),
        username: qs.get('username') || '',
        fullName: qs.get('name') || qs.get('username') || '',
        avatar: qs.get('avatar') || ''
      };
      saveRecentContact(uo);
      loadRecentContacts();
      selectChatUser(uo);
    }
  })();
</script>
</body>
</html>
