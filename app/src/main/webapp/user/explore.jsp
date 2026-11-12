<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Explore</title>
    <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="/fragments/navbar.jsp"/>
    <main class="dashboard-content">
        <jsp:include page="/fragments/topbar.jsp"/>
        <div class="scrollable-main-area">
            <section class="ex-head">
                <div>
                    <h1 class="ex-title"><c:choose><c:when test="${not empty tag}">#<c:out value="${tag}"/></c:when><c:otherwise>Explore</c:otherwise></c:choose></h1>
                    <p class="ex-sub"><c:choose>
                        <c:when test="${not empty tag}">Shu hashtag bilan yozilgan eng mashhur postlar</c:when>
                        <c:otherwise>Shu hafta eng ko'p yoqtirilgan va muhokama qilingan postlar</c:otherwise>
                    </c:choose></p>
                </div>
                <c:if test="${not empty tag}"><a class="ex-clear" href="${ctx}/explore">Barcha trendlar</a></c:if>
            </section>

            <c:if test="${not empty tags}">
                <nav class="ex-tags" aria-label="Ommabop hashtaglar">
                    <c:forEach var="t" items="${tags}">
                        <c:url var="tagUrl" value="/explore"><c:param name="tag" value="${t.key}"/></c:url>
                        <a class="ex-tag ${t.key == tag ? 'on' : ''}" href="${tagUrl}">#<c:out value="${t.key}"/><span><c:out value="${t.value}"/></span></a>
                    </c:forEach>
                </nav>
            </c:if>

            <c:if test="${empty tag and not empty people}">
                <section class="ex-people" aria-label="Ommabop akkauntlar">
                    <h2 class="ex-h2">Ko'p kuzatiladigan akkauntlar</h2>
                    <div class="ex-people-row">
                        <c:forEach var="u" items="${people}">
                            <div class="ex-person">
                                <a href="${ctx}/user/profile?id=${u.id}" class="ex-person-link">
                                    <img src="${empty u.avatar ? defAvatar : ctx.concat('/download?name=').concat(u.avatar)}" alt="" loading="lazy">
                                    <b><c:out value="${u.username}"/><c:if test="${u.verified}"><jsp:include page="/fragments/verified.jsp"/></c:if></b>
                                    <span><c:out value="${u.followers}"/> kuzatuvchi</span>
                                </a>
                                <button type="button" class="ex-follow ${u.iFollow ? 'on' : ''}" data-follow-id="${u.id}">${u.iFollow ? 'Kuzatilmoqda' : 'Kuzatish'}</button>
                            </div>
                        </c:forEach>
                    </div>
                </section>
            </c:if>

            <c:choose>
                <c:when test="${empty posts}">
                    <div class="pf-empty">
                        <c:choose>
                            <c:when test="${not empty tag}">Bu hashtag bilan hali post yo'q. Birinchi bo'lib yozing!</c:when>
                            <c:otherwise>Hali trendlar yo'q. Post yarating — u shu yerda chiqishi mumkin.</c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ex-grid">
                        <c:forEach var="p" items="${posts}" varStatus="st">
                            <div class="ex-item js-post ${st.index % 10 == 0 and not empty p.mediaUrl() ? 'big' : ''}"
                                 data-post-id="${p.id()}" data-author-id="${p.authorId()}"
                                 data-author="<c:out value='${p.authorUsername()}'/>"
                                 data-verified="${p.authorVerified()}"
                                 data-avatar="<c:out value='${p.authorAvatar()}'/>"
                                 data-content="<c:out value='${p.content()}'/>"
                                 data-media-url="<c:out value='${p.mediaUrl()}'/>"
                                 data-media-type="<c:out value='${p.mediaType()}'/>"
                                 data-likes="${p.likeCount()}" data-comments="${p.commentCount()}"
                                 data-views="${p.viewCount()}" data-created="" data-liked="${p.isLikedByMe()}" data-saved="${p.isSavedByMe()}">
                                <a href="#post-${p.id()}" class="ex-link" data-open-post="${p.id()}">
                                    <c:choose>
                                        <c:when test="${empty p.mediaUrl()}"><div class="ex-text"><c:out value="${p.content()}"/></div></c:when>
                                        <c:when test="${p.mediaType() == 'VIDEO'}">
                                            <video src="${ctx}/download?name=${p.mediaUrl()}#t=0.1" muted preload="metadata" playsinline></video>
                                            <i class="fa-solid fa-film ex-badge"></i>
                                        </c:when>
                                        <c:otherwise><img src="${ctx}/download?name=${p.mediaUrl()}" alt="" loading="lazy"></c:otherwise>
                                    </c:choose>
                                    <div class="ex-overlay">
                                        <span><i class="fa-solid fa-heart"></i> ${p.likeCount()}</span>
                                        <span><i class="fa-solid fa-comment"></i> ${p.commentCount()}</span>
                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>
<jsp:include page="/fragments/scripts.jsp"/>
</body>
</html>
