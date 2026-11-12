<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />
<c:set var="post" value="${card}" />
<%-- Bitta post kartasi. Chaqirishdan oldin: <c:set var="card" value="${post}" scope="request"/> --%>

<div class="feed-post-card js-post" id="post-${post.id()}"
     data-post-id="${post.id()}"
     data-author-id="${post.authorId()}"
     data-author="<c:out value='${post.authorUsername()}'/>"
     data-verified="${post.authorVerified()}"
     data-avatar="<c:out value='${post.authorAvatar()}'/>"
     data-content="<c:out value='${post.content()}'/>"
     data-media-url="<c:out value='${post.mediaUrl()}'/>"
     data-media-type="<c:out value='${post.mediaType()}'/>"
     data-likes="${post.likeCount()}"
     data-comments="${post.commentCount()}"
     data-liked="${post.isLikedByMe()}"
     data-saved="${post.isSavedByMe()}">

    <div class="feed-card-header">
        <a href="${ctx}/user/profile?id=${post.authorId()}">
            <img src="${not empty post.authorAvatar() ? ctx.concat('/download?name=').concat(post.authorAvatar()) : defAvatar}" class="feed-card-avatar" alt="Avatar">
        </a>
        <div>
            <a class="post-author-link" href="${ctx}/user/profile?id=${post.authorId()}" style="font-weight: 600; font-size: 13px; display: block;"><c:out value="${post.authorUsername()}"/><c:if test="${post.authorVerified()}"><jsp:include page="/fragments/verified.jsp"/></c:if></a>
            <div style="font-size: 11px; color: var(--text-muted);">Uzbekistan</div>
        </div>
        <button type="button" class="action-btn post-more" title="Ko‘proq" onclick="openPostMenu(${post.id()})"><i class="fa-solid fa-ellipsis"></i></button>
    </div>

    <c:if test="${not empty post.mediaUrl()}">
        <div class="feed-card-media" data-dbl-like>
            <c:choose>
                <c:when test="${post.mediaType() == 'VIDEO'}">
                    <video src="${ctx}/download?name=${post.mediaUrl()}#t=0.1" muted loop playsinline preload="metadata" data-autoplay></video>
                </c:when>
                <c:otherwise>
                    <img src="${ctx}/download?name=${post.mediaUrl()}" alt="Media" loading="lazy">
                </c:otherwise>
            </c:choose>
            <i class="fa-solid fa-heart heart-pop"></i>
        </div>
    </c:if>

    <div class="feed-card-actions">
        <div style="display: flex; gap: 14px;">
            <button type="button" class="action-btn js-like-btn ${post.isLikedByMe() ? 'liked' : ''}" data-post-id="${post.id()}" title="Like" onclick="toggleLike(${post.id()})"><i class="fa-${post.isLikedByMe() ? 'solid' : 'regular'} fa-heart"></i></button>
            <button type="button" class="action-btn" title="Izoh" onclick="openPostViewer(${post.id()}, true)"><i class="fa-regular fa-comment"></i></button>
            <button type="button" class="action-btn" title="Ulashish" onclick="sharePost(${post.id()})"><i class="fa-regular fa-paper-plane"></i></button>
        </div>
        <button type="button" class="action-btn js-save-btn" data-post-id="${post.id()}" title="Saqlash" onclick="toggleSave(${post.id()})"><i class="fa-${post.isSavedByMe() ? 'solid' : 'regular'} fa-bookmark"></i></button>
    </div>

    <div class="feed-card-info">
        <div class="js-like-count" data-post-id="${post.id()}" style="font-weight: 600; margin-bottom: 4px;">${post.likeCount()} ${post.likeCount() == 1 ? 'like' : 'likes'}</div>
        <div class="js-caption"><a class="post-author-link" href="${ctx}/user/profile?id=${post.authorId()}"><b><c:out value="${post.authorUsername()}"/></b></a> <c:out value="${post.content()}"/></div>
        <button type="button" class="comment-link js-comment-count" data-post-id="${post.id()}" onclick="openPostViewer(${post.id()}, true)">
            <c:choose>
                <c:when test="${post.commentCount() > 0}">View all ${post.commentCount()} comments</c:when>
                <c:otherwise>Add a comment</c:otherwise>
            </c:choose>
        </button>
    </div>
</div>
