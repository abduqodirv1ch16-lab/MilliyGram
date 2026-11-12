<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="defAvatar" value="data:image/svg+xml;utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'%3E%3Crect width='80' height='80' fill='%23E2E8F0'/%3E%3Ccircle cx='40' cy='30' r='14' fill='%2394A3B8'/%3E%3C/svg%3E" />
<!DOCTYPE html>
<html lang="uz">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MilliyGram — Yangi post</title>
    <jsp:include page="/fragments/head.jsp"/>
</head>
<body>
<div class="dashboard-container">
    <jsp:include page="/fragments/navbar.jsp"/>
    <main class="dashboard-content">
        <jsp:include page="/fragments/topbar.jsp"/>
        <div class="scrollable-main-area">
            <h3 class="page-title">Yangi post yaratish</h3>

            <form id="cpForm" class="cp-layout" action="${ctx}/post/create" method="post" enctype="multipart/form-data">
                <!-- Chap: rasm / video -->
                <div class="cp-drop" id="cpDrop">
                    <div class="cp-empty" id="cpEmpty">
                        <div class="cp-icon"><i class="fa-regular fa-images"></i></div>
                        <h4>Rasm yoki videoni shu yerga tashlang</h4>
                        <p>yoki qurilmangizdan tanlang (50 MB gacha)</p>
                        <button type="button" class="btn btn-primary" id="cpPick">Fayl tanlash</button>
                    </div>
                    <div class="cp-preview" id="cpPreview"></div>
                    <button type="button" class="cp-clear" id="cpClear" style="display:none" title="Olib tashlash"><i class="fa-solid fa-xmark"></i></button>
                    <input type="file" id="cpFile" name="media" accept="image/*,video/*" style="display:none">
                </div>

                <!-- O'ng: matn -->
                <div class="cp-form">
                    <div class="cp-user">
                        <img class="feed-card-avatar" alt="" src="${empty sessionScope.avatar ? defAvatar : ctx.concat('/download?name=').concat(sessionScope.avatar)}">
                        <span><c:out value="${sessionScope.username}"/></span>
                    </div>
                    <input type="hidden" name="title" id="cpTitle">
                    <div>
                        <textarea id="cpContent" name="content" class="form-control" rows="7" maxlength="2000" placeholder="Post matnini yozing..." required></textarea>
                        <div class="cp-count"><span id="cpCount">0</span> / 2000</div>
                    </div>
                    <div class="cp-emoji" id="cpEmoji"></div>
                    <div class="mg-error" id="cpError" style="display:none"></div>
                    <button type="submit" class="cp-submit" id="cpSubmit" disabled>Ulashish</button>
                </div>
            </form>
        </div>
    </main>
</div>
<jsp:include page="/fragments/scripts.jsp"/>
<script>
    (function () {
        var file = $id('cpFile'), drop = $id('cpDrop'), prev = $id('cpPreview'), empty = $id('cpEmpty');
        var txt = $id('cpContent'), sub = $id('cpSubmit'), err = $id('cpError');
        function fail(m) { err.textContent = m; err.style.display = m ? 'block' : 'none'; }
        function update() { $id('cpCount').textContent = txt.value.length; sub.disabled = !txt.value.trim(); }
        txt.addEventListener('input', update);
        '😀😂😍🔥👍🎉❤️😎✨🚀🙏😊'.match(/(\p{Extended_Pictographic}️?)/gu).forEach(function (e) {
            var b = el('button', null, e); b.type = 'button';
            b.onclick = function () { txt.value += e; txt.focus(); update(); };
            $id('cpEmoji').appendChild(b);
        });
        function clear() {
            file.value = ''; prev.innerHTML = ''; prev.classList.remove('on');
            empty.style.display = ''; $id('cpClear').style.display = 'none';
        }
        function setFile(f) {
            fail('');
            if (!f) return;
            if (f.type.indexOf('image/') !== 0 && f.type.indexOf('video/') !== 0) return fail('Faqat rasm yoki video tanlang');
            if (f.size > 50 * 1024 * 1024) return fail('Fayl juda katta (50 MB gacha)');
            if (!file.files.length || file.files[0] !== f) { var dt = new DataTransfer(); dt.items.add(f); file.files = dt.files; }
            var url = URL.createObjectURL(f);
            var n = document.createElement(f.type.indexOf('video/') === 0 ? 'video' : 'img');
            n.src = url;
            if (n.tagName === 'VIDEO') { n.controls = true; n.autoplay = true; n.muted = true; n.loop = true; n.playsInline = true; }
            prev.innerHTML = ''; prev.appendChild(n); prev.classList.add('on');
            empty.style.display = 'none'; $id('cpClear').style.display = '';
        }
        $id('cpPick').onclick = function () { file.click(); };
        file.addEventListener('change', function () { setFile(file.files[0]); });
        $id('cpClear').onclick = clear;
        ['dragenter', 'dragover'].forEach(function (ev) { drop.addEventListener(ev, function (e) { e.preventDefault(); drop.classList.add('drag'); }); });
        ['dragleave', 'drop'].forEach(function (ev) { drop.addEventListener(ev, function (e) { e.preventDefault(); drop.classList.remove('drag'); }); });
        drop.addEventListener('drop', function (e) { if (e.dataTransfer.files.length) setFile(e.dataTransfer.files[0]); });
        $id('cpForm').addEventListener('submit', function () {
            var t = txt.value.trim().split('\n')[0];
            $id('cpTitle').value = t.length > 60 ? t.substring(0, 60) : t;   // backend sarlavha talab qiladi
            sub.disabled = true; sub.textContent = 'Yuklanmoqda...';
        });
        update();
    })();
</script>
</body>
</html>
