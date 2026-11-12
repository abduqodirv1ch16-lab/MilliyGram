<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Saved</title>
    <jsp:include page="/fragments/head.jsp"/>
    <style>
        .saved-item { position: relative; }
        .saved-card-link { display:block; position:relative; aspect-ratio:1/1; background:#000; border-radius:16px; overflow:hidden; border:1px solid var(--border-color); transition:transform .2s, box-shadow .2s; text-decoration:none; cursor:pointer; }
        .saved-card-link:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,.18); }
        .saved-card-link img, .saved-card-link video { width:100%; height:100%; object-fit:cover; display:block; }
        .saved-text-only { width:100%; height:100%; display:flex; align-items:center; justify-content:center; padding:16px; text-align:center; color:#fff; font-weight:600; font-size:14px; background:linear-gradient(135deg,#6366f1,#d946ef); word-break:break-word; }
        .saved-video-badge { position:absolute; left:10px; top:10px; color:#fff; text-shadow:0 1px 4px rgba(0,0,0,.6); }
        .saved-overlay { position:absolute; inset:0; background:rgba(0,0,0,.42); display:flex; align-items:center; justify-content:center; opacity:0; transition:opacity .2s; color:#fff; font-size:16px; gap:22px; font-weight:700; }
        .saved-card-link:hover .saved-overlay { opacity:1; }
        .unsave-btn { position:absolute; top:10px; right:10px; background:rgba(0,0,0,.6); color:#fff; border:none; width:32px; height:32px; border-radius:50%; cursor:pointer; display:flex; align-items:center; justify-content:center; z-index:2; }
        .unsave-btn:hover { background:#FF3366; }
        .saved-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(210px,1fr)); gap:18px; }
    </style>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="/fragments/navbar.jsp"/>
    <main class="dashboard-content">
        <jsp:include page="/fragments/topbar.jsp"/>
        <div class="scrollable-main-area">
            <h3 class="page-title">Saved Posts</h3>
            <div id="savedEmpty" class="pf-empty" style="${empty savedPosts ? '' : 'display:none;'}">Hozircha saqlangan postlar yo‘q.</div>
            <div class="saved-grid" id="savedGrid">
                <c:forEach var="p" items="${savedPosts}">
                    <div class="saved-item js-post" data-remove-on-unsave
                         data-post-id="${p.id()}" data-author-id="${p.authorId()}"
                         data-author="<c:out value='${p.authorUsername()}'/>"
                         data-verified="${p.authorVerified()}"
                         data-avatar="<c:out value='${p.authorAvatar()}'/>"
                         data-content="<c:out value='${p.content()}'/>"
                         data-media-url="<c:out value='${p.mediaUrl()}'/>"
                         data-media-type="<c:out value='${p.mediaType()}'/>"
                         data-likes="${p.likeCount()}" data-comments="${p.commentCount()}"
                         data-views="0" data-created="" data-liked="${p.isLikedByMe()}" data-saved="true">
                        <button type="button" class="unsave-btn" title="Saqlanganlardan olib tashlash"
                                onclick="event.stopPropagation(); toggleSave(${p.id()});"><i class="fa-solid fa-bookmark"></i></button>
                        <a href="#post-${p.id()}" class="saved-card-link" onclick="openPostViewer(${p.id()}); return false;">
                            <c:choose>
                                <c:when test="${empty p.mediaUrl()}"><div class="saved-text-only"><c:out value="${p.content()}"/></div></c:when>
                                <c:when test="${p.mediaType() == 'VIDEO'}">
                                    <video src="${ctx}/download?name=${p.mediaUrl()}#t=0.1" muted preload="metadata" playsinline></video>
                                    <i class="fa-solid fa-film saved-video-badge"></i>
                                </c:when>
                                <c:otherwise><img src="${ctx}/download?name=${p.mediaUrl()}" alt="" loading="lazy"></c:otherwise>
                            </c:choose>
                            <div class="saved-overlay">
                                <span><i class="fa-solid fa-heart"></i> ${p.likeCount()}</span>
                                <span><i class="fa-solid fa-comment"></i> ${p.commentCount()}</span>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </main>
</div>
<jsp:include page="/fragments/scripts.jsp"/>
<script>
    window.onSavedRemoved = function () {
        var g = document.getElementById('savedGrid');
        if (g && g.children.length === 0) document.getElementById('savedEmpty').style.display = '';
    };
</script>
</body>
</html>
