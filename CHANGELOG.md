# O‘zgarishlar tarixi

Har bir o‘zgarish fayl nomi bilan yozilgan, dasturchi qaysi joyga qarashni bilsin.

---

## 3-versiya: admin panel, yangi imkoniyatlar, tezlashtirish (2026-10-23)

### Admin panel (yangi)
- **Alohida admin akkauntlari:** `entity/AdminUser.java`, jadval `admin_users`. Ular sayt foydalanuvchilari (`auht_users`) bilan bog‘lanmagan.
- **2 bosqichli kirish** (parol + Google Authenticator / TOTP RFC 6238): `servlet/admin/AdminAuthServlet.java`, `service/AdminService.java`, `utils/Totp.java`. Bitta kodni qayta ishlatib bo‘lmaydi (`totp_last_step`).
- **Hujumdan himoya:**
  - 5 xato urinishda akkaunt 15 daqiqaga bloklanadi;
  - bir IP dan 15 daqiqada 10 ta xato urinishda IP bloklanadi (`security/LoginThrottle.java`);
  - login bor-yo‘qligini bilib bo‘lmaydi: xabar bir xil, javob vaqti tenglashtirilgan;
  - har bir xato javobga 0,4–0,8 soniya kechikish qo‘shiladi;
  - login formasida bir martalik token bor.
- **Panel himoyasi** (`security/AdminFilter.java`):
  - CSP nonce bilan, `X-Frame-Options: DENY`, `no-store`;
  - har bir POST da CSRF token va Origin tekshiriladi;
  - 30 daqiqa harakatsizlikda sessiya tugaydi;
  - User-Agent o‘zgarsa sessiya yopiladi.
- **Birinchi admin:** `/mgadmin/setup?token=` orqali yaratiladi. Buning uchun `ADMIN_SETUP_TOKEN` muhit o‘zgaruvchisi kerak. Admin yaratilgach, havola 404 qaytaradi.
- **Bo‘limlar** (`WEB-INF/admin/panel.jsp`, API: `servlet/admin/AdminApiServlet.java`, so‘rovlar: `dao/AdminDao.java`):
  - umumiy ko‘rinish: 30 kunlik grafik, ko‘rsatkichlar, yangi va eng mashhur akkauntlar;
  - foydalanuvchilar: qidiruv, filtr, bloklash, ✓ berish, butunlay o‘chirish (barcha ma’lumoti va fayllari bilan);
  - postlar va izohlar: ko‘rish va o‘chirish;
  - shikoyatlar: post bo‘yicha guruhlangan, «postni o‘chirish» yoki «rad etish»;
  - jurnal (`entity/AdminLog.java`, jadval `admin_logs`): har bir kirish urinishi va har bir amal IP, brauzer va sabab bilan yoziladi;
  - server holati: xotira, disk, baza hajmi, xato urinishlar;
  - adminlar (faqat bosh admin uchun): yangi admin qo‘shish (QR kod bilan), o‘chirish/yoqish;
  - parolni o‘zgartirish (2FA kodi bilan).
- **Shikoyat holati:** `Complaint` ga `status`, `resolved_by`, `resolved_at` ustunlari qo‘shildi.

### Sayt uchun yangiliklar
- **Tasdiqlangan belgi ✓:** `AuthUser.verified` ustuni. Belgi postlarda, profilda, izohlarda, qidiruvda va followers ro‘yxatida ko‘rinadi. Kod: `fragments/verified.jsp`, JS dagi `vBadge()`.
- **Bloklash ishlaydi:** bloklangan foydalanuvchi darhol tizimdan chiqariladi va qayta kira olmaydi (`security/UserFlags.java`, `MyWebFilter`, `LoginServlet`). Uning postlari lenta, Explore va qidiruvdan yashiriladi, profili 404 qaytaradi.
- **Explore sahifasi** (`/explore`, `servlet/user/ExploreServlet.java`, `user/explore.jsp`):
  - trenddagi postlar: like×3 + izoh×4 + ko‘rish/20;
  - 30 kunlik ommabop hashtaglar (5 daqiqa keshlanadi);
  - ko‘p kuzatiladigan akkauntlar va «Kuzatish» tugmasi;
  - `?tag=` bilan hashtag bo‘yicha filtr.
- **Hashtaglar bosiladigan bo‘ldi:** post matnidagi `#so‘z` Explore'ga havola bo‘ladi (`linkifyTags()` in `scripts.jsp`). Xavfsizlik uchun faqat `textContent` ishlatiladi.
- **Explore** chap menyuga qo‘shildi (`fragments/navbar.jsp`).

### Tezlashtirish
- **N+1 so‘rov muammosi hal qilindi.** Avval har bir post uchun 6 ta, har bir izoh uchun 4 ta alohida so‘rov ketardi. Endi butun sahifa uchun 6 ta guruhli so‘rov ishlatiladi: `dao/FeedDao.java`, `PostService.mapMany()`, `CommentService.mapMany()`.
- **Lenta sahifalab yuklanadi:** 20 tadan, «Oldingi postlarni ko‘rsatish» tugmasi bilan (`HomeServlet`, `?before=ID`).
- **«Saved» sahifasi** endi faqat saqlangan postlarni bazadan oladi. Avval butun lenta yuklanib, keyin ajratilardi.
- **Chap panel sonlari** COUNT so‘rovlari bilan olinadi. Avval barcha postlar yuklanib, `.size()` hisoblanardi (`servlet/SidebarStats.java`).
- **13 ta baza indeksi** ilova ishga tushganda yaratiladi (`dao/StartupDao.java`, `security/AppStartup.java`).
- **Nginx gzip** yoqildi (`deploy/secure_server.sh`).
- **Natija** (140 post, 62 foydalanuvchi bilan sinov): bosh sahifa 723 ms → 55 ms, Saved 242 ms → 59 ms. Bosh sahifadagi farqning bir qismi sahifalashdan, ya'ni endi bir sahifada 20 ta post.

### Boshqa
- Foydalanuvchi o‘z postini o‘chirganda uning izohlari, like va saqlashlari ham o‘chadi, media fayli diskdan o‘chiriladi. Avval bazada «yetim» yozuvlar qolardi.
- `/` dan boshqa noma'lum manzillar endi bosh sahifani emas, 404 ni qaytaradi.
- `pom.xml`:
  - `com.google.zxing:core:3.5.3` qo‘shildi (QR kod uchun);
  - Lombok `provided` qilindi, endi `.war` ga kirmaydi.

---

## 2-versiya: xavfsizlik tuzatishlari (2026-10-23)

| # | Muammo | Tuzatish | Fayl |
|---|---|---|---|
| 1 | Parollar ochiq matnda saqlanardi | PBKDF2-SHA256, eski parollar kirishda avtomatik shifrlanadi | `utils/PasswordUtils.java`, `service/AuthService.java` |
| 2 | `/download?name=../../etc/passwd` bilan istalgan fayl o‘qilardi | Faqat UUID nomli fayllar, yo‘l tekshiriladi | `utils/FileUtils.java`, `servlet/FileDownloadServlet.java` |
| 3 | `.html`/`.svg` yuklab, zararli kod ishlatish mumkin edi | Faqat rasm, video va audio; `nosniff` va `sandbox` sarlavhalari | `utils/FileUtils.java` |
| 4 | Ro‘yxatdan o‘tishda server tekshiruvi yo‘q edi | Username, ism va parol (6–100 belgi) tekshiriladi | `servlet/auth/RegisterServlet.java` |
| 5 | Session fixation | Kirishda `changeSessionId()` | `LoginServlet`, `RegisterServlet` |
| 6 | CSRF | Cookie `SameSite=Lax`, `HttpOnly` | `WEB-INF/web.xml` |
| 7 | Xatoda stack trace ko‘rinardi | `error.jsp`, Tomcat `ErrorReportValve` | `webapp/error.jsp`, `deploy/secure_server.sh` |
| 8 | Baza paroli kodda ochiq yozilgan edi | Serverda muhit o‘zgaruvchilaridan olinadi | `dao/BaseDao.java` |
| 9 | Chat va qidiruvda JSON buzilardi | Barcha qiymatlar ekranlanadi | `utils/JsonUtils.java`, `ChatServlet`, `UserSearchServlet` |
| 10 | Profilni ochish obuna holatini o‘zgartirardi | Holat faqat o‘qiladi | `servlet/user/PostListServlet.java` |
| 11 | Matn uzunligi cheklanmagan edi | Post 200/5000, izoh 2000, chat 5000, shikoyat 1000 belgi | tegishli servletlar |
| 12 | `show_sql=true` | `false` | `persistence.xml` |

**Server tomonda** (`deploy/secure_server.sh`):
- bazaga tasodifiy kuchli parol;
- SSH faqat kalit bilan, root kira olmaydi;
- fail2ban;
- firewall: faqat 22, 80 va 443 portlar ochiq;
- Nginx rate-limit: login va ro‘yxatdan o‘tishga daqiqasiga 10 ta urinish;
- xavfsizlik yangilanishlari avtomatik o‘rnatiladi;
- har kuni zaxira nusxa olinadi.

---

## 1-versiya: serverga joylash (2026-10-23)

- Oracle Cloud serveriga (Oracle Linux 9) Java 21, Tomcat 11, PostgreSQL 13 va Nginx o‘rnatildi (`deploy/setup_server.sh`).
- Ilova `ROOT.war` sifatida joylandi, shuning uchun sayt `/` manzilida ochiladi.
- PostgreSQL 13 da parol `md5` usulida saqlangani sababli `pg_hba.conf` ham `md5` ga o‘rnatildi.
