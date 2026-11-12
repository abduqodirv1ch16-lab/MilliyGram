# MilliyGram

O‘zbek tilidagi ijtimoiy tarmoq: postlar (matn, rasm, video), izohlar, like, saqlash, obuna, hikoyalar (24 soat), shaxsiy chat, bildirishnomalar, Explore va to‘liq admin panel.

O‘zgarishlar tarixi bilan [`CHANGELOG.md`](CHANGELOG.md) faylida tanishishingiz mumkin.

## 1. Loyiha tuzilmasi

```
MilliyGram/
├── README.md                ← loyiha tuzilmasi, ishga tushirish va serverga joylash
├── CHANGELOG.md             ← versiyalar va o‘zgarishlar tarixi
├── .gitignore               ← Git kuzatmaydigan fayllar ro‘yxati
├── .env.example             ← muhit o‘zgaruvchilari namunasi
├── app/                     ← Maven loyihasi
│   ├── pom.xml
│   ├── mvnw, mvnw.cmd       ← Maven Wrapper skriptlari
│   └── src/main/
│       ├── java/uz/pdp/mini_blok_with_jakarta/   ← Java kodi
│       ├── resources/META-INF/persistence.xml    ← JPA / Hibernate sozlamalari
│       └── webapp/                               ← JSP sahifalar
└── deploy/
    ├── setup_server.sh      ← yangi serverga birinchi o‘rnatish (Java, Tomcat, PostgreSQL, Nginx)
    └── secure_server.sh     ← xavfsizlik + yangi versiyani joylash skripti
```

## 2. Texnologiyalar

| Qism | Texnologiya |
|---|---|
| Til | Java 17 (serverda Java 21 bilan ham mos) |
| Veb | Jakarta Servlet 6.1 + JSP + JSTL 3 |
| Server | Apache Tomcat 11 |
| Baza | PostgreSQL 13+ |
| ORM | Hibernate 7 (JPA 3.2), jadvallar `hbm2ddl=update` bilan avtomatik yaratiladi |
| Boshqa | Lombok (faqat kompilyatsiyada), ZXing (2FA QR kodi) |
| Frontend | Vanilla JavaScript, Font Awesome |
| Proksi | Nginx (`80/443` → Tomcat `127.0.0.1:8080`) |

## 3. Java kodi tuzilmasi

Paket: `uz.pdp.mini_blok_with_jakarta`. So‘rov yo‘li: **Filter → Servlet → Service → DAO → Entity**.

| Paket | Vazifasi | Muhim fayllar |
|---|---|---|
| `entity` | Baza jadvallari (JPA) | `AuthUser`, `Post`, `Comment`, `ChatMessage`, `Story`, `Follow`, `Complaint`, `AdminUser`, `AdminLog` |
| `dao` | Baza so‘rovlari | `BaseDao` — EntityManager, tranzaksiya va `.env` o‘quvchi; `FeedDao` — guruhli so‘rovlar; `AdminDao` — admin panel so‘rovlari; `StartupDao` — indekslar |
| `service` | Biznes-mantiq | `AuthService`, `PostService`, `CommentService`, `ChatService`, `AdminService` |
| `servlet` | URL manzillar | `auth/*`, `user/*`, `admin/*`, `HomeServlet`, `FileDownloadServlet` |
| `security` | Filtrlar va himoya | `MyWebFilter`, `AdminFilter`, `UserFlags`, `LoginThrottle`, `AppStartup` |
| `utils` | Yordamchilar | `PasswordUtils` (PBKDF2), `Totp` (RFC 6238 2FA), `FileUtils`, `Json`/`JsonUtils`, `QrUtils` |
| `dto`, `enums` | Ma’lumot uzatish obyektlari | `Role {USER, ADMIN}`, `Status {ACTIVE, BLOK}` |

## 4. URL xaritasi

**Sayt sahifalari:**

| URL | Servlet | Vazifa |
|---|---|---|
| `/` | `HomeServlet` | Lenta, 20 tadan, `?before=ID` bilan keyingi sahifa |
| `/explore`, `/explore?tag=sayohat` | `ExploreServlet` | Trendlar, hashtaglar, ommabop akkauntlar |
| `/login`, `/register`, `/logout` | `auth/*` | Kirish, ro‘yxatdan o‘tish, chiqish (POST) |
| `/user/profile?id=` | `ProfileServlet` | Foydalanuvchi profili |
| `/saved/posts` | `SavedPostsServlet` | Saqlangan postlar |
| `/post/create`, `/post/edit`, `/post/delete` | `user/Post*` | Post yaratish, tahrirlash, o‘chirish |
| `/post/like`, `/post/save`, `/post/report` | `user/*` | Like, saqlash, shikoyat (JSON) |
| `/comment`, `/comment/like` | `CommentServlet` | Izohlar va javoblar (JSON) |
| `/user/follow`, `/user/search` | `user/*` | Obuna, qidiruv (JSON) |
| `/chat/send`, `/chat/action` | `ChatServlet` | Chat tarixi, xabar yuborish, tahrir/o‘chirish |
| `/api/*` | `SocialApiServlet` | `/api/user`, `/api/me`, `/api/follows`, `/api/notifications`, `/api/stories`, `/api/password`, `/api/profile/edit`, `/api/story/*` |
| `/download?name=` | `FileDownloadServlet` | Yuklangan media fayllar (faqat UUID nomli) |

**Admin panel** (`AdminFilter` himoyasida):

| URL | Vazifa |
|---|---|
| `/mgadmin/login` | 2 bosqichli kirish: parol + Google Authenticator (TOTP) kodi |
| `/mgadmin/setup?token=` | Birinchi (bosh) adminni yaratish — faqat admin yo‘q bo‘lganda va to‘g‘ri token bilan |
| `/mgadmin` | Boshqaruv paneli (`WEB-INF/admin/panel.jsp`) |
| `/mgadmin/api/*` | Admin API (`X-CSRF-Token` sarlavhasi bilan himoyalangan) |

## 5. Kompyuterda (Local) ishga tushirish

1. PostgreSQL o‘rnating va ma’lumotlar bazasini yarating:
   ```sql
   CREATE DATABASE mini_blog;
   ```
2. Loyiha ildizidagi `.env.example` faylidan `.env` nusxa oling (`cp .env.example .env`) va o‘zingizning lokal PostgreSQL ma’lumotlaringizni yozing:
   ```env
   DB_URL=jdbc:postgresql://localhost:5432/mini_blog?currentSchema=public
   DB_USER=postgres
   DB_PASSWORD=sizning_lokal_parolingiz
   ADMIN_SETUP_TOKEN=local-setup-token-kamida-24-belgi-123456
   ```
   *(Yoki ushbu o‘zgaruvchilarni IntelliJ IDEA → Run/Debug Configurations → Tomcat Server → Environment variables qismida bering. `persistence.xml` ichiga haqiqiy parolni yozmang!)*
3. IntelliJ IDEA'da loyihani oching, `app/pom.xml` ustida o‘ng tugmani bosib **Add as Maven Project** (agar avtomatik tanimasa) tanlang va Tomcat 11 konfiguratsiyasini qo‘shing. **Application context** `/` bo‘lishi shart.
4. Ishga tushiring — jadvallar va indekslar avtomatik yaratiladi.
5. Birinchi adminni yaratish uchun `http://localhost:8080/mgadmin/setup?token=<ADMIN_SETUP_TOKEN>` manziliga kiring.

`.war` fayl yig‘ish:
```bash
cd app && ./mvnw clean package
```

## 6. Serverga (Production) joylash

Serverda barcha maxfiy ma’lumotlar `/etc/miniblog/db.env` faylida saqlanadi (faqat `root` va `tomcat` o‘qiy oladi):

| O‘zgaruvchi | Vazifa |
|---|---|
| `DB_URL`, `DB_USER`, `DB_PASSWORD` | Baza ulanishi (`BaseDao` orqali o‘qiladi) |
| `ADMIN_SETUP_TOKEN` | Bosh adminni yaratish havolasi uchun bir martalik maxfiy kalit |

**Yangi versiyani serverga chiqarish:**
```bash
cd app && ./mvnw clean package
scp -i <SSH_KEY_PATH> target/Mini_blok_with_Jakarta-1.0-SNAPSHOT.war <SSH_USER>@<SERVER_IP>:~/mini_blog.war
scp -i <SSH_KEY_PATH> ../deploy/secure_server.sh <SSH_USER>@<SERVER_IP>:~
ssh -i <SSH_KEY_PATH> <SSH_USER>@<SERVER_IP> "sudo bash ~/secure_server.sh"
```

## 7. Xavfsizlik qoidalari (kodga o‘zgartirish kiritishda)

- **Parollar** faqat `PasswordUtils.hash()` orqali saqlanadi (PBKDF2-SHA256, 120 000 iteratsiya).
- **Maxfiy kalitlar va parollar** hech qachon kod ichida (`persistence.xml`, `.java`, `.sh`) ochiq yozilmaydi — faqat `.env` yoki server muhit o‘zgaruvchilari orqali uzatiladi.
- **Fayl yuklash** faqat `FileUtils.uploadFile()` va `FileUtils.resolveSafe()` orqali amalga oshiriladi.
- **JSP'da foydalanuvchi matni** doim `<c:out>` bilan chiqariladi; JavaScript'da `textContent` ishlatiladi.
- **JSON** faqat `Json.of()` yoki `JsonUtils.q()` bilan hosil qilinadi.
- **Baza so‘rovlari** faqat parametrlar bilan (`:param`) yoziladi.
