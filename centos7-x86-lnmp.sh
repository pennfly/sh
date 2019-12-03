#!/bin/bash
yum install -y git
echo "https://webtatic.com/packages/php72/"
yum -y install epel-release
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install php72w-fpm php72w-cli php72w-opcache php72w-common php72w-pdo php72w-mbstring php72w-xml php72w-gd php72w-mysqlnd php72w-intl php72w-soap php-redis
systemctl start php-fpm
systemctl enable php-fpm
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
echo "|----------------------"
echo "|-"
echo "|-   PHP安装完成"
echo "|-"
echo "|----------------------"
echo "|----------------------——————————————————|"
echo "|----------------------"
echo "|-https://www.nginx.com/resources/wiki/start/topics/tutorials/install/"
echo "|----------------------"
cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
yum -y install nginx
systemctl start nginx
systemctl enable nginx
echo "|----------------------"
echo "|-"
echo "|-   Nginx安装完成"
echo "|-"
echo "|----------------------"
echo "|----------------------——————————————————|"
echo "|----------------------"
echo "|-http://downloads.mariadb.org/mariadb/repositories/"
echo "|----------------------"
uname -a
echo "|----------------------"
echo -n "U cpu is X86?:(y/n)"
read mysql
if [[ $mysql == "y" ]]; then
	cat > /etc/yum.repos.d/MariaDB.repo <<EOF
# MariaDB 10.3 CentOS repository list - created 2019-05-28 06:23 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
	yum -y install MariaDB-server MariaDB-client
	systemctl start mariadb
	systemctl enable mariadb
fi
echo "|----------------------"
echo "|-"
echo "|-   MariaDB安装完成"
echo "|-"
echo "|----------------------"
echo "|----------------------——————————————————|"
echo "|----------------------"
cat > /etc/nginx/example.conf <<EOF
server {
    listen 80;
    server_name example.com;
    root /example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \\.php\$ {
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\\.(?!well-known).* {
        deny all;
    }
}
EOF

vim /etc/php-fpm.d/www.conf
mysql_secure_installation
