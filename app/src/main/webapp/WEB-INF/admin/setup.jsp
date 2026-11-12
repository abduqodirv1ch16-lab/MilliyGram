<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex,nofollow">
  <title>Bosh adminni yaratish — MilliyGram</title>
  <style>
    <%@ include file="style.jspf" %>
    body{display:flex;justify-content:center;padding:40px 16px}
    .card{width:100%;max-width:820px;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius-lg);overflow:hidden}
    .band{height:10px;background:var(--ikat)}
    .inner{display:grid;grid-template-columns:1fr 1fr;gap:36px;padding:34px}
    h1{font-size:22px;margin:0 0 6px}
    .lead{color:var(--muted);margin:0 0 22px}
    ol{margin:0 0 18px;padding-left:20px;color:var(--muted)}
    ol li{margin-bottom:8px}
    ol b{color:var(--text)}
    .qr{display:inline-block;padding:10px;background:#fff;border-radius:var(--radius)}
    .qr svg{display:block}
    .secret{margin-top:12px;font-size:13px;color:var(--muted)}
    .secret code{display:block;margin-top:6px;padding:9px 12px;border-radius:var(--radius-sm);background:var(--raised);color:var(--text);font-size:14px;letter-spacing:.06em;word-break:break-all}
    @media (max-width:760px){.inner{grid-template-columns:1fr;padding:22px}}
  </style>
</head>
<body>
<div class="card">
  <div class="band"></div>
  <div class="inner">
    <section>
      <h1>Bosh adminni yaratish</h1>
      <p class="lead">Bu sahifa faqat bir marta ishlaydi. Admin yaratilgach, havola o'chadi.</p>
      <ol>
        <li>Telefoningizga <b>Google Authenticator</b> ilovasini o'rnating.</li>
        <li>Ilovada <b>+</b> tugmasini bosib, <b>QR kodni skanerlang</b>.</li>
        <li>Login va kuchli parol o'ylab toping, ilovadagi kodni kiriting.</li>
      </ol>
      <div class="qr">${qrSvg}</div>
      <div class="secret">QR kodni skanerlay olmasangiz, bu kalitni ilovaga qo'lda kiriting:<code><c:out value="${secret}"/></code></div>
    </section>
    <section>
      <c:if test="${not empty error}"><div class="alert err" role="alert"><c:out value="${error}"/></div></c:if>
      <form method="post" action="${pageContext.request.contextPath}/mgadmin/setup" autocomplete="off">
        <input type="hidden" name="ft" value="<c:out value='${formToken}'/>">
        <input type="hidden" name="token" value="<c:out value='${token}'/>">
        <div class="field">
          <label for="username">Login</label>
          <input class="input" id="username" name="username" maxlength="40" pattern="[A-Za-z0-9_.\-]{4,40}" required autofocus>
        </div>
        <div class="field">
          <label for="password">Parol (kamida 12 belgi: katta-kichik harf, raqam, belgi)</label>
          <input class="input" id="password" name="password" type="password" minlength="12" maxlength="200" autocomplete="new-password" required>
        </div>
        <div class="field">
          <label for="password2">Parolni takrorlang</label>
          <input class="input" id="password2" name="password2" type="password" minlength="12" maxlength="200" autocomplete="new-password" required>
        </div>
        <div class="field">
          <label for="code">Google Authenticator'dagi 6 xonali kod</label>
          <input class="input code" id="code" name="code" inputmode="numeric" maxlength="7" autocomplete="one-time-code" required>
        </div>
        <button class="btn primary block" type="submit">Bosh adminni yaratish</button>
      </form>
    </section>
  </div>
</div>
</body>
</html>
