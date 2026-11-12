<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:if test="${empty sessionScope.id}">
    <c:redirect url="/login"/>
</c:if>
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Feed</title>
    <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="/fragments/navbar.jsp"/>
    <main class="dashboard-content">
        <jsp:include page="/fragments/topbar.jsp"/>
        <div class="scrollable-main-area">
            <!-- Haqiqiy hikoyalar: faqat o'zim va men kuzatayotganlar, 24 soat -->
            <div class="stories-container" id="storiesBar"></div>

            <div class="feed-grid-layout">
                <c:if test="${empty posts}">
                    <div class="pf-empty">Hozircha postlar yo‘q. Yangi post yarating!</div>
                </c:if>
                <c:forEach var="p" items="${posts}">
                    <c:set var="card" value="${p}" scope="request"/>
                    <jsp:include page="/fragments/post_card.jsp"/>
                </c:forEach>
            </div>
            <c:if test="${hasMore}">
                <div class="feed-more"><a class="feed-more-btn" href="${ctx}/?before=${nextBefore}">Oldingi postlarni ko'rsatish</a></div>
            </c:if>
        </div>
    </main>
</div>
<jsp:include page="/fragments/scripts.jsp"/>
</body>
</html>
