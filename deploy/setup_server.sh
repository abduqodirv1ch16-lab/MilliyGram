#!/usr/bin/env bash
# Mini Blog (Jakarta) — Oracle Cloud serverga o'rnatish skripti
# Ishlatish:  sudo bash setup_server.sh
# Ubuntu (22.04/24.04) va Oracle Linux (8/9) da ishlaydi.
set -euo pipefail

DB_NAME="mini_blog"
DB_USER="postgres"
DB_PASS="${DB_PASS:-$(openssl rand -hex 16)}"  # tashqaridan berilmasa, tasodifiy parol yaratiladi
APP_USER="tomcat"
TOMCAT_DIR="/opt/tomcat"

if [[ $EUID -ne 0 ]]; then echo "sudo bilan ishga tushiring: sudo bash $0"; exit 1; fi

if command -v apt-get >/dev/null; then OS=ubuntu; else OS=oracle; fi
echo ">>> OS: $OS"

# ---------- 1. Paketlar: Java 21, PostgreSQL, Nginx ----------
if [[ $OS == ubuntu ]]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y openjdk-21-jdk-headless postgresql nginx curl
else
  dnf install -y java-21-openjdk-headless postgresql-server nginx curl tar policycoreutils-python-utils
  if [[ ! -f /var/lib/pgsql/data/PG_VERSION ]]; then postgresql-setup --initdb; fi
  # parol bilan ulanishga ruxsat
  sed -i -E 's/^(host\s+all\s+all\s+127\.0\.0\.1\/32\s+)\S+/\1md5/' /var/lib/pgsql/data/pg_hba.conf
  sed -i -E 's/^(host\s+all\s+all\s+::1\/128\s+)\S+/\1md5/' /var/lib/pgsql/data/pg_hba.conf
fi
systemctl enable --now postgresql

# ---------- 2. Baza ----------
sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASS}';"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1 \
  || sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};"
systemctl restart postgresql

# ---------- 3. Tomcat 11 ----------
if [[ ! -d $TOMCAT_DIR ]]; then
  VER=$(curl -s https://dlcdn.apache.org/tomcat/tomcat-11/ | grep -oE 'v11\.[0-9]+\.[0-9]+' | sort -V | tail -1 | tr -d v)
  echo ">>> Tomcat $VER yuklanmoqda"
  curl -fL -o /tmp/tomcat.tgz "https://dlcdn.apache.org/tomcat/tomcat-11/v${VER}/bin/apache-tomcat-${VER}.tar.gz"
  mkdir -p $TOMCAT_DIR
  tar xzf /tmp/tomcat.tgz -C $TOMCAT_DIR --strip-components=1
  rm -rf $TOMCAT_DIR/webapps/*          # standart ilovalarni o'chiramiz
fi
id $APP_USER &>/dev/null || useradd -r -m -d /home/$APP_USER -s /bin/false $APP_USER
mkdir -p /home/$APP_USER/mini_blog_uploads   # rasm/videolar shu yerga saqlanadi
chown -R $APP_USER:$APP_USER $TOMCAT_DIR /home/$APP_USER

# Tomcat faqat ichkaridan (127.0.0.1:8080) eshitsin, tashqariga Nginx chiqaradi
sed -i 's|<Connector port="8080" protocol="HTTP/1.1"|<Connector port="8080" address="127.0.0.1" protocol="HTTP/1.1" maxPostSize="62914560"|' \
  $TOMCAT_DIR/conf/server.xml || true

JAVA_HOME_DIR=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat (Mini Blog)
After=network.target postgresql.service

[Service]
Type=forking
User=$APP_USER
Group=$APP_USER
Environment=JAVA_HOME=$JAVA_HOME_DIR
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR
Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment="CATALINA_OPTS=-Xms512m -Xmx4g -Dfile.encoding=UTF-8"
ExecStart=$TOMCAT_DIR/bin/startup.sh
ExecStop=$TOMCAT_DIR/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable tomcat

# ---------- 4. Ilovani joylash (ROOT.war -> sayt "/" manzilda ochiladi) ----------
WAR=$(ls -1 ~/*.war /home/*/*.war 2>/dev/null | grep -v "^$TOMCAT_DIR" | head -1 || true)
if [[ -n "${WAR:-}" ]]; then
  echo ">>> $WAR joylanmoqda"
  systemctl stop tomcat || true
  rm -rf $TOMCAT_DIR/webapps/ROOT $TOMCAT_DIR/webapps/ROOT.war
  cp "$WAR" $TOMCAT_DIR/webapps/ROOT.war
  chown $APP_USER:$APP_USER $TOMCAT_DIR/webapps/ROOT.war
else
  echo "!!! .war fayl topilmadi — keyin uni ~/ ga yuklab, skriptni qayta ishga tushiring"
fi
systemctl restart tomcat

# ---------- 5. Nginx (80-port -> Tomcat) ----------
NGX_CONF=/etc/nginx/conf.d/miniblog.conf
cat > $NGX_CONF <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    client_max_body_size 60M;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
}
EOF
rm -f /etc/nginx/sites-enabled/default
if [[ $OS == oracle ]]; then
  sed -i 's/listen       80 default_server;/listen 80;/; s/listen       \[::\]:80 default_server;/listen [::]:80;/' /etc/nginx/nginx.conf || true
  setsebool -P httpd_can_network_connect 1 || true
fi
nginx -t
systemctl enable --now nginx
systemctl reload nginx

# ---------- 6. Server ichki firewall'ida 80/443 portni ochish ----------
if [[ $OS == ubuntu ]]; then
  for P in 80 443; do
    iptables -C INPUT -p tcp --dport $P -j ACCEPT 2>/dev/null || iptables -I INPUT 1 -p tcp -m state --state NEW --dport $P -j ACCEPT
  done
  command -v netfilter-persistent >/dev/null && netfilter-persistent save || true
else
  firewall-cmd --permanent --add-service=http --add-service=https && firewall-cmd --reload || true
fi

IP=$(curl -s ifconfig.me || echo "SERVER_IP")
echo
echo "============================================"
echo " Tayyor!  Sayt manzili:  http://$IP"
echo " Loglar:  sudo tail -f $TOMCAT_DIR/logs/catalina.out"
echo "============================================"
