<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MilliyGram — Ro‘yxatdan o‘tish</title>
  <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="auth-wrap">
  <div class="auth-card wide">
    <div class="auth-brand">
      <span class="logo-mark"><jsp:include page="/fragments/icons.jsp"/></span>
      <h1 class="brand-gradient">MilliyGram</h1>
    </div>
    <div class="auth-body">
      <p class="auth-sub">Yangi hisob yarating</p>
      <c:if test="${not empty errorMessage}"><div class="mg-error" id="serverError"><c:out value="${errorMessage}"/></div></c:if>
      <div class="mg-error" id="rgError" style="display:none"></div>

      <form id="rgForm" action="${ctx}/register" method="post" autocomplete="off">
        <!-- Profil foni: rasm yoki video (uzun bo'lsa avtomatik 3 soniyaga kesiladi) -->
        <div class="rg-head">
          <div class="pick-cover" id="rgCover">
            <div id="rgCoverMedia" style="position:absolute;inset:0"></div>
            <div class="pick-label"><i class="fa-solid fa-film"></i>Profil foni — rasm yoki video<br><small>Video 3 soniyaga avtomatik kesiladi</small></div>
            <div class="pick-busy" id="rgBusy">Video 3 soniyaga kesilmoqda...</div>
          </div>
          <div class="pick-avatar" id="rgAvatar" title="Profil rasmi">
            <img id="rgAvatarImg" alt="" src="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E">
            <div class="pick-cam"><i class="fa-solid fa-camera"></i></div>
          </div>
        </div>
        <input type="file" id="rgCoverIn" accept="image/*,video/*" style="display:none">
        <input type="file" id="rgAvatarIn" accept="image/*" style="display:none">
        <div class="rg-hint" style="text-align:center;margin:6px 0 14px">Profil rasmi uchun doira ustiga bosing</div>

        <div class="mg-field"><label>To‘liq ism</label><input class="form-control" type="text" id="fFull" name="fullname" maxlength="100" required></div>
        <div class="rg-grid">
          <div class="mg-field"><label>Username</label><input class="form-control" type="text" id="fUser" name="username" maxlength="30" required autocomplete="off"></div>
          <div class="mg-field"><label>Parol</label><input class="form-control" type="password" id="fPass" name="password" required autocomplete="new-password"></div>
        </div>
        <div class="mg-field"><label>Joylashuv</label><input class="form-control" type="text" id="fLoc" maxlength="100" placeholder="Masalan: Toshkent, O‘zbekiston"></div>
        <div class="mg-field"><label>Bio</label><textarea class="form-control" id="fBio" rows="3" maxlength="300" placeholder="O‘zingiz haqingizda qisqacha..."></textarea></div>

        <button type="submit" class="auth-submit" id="rgSubmit">Ro‘yxatdan o‘tish</button>
      </form>
      <div class="auth-foot">Hisobingiz bormi? <a href="${ctx}/login">Kirish</a></div>
    </div>
  </div>
</div>

<jsp:include page="/fragments/scripts.jsp"/>
<script>
  (function () {
    var avatarFile = null, coverFile = null;
    function fail(m) { var e = $id('rgError'); e.textContent = m; e.style.display = m ? 'block' : 'none'; e.scrollIntoView({block: 'nearest'}); }
    $id('rgCover').onclick = function () { $id('rgCoverIn').click(); };
    $id('rgAvatar').onclick = function () { $id('rgAvatarIn').click(); };
    $id('rgAvatarIn').onchange = function () {
      var f = this.files[0]; this.value = ''; if (!f) return;
      if (f.type.indexOf('image/') !== 0) return fail('Profil rasmi uchun rasm tanlang');
      avatarFile = f; $id('rgAvatarImg').src = URL.createObjectURL(f);
    };
    $id('rgCoverIn').onchange = function () {
      var f = this.files[0]; this.value = ''; if (!f) return;
      MG.processCover(f, function (b) { $id('rgBusy').classList.toggle('on', b); }).then(function (r) {
        coverFile = r.file;
        var host = $id('rgCoverMedia'); host.innerHTML = '';
        var n = document.createElement(r.isVideo ? 'video' : 'img'); n.src = r.url;
        if (r.isVideo) { n.autoplay = true; n.muted = true; n.loop = true; n.playsInline = true; }
        host.appendChild(n);
        if (r.trimmed) showToast('Video 3 soniyaga qisqartirildi');
      }).catch(function (e) { fail(e.message); });
    };

    $id('rgForm').addEventListener('submit', function (ev) {
      ev.preventDefault(); fail('');
      var full = $id('fFull').value.trim(), user = $id('fUser').value.trim(), pass = $id('fPass').value;
      if (!full) return fail('To‘liq ismni kiriting');
      if (!/^[A-Za-z0-9_.]{3,30}$/.test(user)) return fail('Username 3-30 belgi: harf, raqam, _ yoki .');
      if (pass.length < 6) return fail('Parol kamida 6 belgidan iborat bo‘lsin');
      var btn = $id('rgSubmit'); btn.disabled = true; btn.textContent = 'Yaratilmoqda...';

      // 1) mavjud /register servleti hisob yaratadi va sessiyani ochadi
      fetch(CONTEXT_PATH + '/register', {
        method: 'POST', credentials: 'same-origin',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({fullname: full, username: user, password: pass}).toString()
      }).then(function (r) {
        return r.text().then(function (html) {
          var m = html.match(/id="serverError"[^>]*>([^<]+)</);
          if (!r.redirected || m) throw new Error(m ? m[1].trim() : 'Ro‘yxatdan o‘tib bo‘lmadi');
        });
      }).then(function () {
        // 2) qo'shimcha ma'lumotlar: rasm, joylashuv, bio, fon
        var loc = $id('fLoc').value.trim(), bio = $id('fBio').value.trim();
        if (!avatarFile && !coverFile && !loc && !bio) return;
        var fd = new FormData();
        fd.append('fullName', full); fd.append('username', user);
        fd.append('location', loc); fd.append('bio', bio);
        if (avatarFile) fd.append('avatar', avatarFile);
        if (coverFile) fd.append('cover', coverFile);
        return apiForm('/profile/edit', fd).catch(function () { showToast('Qo‘shimcha ma‘lumotlarni keyinroq profilda to‘ldiring', 'error'); });
      }).then(function () {
        location.href = CONTEXT_PATH + '/';
      }).catch(function (e) { btn.disabled = false; btn.textContent = 'Ro‘yxatdan o‘tish'; fail(e.message); });
    });
  })();
</script>
</body>
</html>
