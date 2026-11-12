<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />

<aside class="dashboard-sidebar" id="mgSidebar">

    <div class="sb-top">
        <!-- Logo: milliy do'ppi + MilliyGram -->
        <a href="${ctx}/" class="brand-logo-area">
            <span class="logo-mark"><jsp:include page="/fragments/icons.jsp"/></span>
            <span class="brand-gradient">MilliyGram</span>
        </a>

        <!-- Foydalanuvchining haqiqiy ma'lumotlari: skript /api/user dan to'ldiradi -->
        <div class="sidebar-profile-box">
            <a href="${ctx}/user/profile" class="sidebar-avatar-link">
                <img src="${empty sessionScope.avatar ? defAvatar : ctx.concat('/download?name=').concat(sessionScope.avatar)}"
                     class="sidebar-avatar" alt="Profil">
                <h3 class="sidebar-name"><c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}"/></h3>
            </a>
            <div class="sidebar-handle">@<c:out value="${sessionScope.username}"/></div>
        </div>

        <!-- Statistika: Posts -> profil, Followers / Following -> shu panel ichida ro'yxat -->
        <div class="sidebar-stats">
            <a class="stat-item" href="${ctx}/user/profile" title="Postlarim">
                <span class="stat-num" data-stat="posts"><c:out value="${not empty realPostCount ? realPostCount : 0}"/></span>
                <span class="stat-label">Posts</span>
            </a>
            <button type="button" class="stat-item" data-stat-list="followers" title="Followers">
                <span class="stat-num" data-stat="followers"><c:out value="${not empty realFollowerCount ? realFollowerCount : 0}"/></span>
                <span class="stat-label">Followers</span>
            </button>
            <button type="button" class="stat-item" data-stat-list="following" title="Following">
                <span class="stat-num" data-stat="following"><c:out value="${not empty realFollowingCount ? realFollowingCount : 0}"/></span>
                <span class="stat-label">Following</span>
            </button>
        </div>

        <!-- Menyu -->
        <nav class="sidebar-nav" id="mgNav">
            <a href="${ctx}/" class="nav-link-item ${pageContext.request.requestURI.endsWith('home.jsp') ? 'active' : ''}">
                <i class="fa-solid fa-house"></i> Feed
            </a>
            <a href="${ctx}/explore" class="nav-link-item ${pageContext.request.requestURI.contains('explore') ? 'active' : ''}">
                <i class="fa-regular fa-compass"></i> Explore
            </a>
            <a href="${ctx}/saved/posts" class="nav-link-item ${pageContext.request.requestURI.contains('saved') ? 'active' : ''}">
                <i class="fa-regular fa-bookmark"></i> Saved
            </a>
            <a href="${ctx}/user/profile" id="mgNavProfile" class="nav-link-item ${pageContext.request.requestURI.contains('profile') ? 'active' : ''}">
                <i class="fa-regular fa-user"></i> Profile
            </a>
        </nav>
    </div>

    <!-- Quyi qism: Logout o'rniga Settings -->
    <div class="sb-bottom">
        <button type="button" class="settings-btn" id="settingsBtn" aria-haspopup="true" aria-expanded="false">
            <i class="fa-solid fa-gear"></i> Settings
        </button>
    </div>

    <!-- Settings paneli (pastdan tepaga ochiladi, faqat shu panel ichida) -->
    <div class="settings-pop" id="settingsPop" role="menu">
        <button type="button" class="sp-item" id="spTheme">
            <i class="fa-solid fa-moon" id="spThemeIcon"></i>
            <span id="spThemeLabel">Qorong'u rejim</span>
            <span class="sp-switch"></span>
        </button>
        <button type="button" class="sp-item" id="spWallpaper">
            <i class="fa-regular fa-image"></i> Fon rasmi <i class="fa-solid fa-chevron-right sp-chev"></i>
        </button>
        <button type="button" class="sp-item" id="spPassword">
            <i class="fa-solid fa-key"></i> Parolni o'zgartirish
        </button>
        <div class="sp-sep"></div>
        <form action="${ctx}/logout" method="post" style="margin:0;">
            <button type="submit" class="sp-item danger">
                <i class="fa-solid fa-arrow-right-from-bracket"></i> Log out
            </button>
        </form>
    </div>

    <!-- Followers / Following ro'yxati: yon panelning o'zida ochiladi -->
    <div class="sb-list-panel" id="sbListPanel" aria-hidden="true">
        <div class="sb-list-head">
            <button type="button" class="icon-btn" id="sbListBack" title="Orqaga"><i class="fa-solid fa-arrow-left"></i></button>
            <span id="sbListTitle">Following</span>
        </div>
        <div class="sb-list-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="sbListSearch" placeholder="Qidirish" autocomplete="off">
        </div>
        <div class="sb-list-body" id="sbListBody"></div>
    </div>
</aside>
