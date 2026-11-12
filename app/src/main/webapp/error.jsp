<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xatolik — MilliyGram</title>
    <style>
        body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
             font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;
             background:linear-gradient(135deg,#6366f1,#a855f7 55%,#d946ef);color:#1f2937}
        .box{background:#fff;border-radius:16px;padding:32px 28px;max-width:380px;width:calc(100% - 32px);
             text-align:center;box-shadow:0 20px 50px rgba(0,0,0,.18)}
        h1{margin:0 0 8px;font-size:44px;color:#8b5cf6}
        p{margin:0 0 20px;color:#6b7280}
        a{display:inline-block;padding:10px 22px;border-radius:10px;color:#fff;text-decoration:none;font-weight:600;
          background:linear-gradient(90deg,#6366f1,#d946ef)}
    </style>
</head>
<body>
<div class="box">
    <c:set var="code" value="${requestScope['jakarta.servlet.error.status_code']}"/>
    <h1><c:out value="${empty code ? 'Xato' : code}"/></h1>
    <p>
        <c:choose>
            <c:when test="${code == 404}">Bunday sahifa topilmadi.</c:when>
            <c:when test="${code == 403}">Bu amalni bajarishga ruxsatingiz yo‘q.</c:when>
            <c:when test="${code == 400}">So‘rovda xatolik bor.</c:when>
            <c:otherwise>Kutilmagan xatolik yuz berdi. Birozdan keyin qayta urinib ko‘ring.</c:otherwise>
        </c:choose>
    </p>
    <a href="/">Bosh sahifaga</a>
</div>
</body>
</html>
