#!/bin/bash
# Syslog server with web interface for Debian 10
# LAMP + phpmyadmin + rsyslog + Log Analyzer

PHPMYADMINUSER="pma"
PHPMYADMINPASS="321"
SYSLOGDBPASSWORD="Qwerty"
PMAVER="4.9.2"
LAVERSION="4.1.7"

export LANG="en_US.UTF-8"



function check_packages {
    notinstalled=""
    if [ $# -eq 0 ]; then echo "Package name(s) required"; fi
    if [ $# -gt 0 ]; then
        for packagename in $@; do
            if [[ "" == $(dpkg-query  -W --showformat='${Status}\n' ${packagename}  2>&1 | grep "install ok") ]]; then
                notinstalled=${notinstalled}${packagename}" "
            fi
        done
    fi
    if [[ "" == ${notinstalled} ]]; then
        echo "true"
    else
        echo "${notinstalled}"
    fi
}



######## MARIA DB
function check_sql {
    if [[ "true" != $( check_packages  mariadb-server ) && "true" != $( check_packages  mysql-server) ]]; then
        echo "false"
    fi
    if  [[ "true" == $( check_packages  mariadb-server ) ]]; then echo "mariadb"; fi
    if  [[ "true" == $( check_packages  mysql-server ) ]]; then echo "mysql"; fi
}

function install_sql {
    apt -y install mariadb-server
#    mysql -uroot -e "UPDATE mysql.user SET Password=PASSWORD('${MYSQLROOTPASS}') WHERE User='root';\
#    DELETE FROM mysql.user WHERE User='';\
#    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\
#    DROP DATABASE test;\
#    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';\
#    FLUSH PRIVILEGES;"
}




######### PHP
function check_php {
    phpnotinstalled=$( check_packages php libapache2-mod-php php-mysql php-common php-cli  php-json php-gd php-opcache php-readline php-mbstring )
    if [[ "true" != ${phpnotinstalled} ]]; then
        echo "${phpnotinstalled}"
    else
        echo "true"
    fi
}


######### PHPMYADMIN
function check_phpmyadmin {
    if [[ ! -d /usr/share/phpmyadmin/ ]]; then
        echo "false"
    fi
}

function install_phpmyadmin {
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


if [ ! -f phpMyAdmin-${PMAVER}-all-languages.tar.gz ]; then wget https://files.phpmyadmin.net/phpMyAdmin/${PMAVER}/phpMyAdmin-${PMAVER}-all-languages.tar.gz; fi
tar -xf phpMyAdmin-${PMAVER}-all-languages.tar.gz
mkdir /usr/share/phpmyadmin
cp -r phpMyAdmin-${PMAVER}-all-languages/* /usr/share/phpmyadmin
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
mysql -uroot -e "use mysql; CREATE USER ${PHPMYADMINUSER}@localhost IDENTIFIED BY '${PHPMYADMINPASS}'; GRANT ALL ON *.* TO ${PHPMYADMINUSER}@localhost WITH GRANT OPTION;"
service mysql restart

}


######### SYSLOG

function install_rsyslog_mysql {
debconf-set-selections << END
rsyslog-mysql	rsyslog-mysql/mysql/admin-pass	password
# MySQL application password for rsyslog-mysql:
rsyslog-mysql	rsyslog-mysql/mysql/app-pass	password ${SYSLOGDBPASSWORD}
rsyslog-mysql	rsyslog-mysql/password-confirm	password ${SYSLOGDBPASSWORD}
rsyslog-mysql	rsyslog-mysql/app-password-confirm	password ${SYSLOGDBPASSWORD}
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

echo "Creating /etc/rsyslog.d/enable-remote.conf"
echo "module(load=\"imudp\")" > /etc/rsyslog.d/enable-remote.conf
echo "input(type=\"imudp\" port=\"514\")" >> /etc/rsyslog.d/enable-remote.conf
echo "module(load=\"imtcp\")" >> /etc/rsyslog.d/enable-remote.conf
echo "input(type=\"imtcp\" port=\"514\")" >> /etc/rsyslog.d/enable-remote.conf
service rsyslog restart

echo "17 2     * * *     root mysql -uroot -e 'use Syslog; DELETE FROM SystemEvents WHERE ReceivedAt < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 365 DAY);'" > /etc/cron.d/rsyslog_mysql

#mysql -uroot -e "CREATE DATABASE Syslog_template;"
#mysqldump -uroot Syslog > /tmp/sql.sql
#mysql -uroot Syslog_template < /tmp/sql.sql
#mysql -uroot -e "TRUNCATE TABLE Syslog_template.SystemEvents"
}

######### LOG ANALYZER
function install_loganalyzer {
if [ ! -f loganalyzer-${LAVERSION}.tar.gz ]; then wget http://download.adiscon.com/loganalyzer/loganalyzer-${LAVERSION}.tar.gz; fi
tar -xf loganalyzer-${LAVERSION}.tar.gz
cp -r loganalyzer-${LAVERSION}/src/* /var/www/html/
rm -rf ./loganalyzer-${LAVERSION}/
rm /var/www/html/index.html
chown www-data:www-data -R /var/www/html/

#create new db for loganalyzer user and settings with rsyslog user as admin
mysql -uroot -e "create database loganalyzer; grant all privileges on loganalyzer.* to rsyslog@localhost"

#disable new version check during logon into admin panel
r="\$content\['UPDATEURL'\] = \"http://loganalyzer.adiscon.com/files/version.txt\";"
sed -i  "s|${r}|\$content\['UPDATEURL'\] = \"\";|g"  /var/www/html/include/functions_common.php
}


####
## MAIN
####
instaldebconf="false"
installmariadb="false"
installapache="false"
installphp="false"
instalphpmyadmin="false"
installrsyslog="false"


printf "Checking debconf-utils..."
check=$( check_packages debconf-utils )
if [[ $check != "true" ]]; then
    echo "......will be installed"
    instaldebconf="true"
else
    echo "......found!"
fi

printf "Checking sql..."
check=$( check_sql )
case ${check} in 
    false)
        echo "................will be installed: MariaDB"
        installmariadb="true"
        ;;
    mysql)
        echo "................MySQL found, it will be used during installation"
        ;;
    mariadb)
        echo "................MariaDB found, it will be used during installation"
        ;;
esac

printf "Checking apache..."
check=$( check_packages apache2 )
if [[ $check != "true" ]]; then
    echo ".............will be installed"
    installapache="true"
else
    echo ".............found!"
fi


printf "Checking php..."
check=$( check_php )
if [[ $check != "true" ]]; then
    echo "................will be installed: ${check}"
    installphp="true"
    phptoinstall=${check}
else
    echo "................found!"
fi

printf "Checking rsyslog-mysql..."
check=$( check_packages rsyslog-mysql )
if [[ $check != "true" ]]; then
    echo "......will be installed"
    installrsyslog="true"
else
    echo "......found!"
fi


printf "Checking phpmyadmin..."
check=$( check_phpmyadmin )
if [[ $check == "false" ]]; then
    echo ".........not found in /usr/share/phpmyadmin/"
    echo
    while true; do
        read -p "Do you wish to install phpmyadmin? (y/n): " yn
        case $yn in
            [Yy] ) instalphpmyadmin="true"; break;;
            [Nn] ) break;;
            * ) echo "Please answer [y]es or [n]o.";;
        esac
    done
else
    echo ".........found!"
fi


echo
echo "This file(s) should be downloaded:"
if [[ ${instalphpmyadmin} != "false" ]]; then echo "https://files.phpmyadmin.net/phpMyAdmin/${PMAVER}/phpMyAdmin-${PMAVER}-all-languages.tar.gz" ; fi
echo "http://download.adiscon.com/loganalyzer/loganalyzer-${LAVERSION}.tar.gz"
echo "You can place this file(s) into current directory manually if you have not an Internet connection."
echo "Debian repository must be accessible!"

echo
read -p "Ok, let's do it. Press ENTER to install, CTRL-C - to abort."



# INSTALL
apt update
if [[ ${instaldebconf} != "false" ]]; then apt -y install debconf-utils ; fi
if [[ ${installmariadb} != "false" ]]; then install_sql ; fi
if [[ ${installapache} != "false" ]]; then apt -y install apache2 ; fi
if [[ ${installphp} != "false" ]]; then  apt -y install ${phptoinstall} ; fi
if [[ ${installrsyslog} != "false" ]]; then  install_rsyslog_mysql  ; fi

installrsyslog
if [[ ${instalphpmyadmin} != "false" ]]; then install_phpmyadmin ; fi
install_loganalyzer

serverip=$(ip addr show | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -v "^127.0.0.1" | head -n 1)
echo
echo
echo Installation complete
echo
if [[ ${instalphpmyadmin} != "false" ]]; then 
    echo "phpmyadmin address: http://${serverip}/phpmyadmin"
    echo "             login:${PHPMYADMINUSER}"
    echo "          password:${PHPMYADMINPASS}"
    echo
fi
echo "Open IP address of this server in web-browser (http://${serverip}/)"
echo and use next settings for wizard:
echo
echo "User Database Options (optional)"
echo "Enable User Database: Yes"
echo "       Database User: rsyslog"
echo "   Database Password: ${SYSLOGDBPASSWORD}"
echo
echo "First Syslog Source"
echo "                        Source Type: MYSQL Native"
echo "     Database Name (case-sensitive): Syslog"
echo "Database Tablename (case-sensitive): SystemEvents"
echo "                      Database User: rsyslog"
echo "                  Database Password: ${SYSLOGDBPASSWORD}"
echo "                Enable Row Counting: Yes"

