<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />
<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${profileUser.username}"/> — MilliyGram</title>
  <jsp:include page="/fragments/head.jsp"/>
  <style>
    /* Profil kartasi: fon (rasm/video) butun karta orqasida, ma'lumotlar uning ustida */
    .pf-card { position: relative; border-radius: 22px; }
    .pf-cover { position: absolute; inset: 0; height: auto; z-index: 0; }
    .pf-cover::after { display: none; }
    .pf-body { position: relative; z-index: 2; padding: 30px 40px; gap: 40px; align-items: center; }
    .avatar-ring { margin-top: 0; }
    .avatar-ring img { width: 110px; height: 110px; }
    .pf-info { padding-top: 0; }
    .pf-info, .pf-info * { transition: color .35s, text-shadow .35s; }
    /* FON QORONG'U -> yozuvlar OCH */
    .pf-card.tone-dark .pf-info, .pf-card.tone-dark .pf-info * { color: #fff; text-shadow: 0 1px 6px rgba(0,0,0,.55); }
    .pf-card.tone-dark .pf-stats span { color: rgba(255,255,255,.85); }
    .pf-card.tone-dark .pf-btn { background: rgba(255,255,255,.2); border-color: rgba(255,255,255,.45); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); text-shadow: none; }
    /* FON YORQIN -> yozuvlar TO'Q */
    .pf-card.tone-light .pf-info, .pf-card.tone-light .pf-info * { color: #0f172a; text-shadow: 0 1px 5px rgba(255,255,255,.6); }
    .pf-card.tone-light .pf-stats span { color: rgba(15,23,42,.8); }
    .pf-card.tone-light .pf-btn { background: rgba(255,255,255,.6); border-color: rgba(15,23,42,.25); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); text-shadow: none; }
    .pf-card.has-cover .pf-btn.blue { background: var(--accent-blue); border-color: var(--accent-blue); color: #fff; }
    @media (max-width: 640px) { .pf-body { padding: 22px; gap: 20px; } }
  </style>
</head>
<body>
<div class="dashboard-container">
  <jsp:include page="/fragments/navbar.jsp"/>
  <main class="dashboard-content">
    <jsp:include page="/fragments/topbar.jsp"/>
    <div class="scrollable-main-area">

      <div class="pf-card">
        <!-- Profil foni: rasm yoki 3 soniyalik video (aylanib turadi) -->
        <div class="pf-cover" id="pfCover" data-cover="<c:out value='${profileUser.coverUrl}'/>">
          <%-- fon rasm/videoni JS qo'yadi (EL da regex xato beradi) --%>
        </div>

        <div class="pf-body">
          <!-- Hikoyasi bo'lsa avatar atrofida qizil halqa chiqadi (JS aniqlaydi) -->
          <div class="avatar-ring" id="pfRing" data-uid="${profileUser.id}">
            <img id="pfAvatar" src="${not empty profileUser.avatarUrl ? ctx.concat('/download?name=').concat(profileUser.avatarUrl) : defAvatar}" alt="Avatar">
          </div>

          <div class="pf-info">
            <div class="pf-line1">
              <h2 id="pfUsername"><c:out value="${profileUser.username}"/><c:if test="${profileUser.verifiedUser}"><jsp:include page="/fragments/verified.jsp"/></c:if></h2>
              <c:choose>
                <c:when test="${isMyProfile}">
                  <button type="button" class="pf-btn" id="editProfileBtn">Edit profile</button>
                  <a href="${ctx}/post/create" class="pf-btn">New post</a>
                </c:when>
                <c:otherwise>
                  <button type="button" id="followBtn" class="pf-btn ${isFollowing ? '' : 'blue'}">${isFollowing ? 'Following' : 'Follow'}</button>
                  <c:url var="msgUrl" value="/user/chat.jsp">
                    <c:param name="to" value="${profileUser.id}"/>
                    <c:param name="username" value="${profileUser.username}"/>
                    <c:param name="name" value="${profileUser.fullName}"/>
                    <c:param name="avatar" value="${profileUser.avatarUrl}"/>
                  </c:url>
                  <a href="${msgUrl}" class="pf-btn">Message</a>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="pf-stats">
              <div><strong><c:out value="${not empty profilePosts ? profilePosts.size() : 0}"/></strong> <span>posts</span></div>
              <c:choose>
                <c:when test="${isMyProfile}">
                  <button type="button" data-stat-list="followers"><strong data-stat="followers">${not empty followersCount ? followersCount : 0}</strong> <span>followers</span></button>
                  <button type="button" data-stat-list="following"><strong data-stat="following">${not empty followingCount ? followingCount : 0}</strong> <span>following</span></button>
                </c:when>
                <c:otherwise>
                  <div><strong id="followersCount">${not empty followersCount ? followersCount : 0}</strong> <span>followers</span></div>
                  <div><strong>${not empty followingCount ? followingCount : 0}</strong> <span>following</span></div>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="pf-name" id="pfName"><c:out value="${profileUser.fullName}"/></div>
            <c:if test="${not empty profileUser.bio}"><div class="pf-bio" id="pfBio"><c:out value="${profileUser.bio}"/></div></c:if>
            <c:if test="${not empty profileUser.location}"><div class="pf-loc" id="pfLoc"><i class="fa-solid fa-location-dot"></i> <c:out value="${profileUser.location}"/></div></c:if>
          </div>
        </div>
      </div>

      <h3 class="page-title">POSTS</h3>
      <div class="feed-grid-layout">
        <c:if test="${empty profilePosts}"><div class="pf-empty">Hozircha postlar mavjud emas.</div></c:if>
        <c:forEach var="p" items="${profilePosts}">
          <c:set var="card" value="${p}" scope="request"/>
          <jsp:include page="/fragments/post_card.jsp"/>
        </c:forEach>
      </div>
    </div>
  </main>
</div>

<jsp:include page="/fragments/scripts.jsp"/>
<script>
  var PROFILE_ID = '${profileUser.id}';
  var IS_MINE = ${isMyProfile ? 'true' : 'false'};
  var profileStory = null;

  /* --- profil foni: rasm yoki video --- */
  (function () {
    var box = $id('pfCover'), name = box.getAttribute('data-cover');
    if (!name) return;
    var video = isVideoName(name);
    var n = document.createElement(video ? 'video' : 'img');
    if (video) {
      n.muted = true; n.defaultMuted = true; n.loop = true; n.autoplay = true; n.playsInline = true;
      n.setAttribute('muted', ''); n.setAttribute('playsinline', ''); n.setAttribute('loop', ''); n.setAttribute('autoplay', '');
      n.preload = 'auto';
    }
    n.src = mediaSrc(name);
    box.appendChild(n);
    var card = box.parentNode;
    card.classList.add('has-cover', 'tone-dark');

    /* Fon yorqinligini o'lchab, yozuv rangini tanlaymiz (video bo'lsa har yarim soniyada qayta) */
    var cv = document.createElement('canvas'); cv.width = 48; cv.height = 24;
    var cx = cv.getContext('2d', {willReadFrequently: true});
    function measure() {
      try {
        var w = video ? n.videoWidth : n.naturalWidth, h = video ? n.videoHeight : n.naturalHeight;
        if (!w || !h) return;
        // karta ko'rinishidagi kabi "cover" kesim
        var bw = card.clientWidth, bh = card.clientHeight, sc = Math.max(bw / w, bh / h);
        var sw = bw / sc, sh = bh / sc, sx = (w - sw) / 2, sy = (h - sh) / 2;
        cx.drawImage(n, sx, sy, sw, sh, 0, 0, 48, 24);
        var d = cx.getImageData(0, 0, 48, 24).data, sum = 0, cnt = 0;
        for (var i = 0; i < d.length; i += 4) { sum += 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]; cnt++; }
        var lum = sum / cnt;                       // 0..255
        var light = card.classList.contains('tone-light');
        // gisterezis: rang tez-tez "miltillamasligi" uchun
        if (!light && lum > 150) { card.classList.remove('tone-dark'); card.classList.add('tone-light'); }
        else if (light && lum < 125) { card.classList.remove('tone-light'); card.classList.add('tone-dark'); }
      } catch (e) { /* o'lchab bo'lmasa, oq yozuv qoladi */ }
    }
    if (video) {
      function go() { var pr = n.play(); if (pr && pr.catch) pr.catch(function () {}); }
      n.addEventListener('canplay', go); go();
      document.addEventListener('click', go, {once: true});
      n.addEventListener('loadeddata', measure);
      setInterval(measure, 500);
    } else {
      if (n.complete) measure(); else n.addEventListener('load', measure);
    }
  })();

  /* --- hikoya halqasi --- */
  function loadProfileStory() {
    api('/stories?userId=' + encodeURIComponent(PROFILE_ID)).then(function (g) {
      var ring = $id('pfRing');
      profileStory = (g && g.length) ? g[0] : null;
      ring.classList.toggle('has-story', !!profileStory);
      ring.classList.toggle('seen', !!profileStory && groupSeen(profileStory));
    }).catch(function () {});
  }
  window.onStoriesChanged = loadProfileStory;
  $id('pfRing').addEventListener('click', function () {
    if (profileStory) openStoryGroups([profileStory], 0);
  });
  loadProfileStory();

  /* --- Follow (boshqa odam profili) --- */
  var fb = $id('followBtn');
  if (fb) fb.addEventListener('click', function () {
    fb.disabled = true;
    toggleFollow(PROFILE_ID, function (d) {
      fb.disabled = false;
      fb.textContent = d.following ? 'Following' : 'Follow';
      fb.className = 'pf-btn' + (d.following ? '' : ' blue');
      if (d.followersCount !== undefined) $id('followersCount').textContent = d.followersCount;
      loadProfileStory();   // endi kuzatayotgan bo'lsam hikoyasini ko'raman
    });
    setTimeout(function () { fb.disabled = false; }, 4000);
  });

  /* --- Edit profile (Instagram kabi) --- */
  var eb = $id('editProfileBtn');
  if (eb) eb.addEventListener('click', function () {
    api('/me').then(openEdit).catch(function (e) { showToast(e.message, 'error'); });
  });

  function field(label, node, hint) {
    var f = el('div', 'mg-field'); f.appendChild(el('label', null, label)); f.appendChild(node);
    if (hint) f.appendChild(el('div', 'rg-hint', hint));
    return f;
  }
  function openEdit(u) {
    var newAvatar = null, newCover = null;
    var wrap = el('div');
    var err = el('div', 'mg-error'); err.style.display = 'none'; wrap.appendChild(err);

    var cover = el('div', 'pick-cover');
    var coverMedia = el('div'); coverMedia.style.cssText = 'position:absolute;inset:0';
    cover.appendChild(coverMedia);
    function showCover(url, isVideo) {
      coverMedia.innerHTML = '';
      if (!url) return;
      var n = document.createElement(isVideo ? 'video' : 'img'); n.src = url;
      if (isVideo) { n.autoplay = true; n.muted = true; n.loop = true; n.playsInline = true; }
      coverMedia.appendChild(n);
    }
    if (u.coverUrl) showCover(mediaSrc(u.coverUrl), isVideoName(u.coverUrl));
    var lab = el('div', 'pick-label'); lab.innerHTML = '<i class="fa-solid fa-film"></i>Profil foni (rasm yoki 3 soniyalik video)';
    var busy = el('div', 'pick-busy', 'Video 3 soniyaga kesilmoqda...');
    cover.appendChild(lab); cover.appendChild(busy);
    var cin = el('input'); cin.type = 'file'; cin.accept = 'image/*,video/*'; cin.style.display = 'none';
    cover.onclick = function () { cin.click(); };
    cin.onchange = function () {
      var f = cin.files[0]; cin.value = ''; if (!f) return;
      MG.processCover(f, function (b) { busy.classList.toggle('on', b); }).then(function (r) {
        newCover = r.file; showCover(r.url, r.isVideo);
        if (r.trimmed) showToast('Video 3 soniyaga qisqartirildi');
      }).catch(function (e) { showToast(e.message, 'error'); });
    };
    wrap.appendChild(cover); wrap.appendChild(cin);

    var av = el('div', 'pick-avatar');
    var avImg = el('img'); avImg.src = resolveAvatar(u.avatarUrl);
    var cam = el('div', 'pick-cam'); cam.innerHTML = '<i class="fa-solid fa-camera"></i>';
    av.appendChild(avImg); av.appendChild(cam);
    var ain = el('input'); ain.type = 'file'; ain.accept = 'image/*'; ain.style.display = 'none';
    av.onclick = function () { ain.click(); };
    ain.onchange = function () {
      var f = ain.files[0]; ain.value = ''; if (!f) return;
      if (f.type.indexOf('image/') !== 0) return showToast('Profil rasmi uchun rasm tanlang', 'error');
      newAvatar = f; avImg.src = URL.createObjectURL(f);
    };
    wrap.appendChild(av); wrap.appendChild(ain);
    var ch = el('div', 'rg-hint', 'Rasmni almashtirish uchun bosing'); ch.style.cssText = 'text-align:center;margin:6px 0 12px'; wrap.appendChild(ch);

    var iName = el('input', 'form-control'); iName.value = u.fullName || ''; iName.maxLength = 100;
    var iUser = el('input', 'form-control'); iUser.value = u.username || ''; iUser.maxLength = 30;
    var iLoc = el('input', 'form-control'); iLoc.value = u.location || ''; iLoc.maxLength = 100; iLoc.placeholder = 'Masalan: Toshkent, O‘zbekiston';
    var iBio = el('textarea', 'form-control'); iBio.rows = 3; iBio.maxLength = 300; iBio.value = u.bio || '';
    wrap.appendChild(field('Ism', iName));
    wrap.appendChild(field('Username', iUser, 'Harf, raqam, _ yoki . (3-30 belgi)'));
    wrap.appendChild(field('Joylashuv', iLoc));
    wrap.appendChild(field('Bio', iBio));

    function fail(m) { err.textContent = m; err.style.display = 'block'; wrap.parentNode.scrollTop = 0; }
    mgModal('Profilni tahrirlash', wrap, [
      {text: 'Bekor qilish', onClick: function (m) { m.close(); }},
      {text: 'Saqlash', cls: 'btn-primary', onClick: function (m, btn) {
          err.style.display = 'none';
          if (!/^[A-Za-z0-9_.]{3,30}$/.test(iUser.value.trim())) return fail('Username 3-30 belgi: harf, raqam, _ yoki .');
          if (!iName.value.trim()) return fail('Ismni kiriting');
          var fd = new FormData();
          fd.append('fullName', iName.value.trim()); fd.append('username', iUser.value.trim());
          fd.append('location', iLoc.value.trim()); fd.append('bio', iBio.value.trim());
          if (newAvatar) fd.append('avatar', newAvatar);
          if (newCover) fd.append('cover', newCover);
          btn.disabled = true; btn.textContent = 'Saqlanmoqda...';
          apiForm('/profile/edit', fd).then(function () {
            try { sessionStorage.removeItem('mg_me'); } catch (e) {}
            showToast('Profil yangilandi'); setTimeout(function () { location.reload(); }, 500);
          }).catch(function (e) { btn.disabled = false; btn.textContent = 'Saqlash'; fail(e.message); });
        }}
    ], {wide: true});
  }
</script>
</body>
</html>
