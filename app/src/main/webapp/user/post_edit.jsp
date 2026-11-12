<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Postni tahrirlash</title>
    <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="/fragments/navbar.jsp"/>
    <main class="dashboard-content">
        <jsp:include page="/fragments/topbar.jsp"/>
        <div class="scrollable-main-area">
            <h3 class="page-title">Postni tahrirlash</h3>
            <form class="cp-layout" action="${ctx}/post/edit" method="post">
                <input type="hidden" name="id" value="${post.id}">
                <div class="cp-drop">
                    <c:choose>
                        <c:when test="${empty post.mediaUrl}"><div class="cp-empty"><div class="cp-icon"><i class="fa-regular fa-file-lines"></i></div><p>Bu postda rasm yoki video yo‘q</p></div></c:when>
                        <c:when test="${post.mediaType == 'VIDEO'}"><div class="cp-preview on"><video src="${ctx}/download?name=${post.mediaUrl}" controls muted></video></div></c:when>
                        <c:otherwise><div class="cp-preview on"><img src="${ctx}/download?name=${post.mediaUrl}" alt=""></div></c:otherwise>
                    </c:choose>
                </div>
                <div class="cp-form">
                    <div class="cp-user"><span>Matnni o‘zgartiring</span></div>
                    <div>
                        <textarea name="content" class="form-control" rows="8" maxlength="2000" required><c:out value="${post.content}"/></textarea>
                    </div>
                    <div style="display:flex;gap:10px;margin-top:auto">
                        <a href="${ctx}/" class="btn btn-ghost" style="flex:1;text-align:center;text-decoration:none">Bekor qilish</a>
                        <button type="submit" class="cp-submit" style="flex:2;margin-top:0">Saqlash</button>
                    </div>
                </div>
            </form>
        </div>
    </main>
</div>
<jsp:include page="/fragments/scripts.jsp"/>
</body>
</html>
