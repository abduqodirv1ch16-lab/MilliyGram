#!/usr/bin/env bash
# MilliyGram — server xavfsizligini mustahkamlash va yangi versiyani joylash (Oracle Linux 9)
# Ishlatish:  sudo bash secure_server.sh
# Qayta-qayta ishga tushirish xavfsiz: har safar faqat kerakli o'zgarishlarni qiladi.
set -euo pipefail

TOMCAT_DIR="/opt/tomcat"
APP_USER="tomcat"
DB_NAME="mini_blog"
ENV_DIR="/etc/miniblog"
ENV_FILE="$ENV_DIR/db.env"
BACKUP_DIR="/var/backups/miniblog"
DEPLOY_USER="${DEPLOY_USER:-${SUDO_USER:-opc}}"
HOME_DIR="/home/$DEPLOY_USER"
SERVER_HOST="${SERVER_HOST:-$(curl -s --max-time 5 ifconfig.me || hostname -I | awk '{print $1}')}"
WAR_SHA="${WAR_SHA:-}"

[[ $EUID -eq 0 ]] || { echo "sudo bilan ishga tushiring: sudo bash $0"; exit 1; }
cd /tmp
step() { echo; echo ">>> $*"; }

# ---------------------------------------------------------------- 1. Yangi .war
step "1/9 Yangi versiyani tayyorlash"
if ls $HOME_DIR/mini_blog.war.part0* >/dev/null 2>&1; then
  cat $HOME_DIR/mini_blog.war.part0* > $HOME_DIR/mini_blog.war
  rm -f $HOME_DIR/mini_blog.war.part0*
  echo "Qismlar birlashtirildi"
fi
NEW_WAR=""
if [[ -f $HOME_DIR/mini_blog.war ]]; then
  if [[ -n "$WAR_SHA" ]] && ! echo "$WAR_SHA  $HOME_DIR/mini_blog.war" | sha256sum -c --quiet; then
    echo "!!! mini_blog.war buzilgan (sha256 mos emas). Qaytadan yuklang."; exit 1
  fi
  NEW_WAR="$HOME_DIR/mini_blog.war"
fi

# ---------------------------------------------------------------- 2. Baza paroli
step "2/9 Baza uchun yangi kuchli parol"
mkdir -p $ENV_DIR
if [[ ! -f $ENV_FILE ]]; then
  DB_PASS=$(openssl rand -hex 24)
  sudo -u postgres psql -q -c "ALTER USER postgres WITH PASSWORD '${DB_PASS}';"
  cat > $ENV_FILE <<EOF
DB_URL=jdbc:postgresql://127.0.0.1:5432/${DB_NAME}?currentSchema=public
DB_USER=postgres
DB_PASSWORD=${DB_PASS}
EOF
  echo "Yangi parol o'rnatildi va $ENV_FILE ga yozildi"
else
  echo "Parol avval o'rnatilgan — o'zgartirilmadi"
fi
# Admin panel: birinchi adminni yaratish uchun bir martalik maxfiy kalit
if ! grep -q '^ADMIN_SETUP_TOKEN=' $ENV_FILE; then
  echo "ADMIN_SETUP_TOKEN=$(openssl rand -hex 24)" >> $ENV_FILE
fi
chown root:$APP_USER $ENV_DIR $ENV_FILE
chmod 750 $ENV_DIR
chmod 640 $ENV_FILE
# PostgreSQL faqat server ichidan ulanishni qabul qilsin
PGCONF=/var/lib/pgsql/data/postgresql.conf
if ! grep -qE "^listen_addresses\s*=\s*'localhost'" $PGCONF; then
  echo "listen_addresses = 'localhost'" >> $PGCONF
fi
systemctl restart postgresql

# ---------------------------------------------------------------- 3. Tomcat
step "3/9 Tomcat'ni mustahkamlash"
mkdir -p /etc/systemd/system/tomcat.service.d
cat > /etc/systemd/system/tomcat.service.d/override.conf <<EOF
[Service]
EnvironmentFile=$ENV_FILE
UMask=0027
EOF
SRV=$TOMCAT_DIR/conf/server.xml
# Xato sahifalarida Tomcat versiyasi va ichki tafsilotlar ko'rinmasin
if ! grep -q 'ErrorReportValve' $SRV; then
  sed -i 's|</Host>|  <Valve className="org.apache.catalina.valves.ErrorReportValve" showReport="false" showServerInfo="false"/>\n      </Host>|' $SRV
fi
# Javob sarlavhasida "Server: Apache..." ko'rinmasin
grep -q 'server="MilliyGram"' $SRV || sed -i 's|<Connector port="8080"|<Connector port="8080" server="MilliyGram"|' $SRV
# Boshqaruv ilovalari (manager/docs/examples) bo'lmasin
rm -rf $TOMCAT_DIR/webapps/{docs,examples,manager,host-manager}
UPL=/home/$APP_USER/mini_blog_uploads
mkdir -p $UPL
chown -R $APP_USER:$APP_USER $TOMCAT_DIR /home/$APP_USER
chmod 750 /home/$APP_USER $UPL
chmod -R o-rwx $TOMCAT_DIR/conf

# ---------------------------------------------------------------- 4. Ilovani joylash
step "4/9 Ilovani joylash"
systemctl daemon-reload
if [[ -n "$NEW_WAR" ]]; then
  systemctl stop tomcat || true
  rm -rf $TOMCAT_DIR/webapps/ROOT $TOMCAT_DIR/webapps/ROOT.war
  cp "$NEW_WAR" $TOMCAT_DIR/webapps/ROOT.war
  chown $APP_USER:$APP_USER $TOMCAT_DIR/webapps/ROOT.war
  mkdir -p $HOME_DIR/old_wars && mv "$NEW_WAR" "$HOME_DIR/old_wars/mini_blog-$(date +%Y%m%d-%H%M).war"
  chown -R "$DEPLOY_USER:$DEPLOY_USER" "$HOME_DIR/old_wars"
  echo "Yangi versiya joylandi"
fi
systemctl restart tomcat

# ---------------------------------------------------------------- 5. Nginx
step "5/9 Nginx: xavfsizlik sarlavhalari va hujumlardan himoya"
cat > /etc/nginx/conf.d/miniblog.conf <<'EOF'
# Bir IP dan login/ro'yxatdan o'tishga juda ko'p urinishni cheklash (parol terib ko'rishdan himoya)
map $request_method $auth_limit_key { POST $binary_remote_addr; default ""; }
limit_req_zone $auth_limit_key     zone=auth:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;
limit_conn_zone $binary_remote_addr zone=perip:10m;

server {
    listen 80 default_server;
    server_name _;

    server_tokens off;
    client_max_body_size 60M;

    # Sahifalarni siqib yuborish — sekin internetda 3-5 barobar tez ochiladi
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 1024;
    gzip_vary on;
    gzip_proxied any;
    gzip_types text/plain text/css application/json application/javascript text/xml image/svg+xml;
    client_body_timeout 60s;
    client_header_timeout 15s;
    limit_conn perip 50;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), camera=(self), microphone=(self)" always;

    # yashirin fayllar (.git, .env ...) va JSP fragmentlarga to'g'ridan-to'g'ri kirish taqiqlanadi
    location ~ /\.            { deny all; return 404; }
    location ^~ /fragments/   { return 404; }
    location ^~ /WEB-INF/     { return 404; }
    location ^~ /META-INF/    { return 404; }

    # Admin panelga kirish: daqiqasiga 10 urinish (ilova ichida ham 5 xatodan keyin blok bor)
    location = /mgadmin/login {
        limit_req zone=auth burst=5 nodelay;
        limit_req_status 429;
        include /etc/nginx/miniblog_proxy.inc;
    }
    location = /mgadmin/setup {
        limit_req zone=auth burst=3 nodelay;
        limit_req_status 429;
        include /etc/nginx/miniblog_proxy.inc;
    }

    location ~ ^/(login|register)$ {
        limit_req zone=auth burst=5 nodelay;
        limit_req_status 429;
        include /etc/nginx/miniblog_proxy.inc;
    }

    location / {
        limit_req zone=general burst=60 nodelay;
        limit_req_status 429;
        include /etc/nginx/miniblog_proxy.inc;
    }
}
EOF
cat > /etc/nginx/miniblog_proxy.inc <<'EOF'
proxy_pass http://127.0.0.1:8080;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_hide_header Server;
proxy_hide_header X-Powered-By;
proxy_read_timeout 120s;
EOF
# nginx.conf dagi standart server blokini o'chiramiz ("conflicting server name" ogohlantirishi shundan edi)
if grep -q "^    server {" /etc/nginx/nginx.conf; then
  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
  python3 - <<'PY'
import re
p="/etc/nginx/nginx.conf"; s=open(p).read()
out=[]; i=0; lines=s.split("\n"); depth=0; skip=False
for ln in lines:
    if not skip and re.match(r"^    server \{", ln):
        skip=True; depth=0
    if skip:
        depth += ln.count("{") - ln.count("}")
        if depth<=0 and "}" in ln: skip=False
        continue
    out.append(ln)
open(p,"w").write("\n".join(out))
PY
fi
grep -q "server_tokens off" /etc/nginx/nginx.conf || sed -i 's|^\(\s*\)sendfile\(\s\+\)on;|\1sendfile\2on;\n\1server_tokens off;|' /etc/nginx/nginx.conf
nginx -t
systemctl reload nginx

# ---------------------------------------------------------------- 6. Firewall
step "6/9 Firewall: faqat 22, 80, 443 ochiq"
systemctl enable --now firewalld
for s in $(firewall-cmd --list-services); do
  case $s in ssh|http|https) ;; *) firewall-cmd --permanent --remove-service="$s" ;; esac
done
firewall-cmd --permanent --add-service=ssh --add-service=http --add-service=https
firewall-cmd --reload
firewall-cmd --list-services

# ---------------------------------------------------------------- 7. SSH
step "7/9 SSH: faqat kalit bilan kirish, root kira olmaydi"
cat > /etc/ssh/sshd_config.d/01-miniblog.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF
if sshd -t; then systemctl reload sshd; else echo "!!! SSH sozlamasida xato — o'zgarish qo'llanmadi"; rm -f /etc/ssh/sshd_config.d/01-miniblog.conf; fi

# fail2ban — SSH ga parol terib hujum qilganlarni bloklaydi
dnf install -y -q oracle-epel-release-el9 >/dev/null 2>&1 || true
if dnf install -y -q fail2ban fail2ban-firewalld >/dev/null 2>&1; then
  cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = true

[nginx-limit-req]
enabled  = true
port     = http,https
logpath  = /var/log/nginx/error.log
backend  = auto
maxretry = 10
EOF
  systemctl enable --now fail2ban
  systemctl restart fail2ban
  echo "fail2ban yoqildi"
else
  echo "fail2ban o'rnatilmadi (EPEL mavjud emas) — davom etamiz"
fi

# ---------------------------------------------------------------- 8. Avtomatik yangilanishlar
step "8/9 Xavfsizlik yangilanishlarini avtomatik o'rnatish"
dnf install -y -q dnf-automatic >/dev/null
sed -i 's/^upgrade_type.*/upgrade_type = security/; s/^apply_updates.*/apply_updates = yes/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

# ---------------------------------------------------------------- 9. Zaxira nusxa
step "9/9 Har kuni baza va rasmlarning zaxira nusxasi"
mkdir -p $BACKUP_DIR && chmod 700 $BACKUP_DIR
cat > /usr/local/bin/miniblog-backup.sh <<EOF
#!/usr/bin/env bash
set -e
D=\$(date +%Y%m%d-%H%M)
sudo -u postgres pg_dump -Fc $DB_NAME > $BACKUP_DIR/db-\$D.dump
tar czf $BACKUP_DIR/uploads-\$D.tar.gz -C /home/$APP_USER mini_blog_uploads
find $BACKUP_DIR -type f -mtime +7 -delete
EOF
chmod 700 /usr/local/bin/miniblog-backup.sh
cat > /etc/systemd/system/miniblog-backup.service <<'EOF'
[Unit]
Description=MilliyGram zaxira nusxasi
[Service]
Type=oneshot
ExecStart=/usr/local/bin/miniblog-backup.sh
EOF
cat > /etc/systemd/system/miniblog-backup.timer <<'EOF'
[Unit]
Description=MilliyGram zaxira nusxasi (har kuni 03:30)
[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now miniblog-backup.timer
/usr/local/bin/miniblog-backup.sh && echo "Birinchi zaxira nusxa olindi: $BACKUP_DIR"

# ---------------------------------------------------------------- Tekshiruv
echo
echo "Sayt ishga tushishini kutyapmiz..."
for i in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/login || true)
  [[ "$code" == "200" ]] && break
  sleep 2
done
echo
echo "=================================================="
if [[ "$code" == "200" ]]; then
  echo " Tayyor! Sayt ishlayapti:  http://${SERVER_HOST}"
else
  echo " Sayt javob bermadi (kod: $code). Log:"
  echo "   sudo tail -80 $TOMCAT_DIR/logs/catalina.out"
fi
echo " Zaxira nusxalar:  $BACKUP_DIR"
echo " Admin panel:      http://${SERVER_HOST}/mgadmin"
ADMINS=$(sudo -u postgres psql -tA -d $DB_NAME -c "select count(*) from admin_users" 2>/dev/null || echo 0)
if [[ "$ADMINS" == "0" ]]; then
  TOK=$(grep '^ADMIN_SETUP_TOKEN=' $ENV_FILE | cut -d= -f2)
  echo
  echo " Bosh adminni yaratish havolasi (faqat bir marta ishlaydi, hech kimga bermang):"
  echo "   http://${SERVER_HOST}/mgadmin/setup?token=$TOK"
fi
echo "=================================================="
