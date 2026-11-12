<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Kirish</title>
    <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="auth-brand">
            <span class="logo-mark"><jsp:include page="/fragments/icons.jsp"/></span>
            <h1 class="brand-gradient">MilliyGram</h1>
        </div>
        <div class="auth-body">
            <p class="auth-sub">Hisobingizga kiring</p>
            <c:if test="${not empty errorMessage}"><div class="mg-error" id="serverError"><c:out value="${errorMessage}"/></div></c:if>
            <form action="${ctx}/login" method="post" autocomplete="on">
                <div class="mg-field"><label>Username</label><input class="form-control" type="text" name="username" required autofocus autocomplete="username"></div>
                <div class="mg-field"><label>Parol</label><input class="form-control" type="password" name="password" required autocomplete="current-password"></div>
                <button type="submit" class="auth-submit">Kirish</button>
            </form>
            <div class="auth-foot">Hisobingiz yo‘qmi? <a href="${ctx}/register">Ro‘yxatdan o‘tish</a></div>
        </div>
    </div>
</div>
<jsp:include page="/fragments/modals.jsp"/>
</body>
</html>
