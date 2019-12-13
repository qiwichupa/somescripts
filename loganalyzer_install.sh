#!/bin/bash
# Syslog server with web interface for Debian 10
# LAMP + phpmyadmin + rsyslog + Log Analyzer

MYSQLROOTPASS="123"
PMAVER="4.9.2"
LAVERSION="4.1.7"

export LANG="en_US.UTF-8"

######### DEBCONF
if [[ "" == $(dpkg-query  -W --showformat='${Status}\n'  debconf-utils | grep "install ok") ]]; then
    apt -y install debconf-utils
fi

######### MARIA DB
if [[ "" == $(dpkg-query  -W --showformat='${Status}\n'  mysql-server mariadb-server | grep "install ok") ]]; then
    apt -y install mariadb-server
fi
mysql -uroot -e "UPDATE mysql.user SET Password=PASSWORD('${MYSQLROOTPASS}') WHERE User='root';\
    DELETE FROM mysql.user WHERE User='';\
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\
    DROP DATABASE test;\
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';\
    FLUSH PRIVILEGES;"



######### APACHE 
if [[ "" == $(dpkg-query -W --showformat='${Status}\n' apache2 | grep "install ok") ]]; then
    apt -y install apache2
fi


######### PHP
apt -y  install php libapache2-mod-php php-mysql php-common php-cli php-common php-json php-opcache php-readline php-mbstring


######### PHPMYADMIN
IFS='' read -r -d '' SITECONFIG  <<"EOF"
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF


wget https://files.phpmyadmin.net/phpMyAdmin/${PMAVER}/phpMyAdmin-${PMAVER}-all-languages.tar.gz
tar -xvf phpMyAdmin-${PMAVER}-all-languages.tar.gz
rm phpMyAdmin*.gz
mv phpMyAdmin-* /usr/share/phpmyadmin
mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
mkdir /etc/phpmyadmin/
cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
ln -s /usr/share/phpmyadmin/config.inc.php /etc/phpmyadmin/

echo "\$cfg['TempDir'] ='/var/lib/phpmyadmin/tmp';" >> /usr/share/phpmyadmin/config.inc.php
r="\$cfg\['blowfish_secret'\] = '"
sed -i  "s/${r}/${r}$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)/g" /usr/share/phpmyadmin/config.inc.php



echo "$SITECONFIG" >  /etc/apache2/sites-available/phpmyadmin.conf
ln -s /etc/apache2/sites-available/phpmyadmin.conf /etc/apache2/sites-enabled/
service  apache2 restart



######### SYSLOG
if [[ "" == $(dpkg-query  -W --showformat='${Status}\n'  rsyslog-mysql | grep "install ok") ]]; then
debconf-set-selections << 'END'
rsyslog-mysql	rsyslog-mysql/mysql/admin-pass	password
# MySQL application password for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/mysql/app-pass	password
rsyslog-mysql	rsyslog-mysql/password-confirm	password
rsyslog-mysql	rsyslog-mysql/app-password-confirm	password
# MySQL username for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/db/app-user	string	rsyslog@localhost
# Back up the database for rsyslog-mysql before upgrading?
rsyslog-mysql	rsyslog-mysql/upgrade-backup	boolean	true
# Host running the MySQL server for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/remote/newhost	string
# MySQL database name for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/db/dbname	string	Syslog
# Reinstall database for rsyslog-mysql?
rsyslog-mysql	rsyslog-mysql/dbconfig-reinstall	boolean	false
rsyslog-mysql	rsyslog-mysql/missing-db-package-error	select	abort
rsyslog-mysql	rsyslog-mysql/remote/port	string
# Perform upgrade on database for rsyslog-mysql with dbconfig-common?
rsyslog-mysql	rsyslog-mysql/dbconfig-upgrade	boolean	true
# Host name of the MySQL database server for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/remote/host	select	localhost
# Deconfigure database for rsyslog-mysql with dbconfig-common?
rsyslog-mysql	rsyslog-mysql/dbconfig-remove	boolean	true
# Database type to be used by rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/database-type	select	mysql
rsyslog-mysql	rsyslog-mysql/upgrade-error	select	abort
rsyslog-mysql	rsyslog-mysql/remove-error	select	abort
rsyslog-mysql	rsyslog-mysql/install-error	select	abort
rsyslog-mysql	rsyslog-mysql/passwords-do-not-match	error
rsyslog-mysql	rsyslog-mysql/internal/skip-preseed	boolean	false
# Delete the database for rsyslog-mysql?
rsyslog-mysql	rsyslog-mysql/purge	boolean	false
# Connection method for MySQL database of rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/mysql/method	select	Unix socket
rsyslog-mysql	rsyslog-mysql/mysql/admin-user	string	root
rsyslog-mysql	rsyslog-mysql/internal/reconfiguring	boolean	false
# Configure database for rsyslog-mysql with dbconfig-common?
rsyslog-mysql	rsyslog-mysql/dbconfig-install	boolean	true
END
DEBIAN_FRONTEND=noninteractive apt-get install -y rsyslog-mysql
fi

echo "module(load=\"imudp\")" > /etc/rsyslog.d/enable-remote.conf
echo "input(type=\"imudp\" port=\"514\")" >> /etc/rsyslog.d/enable-remote.conf 
echo "module(load=\"imtcp\")" >> /etc/rsyslog.d/enable-remote.conf
echo "input(type=\"imtcp\" port=\"514\")" >> /etc/rsyslog.d/enable-remote.conf 
service rsyslog restart



mysql -uroot -p${MYSQLROOTPASS} -e "CREATE DATABASE Syslog_template;"
mysqldump -uroot -p${MYSQLROOTPASS} Syslog > /tmp/sql.sql
mysql -uroot -p${MYSQLROOTPASS} Syslog_template < /tmp/sql.sql
mysql -uroot -p${MYSQLROOTPASS} -e "TRUNCATE TABLE Syslog_template.SystemEvents"

mysql -uroot -p${MYSQLROOTPASS} -e "use mysql; UPDATE user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"


######### LOG ANALYZER

wget http://download.adiscon.com/loganalyzer/loganalyzer-${LAVERSION}.tar.gz
tar -xvf loganalyzer-${LAVERSION}.tar.gz
rm loganalyzer-${LAVERSION}.tar.gz
cp -r loganalyzer-4.1.7/src/* /var/www/html/
rm /var/www/html/index.html
chown www-data:www-data -R /var/www/html/
