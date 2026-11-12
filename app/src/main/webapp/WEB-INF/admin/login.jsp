<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex,nofollow">
  <title>Boshqaruv paneli — MilliyGram</title>
  <script nonce="${cspNonce}">try{var t=localStorage.getItem('mg_admin_theme');if(t)document.documentElement.setAttribute('data-theme',t)}catch(e){}</script>
  <style>
    <%@ include file="style.jspf" %>
    .wrap{min-height:100%;display:grid;grid-template-columns:minmax(0,1fr) minmax(360px,480px)}
    .art{position:relative;background:var(--ikat);overflow:hidden}
    .art::after{content:"";position:absolute;inset:0;background:linear-gradient(180deg,rgba(20,17,43,.15),rgba(20,17,43,.75))}
    .art-text{position:absolute;left:48px;bottom:44px;right:48px;z-index:1;color:#fff;max-width:440px}
    .art-text h2{font-size:34px;line-height:1.15;margin:0 0 10px;font-weight:700;letter-spacing:-.01em}
    .art-text p{margin:0;color:rgba(255,255,255,.78);font-size:15px}
    .side{display:flex;flex-direction:column;justify-content:center;padding:48px 44px;background:var(--surface);border-left:1px solid var(--line)}
    .brand{display:flex;align-items:center;gap:10px;font-weight:700;font-size:17px;margin-bottom:34px}
    .brand-mark{width:34px;height:34px;border-radius:10px;background:var(--ikat);box-shadow:inset 0 0 0 1px rgba(255,255,255,.15)}
    h1{font-size:24px;margin:0 0 6px;letter-spacing:-.01em}
    .lead{color:var(--muted);margin:0 0 26px}
    .steps{display:flex;gap:6px;margin-bottom:26px}
    .steps span{height:4px;flex:1;border-radius:4px;background:var(--line)}
    .steps span.on{background:var(--violet)}
    .hint{font-size:12.5px;color:var(--faint);margin-top:18px;line-height:1.55}
    .back{display:inline-block;margin-top:14px;font-size:13px;color:var(--muted)}
    @media (max-width:860px){.wrap{grid-template-columns:1fr}.art{display:none}.side{border-left:0;padding:36px 22px;min-height:100vh}}
  </style>
</head>
<body>
<div class="wrap">
  <div class="art" aria-hidden="true">
    <div class="art-text">
      <h2>MilliyGram boshqaruv paneli</h2>
      <p>Foydalanuvchilar, kontent va shikoyatlarni bir joydan boshqaring. Har bir harakat jurnalga yoziladi.</p>
    </div>
  </div>

  <main class="side">
    <div class="brand"><span class="brand-mark"></span> MilliyGram Admin</div>

    <div class="steps" aria-hidden="true">
      <span class="on"></span><span class="${stage == 'totp' ? 'on' : ''}"></span>
    </div>

    <c:if test="${not empty error}"><div class="alert err" role="alert"><c:out value="${error}"/></div></c:if>
    <c:if test="${not empty info}"><div class="alert info" role="status"><c:out value="${info}"/></div></c:if>

    <c:choose>
      <c:when test="${stage == 'totp'}">
        <h1>Tasdiqlash kodi</h1>
        <p class="lead">Telefoningizdagi Google Authenticator ilovasini oching va MilliyGram Admin uchun 6 xonali kodni kiriting.</p>
        <form method="post" action="${pageContext.request.contextPath}/mgadmin/login" autocomplete="off">
          <input type="hidden" name="ft" value="<c:out value='${formToken}'/>">
          <input type="hidden" name="step" value="totp">
          <div class="field">
            <label for="code">6 xonali kod</label>
            <input class="input code" id="code" name="code" inputmode="numeric" pattern="[0-9 ]{6,7}" maxlength="7" autocomplete="one-time-code" required autofocus>
          </div>
          <button class="btn primary block" type="submit">Kirish</button>
        </form>
        <p class="hint">Kod har 30 soniyada yangilanadi. Parol kiritilganidan keyin kodni 5 daqiqa ichida kiritish kerak.</p>
        <a class="back" href="${pageContext.request.contextPath}/mgadmin/login?restart=1">Boshqa akkaunt bilan kirish</a>
      </c:when>
      <c:otherwise>
        <h1>Admin sifatida kirish</h1>
        <p class="lead">Bu sahifa faqat sayt administratorlari uchun.</p>
        <form method="post" action="${pageContext.request.contextPath}/mgadmin/login" autocomplete="off">
          <input type="hidden" name="ft" value="<c:out value='${formToken}'/>">
          <input type="hidden" name="step" value="password">
          <div class="field">
            <label for="username">Login</label>
            <input class="input" id="username" name="username" maxlength="40" autocomplete="username" required autofocus>
          </div>
          <div class="field">
            <label for="password">Parol</label>
            <input class="input" id="password" name="password" type="password" maxlength="200" autocomplete="current-password" required>
          </div>
          <button class="btn primary block" type="submit">Davom etish</button>
        </form>
        <p class="hint">5 marta noto'g'ri urinishdan keyin akkaunt 15 daqiqaga bloklanadi. Barcha urinishlar IP manzili bilan jurnalga yoziladi.</p>
        <c:if test="${noAdmins}"><p class="hint">Hali birorta admin yaratilmagan. Serverdagi o'rnatish havolasidan foydalaning.</p></c:if>
      </c:otherwise>
    </c:choose>
  </main>
</div>
</body>
</html>
