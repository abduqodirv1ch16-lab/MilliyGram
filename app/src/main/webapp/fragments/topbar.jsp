<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%-- Yuqori panel: qidiruv, bildirishnomalar, chat, + POST. Hamma sahifada bir xil. --%>
<header class="top-header-bar">
  <div class="top-search-box">
    <i class="fa-solid fa-magnifying-glass"></i>
    <input type="text" placeholder="Search..." id="userSearchInput" autocomplete="off">
    <div id="userSearchDropdown" class="global-search-dropdown"></div>
  </div>

  <div class="top-actions-right">
    <a href="#" class="top-icon-btn js-bell" title="Notifications">
      <i class="fa-regular fa-bell"></i><span class="badge" style="display:none">0</span>
    </a>
    <a href="${ctx}/user/chat.jsp" class="top-icon-btn" title="Messages"><i class="fa-regular fa-comment-dots"></i></a>
    <a href="${ctx}/post/create" class="create-post-btn"><i class="fa-solid fa-plus"></i> POST</a>
  </div>
</header>
