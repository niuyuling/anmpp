#!/system/bin/sh
#
#ANMPP SERVE SHELL SCRITP.
#20150924 AIXIAO write.
#20160222 AIXIAO modify.
#Email: 1605227279@qq.com
#

PATH=/system/bin:/system/xbin:${PATH}
LD_LIBRARY_PATH=/vendor/lib/:/system/lib/:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH
export PATH
bbox="/data/data/android.pgsql/bin/busybox"
toolbox="/system/bin/toolbox"
toybox="/system/bin/toybox"
busybox="/system/xbin/busybox"
null="/dev/null"
sh="/system/bin/sh"

if ! ${busybox} &> ${null} ; then if ! ${bbox} &> ${null} ; then echo "Busybox No Found" ; exit 1 ; else busybox=${bbox} ; fi ; fi
if ! ${toolbox} &> ${null} ; then echo "Toolbox No Found" ; fi
if ${busybox} [[ ! -e /system/lib/libc.so.6 ]] ; then echo "Gnulibc Not Installed" ; exit 1 ; fi

while getopts :t FLAG
do
    case "${FLAG}" in
        t)
            TRACE_MODE="y"
        ;;
    esac
done
shift $((OPTIND-1))
[ "${TRACE_MODE}" = "y" ] && set -x

function function_ipaddres()
{
    if netcfg &> ${null} ; then
        netcfg | ${busybox} grep 'UP' | ${busybox} awk '{print $3}' | ${busybox} cut -d '/' -f 1 | ${busybox} sed 's/^/YOURIPADDR /'
    else
       ${busybox} ifconfig | ${busybox} grep 'inet' | ${busybox} grep -v 'inet6' | ${busybox} awk '{print $2}' | ${busybox} cut -d ':' -f 2 | ${busybox} sed 's/^/YOURIPADDR /'
    fi
}

function function_uid()
{
    if ${busybox} [[ "`${busybox} id -u`" != "0" ]] ; then
        ${busybox} echo "ONLY RUN IS ROOT USER"
        exit ; fi
}

function function_status()
{
    if ${busybox} [[ "${2}" = "status" ]] ; then
    if ${busybox} [[ "${1}" = "bftpd" ]] ; then
        ${toolbox} ps | ${busybox} grep 'bftpd' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d '/' -f 6 ; fi
    if ${busybox} [[ "${1}" = "nginx" ]] ; then 
        ${toolbox} ps | ${busybox} grep 'nginx' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d ':' -f 1 ; fi 
    if ${busybox} [[ "${1}" = "php-fpm" ]] ; then
        ${toolbox} ps | ${busybox} grep 'php-fpm' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d ':' -f 1 ; fi
    if ${busybox} [[ "${1}" = "mysqld" ]] ; then
        ${toolbox} ps | ${busybox} grep 'mysqld' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d '/' -f 6 ; fi
    if ${busybox} [[ "${1}" = "postgres" ]] ; then
        ${toolbox} ps | ${busybox} grep 'postgres' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d '/' -f 4 ; fi ; fi
}

function function_help()
{
    ${busybox} echo "${0} [service] stop   : stop server"
    ${busybox} echo "${0} [service] start  : start server"
    ${busybox} echo "${0} [service] reload : reload server"
    ${busybox} echo "${0} [service] status : status server"
    ${busybox} echo "${0} [service] start|stop|reload|status"
}

function function_parameters()
{
bftpd_home="/data/data/android.bftpd"
bftpd="/data/data/android.bftpd/sbin/bftpd"
bftpd_conf="/data/data/android.bftpd/etc/bftpd.conf"

nginx_home="/data/data/android.nginx"
nginx="/data/data/android.nginx/sbin/nginx"
nginx_conf="/data/data/android.nginx/conf/nginx.conf"
nginx_pid="/data/data/android.nginx/logs/nginx.pid"

php_fpm_home="/data/data/android.php-fpm"
php_fpm="/data/data/android.php-fpm/bin/php-fpm"
php_fpm_conf="/data/data/android.php-fpm/etc/php-fpm.conf"
php_fpm_conf_ini="/data/data/android.php-fpm/etc/php-fpm.ini"
php_fpm_pid="/data/data/android.php-fpm/tmp/php-fpm.pid"

mysql_home="/data/data/android.mysql"
mysql="/data/data/android.mysql/bin/mysql"
mysqld="/data/data/android.mysql/bin/mysqld"
mysql_conf="/data/data/android.mysql/etc/my.cnf"
mysql_pid="/data/data/android.mysql/data/localhost.pid"

pgsql_home="/data/data/android.pgsql"
}

function function_mount()
{
    ${busybox} mount /dev ${pgsql_home}/dev &> $null &
    ${busybox} mount /proc ${pgsql_home}/proc &> $null &
}

function function_umount()
{
    ${busybox} umount -f ${pgsql_home}/dev &> $null &
    ${busybox} umount -f ${pgsql_home}/proc &> $null &
    if ${busybox} [[ "`${toolbox} mount | ${busybox} grep '/data/data/.*'`" != "" ]] ; then
        parts=$(${busybox} cat /proc/mounts | ${busybox} awk '{print $2}' | ${busybox} grep '^/data/data/.*')
        for p in ${parts} ; do
            ${busybox} umount ${parts} &> ${null}
        done
    fi
    exit 0
}

function_parameters

if ${busybox} [[ ${#} -le 6 ]] ; then
if ${busybox} [[ ${#} -le 1 ]] ; then
if ${busybox} [[ "$1" = "start" ]] || ${busybox} [[ "$1" = "stop" ]] || ${busybox} [[ "$1" = "reload" ]] || ${busybox} [[ "$1" = "status" ]] || ${busybox} [[ "$1" = "my-sql" ]] || ${busybox} [[ "$1" = "pg-sql" ]] || ${busybox} [[ "$1" = "version" ]] || ${busybox} [[ "$1" = "shell" ]] || ${busybox} [[ "$1" = "" ]] ; then
case "$1" in
    start)
        function_uid
        if ${busybox} [[ -d ${bftpd_home} ]] ; then
            ${bftpd} -c ${bftpd_conf} -i -D -d &> ${null} &
        fi
        if ${busybox} [[ -d ${nginx_home} ]] ; then
            ${nginx} &> ${null} &
        fi
        if ${busybox} [[ -d ${mysql_home} ]] ; then
            ${mysqld} --defaults-file=${mysql_conf} --user=root &> ${null} &
        fi
        if ${busybox} [[ -d ${php_fpm_home} ]] ; then
            ${php_fpm} -R -p ${php_fpm_home} &> ${null} &
        fi
        if ${busybox} [[ -d ${pgsql_home} ]] ; then
            function_mount
            ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/start" postgres &> ${null}
        fi  
        ;;
    stop)
        function_uid
        if ${busybox} [[ -d ${bftpd_home} ]] ; then
            ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'bftpd' | ${busybox} awk '{print $2}'` &> ${null} &
        fi
        if ${busybox} [[ -e ${nginx_pid} ]] ; then
            ${nginx} -s stop &> ${null} &
        else
            ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'nginx' | ${busybox} awk '{print $2}'` &> ${null} & 
        fi
        if ${busybox} [[ -e ${php_fpm_pid} ]] ; then
            ${busybox} kill `${busybox} cat ${php_fpm_pid}` &> ${null} &
        else
            ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'php-fpm' | ${busybox} awk '{print $2}'` &> ${null} &
        fi
        if ${busybox} [[ -e ${mysql_pid} ]] ; then
            ${busybox} kill -9 `${busybox} cat ${mysql_pid}` &> ${null}
        else
            ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'mysqld' | ${busybox} awk '{print $2}'` &> ${null} &
        fi
        if ${busybox} [[ -d ${pgsql_home} ]] ; then
            ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/stop" postgres &> ${null}
            function_umount
        fi
        ;;
    reload)
        function_uid
        eval ${0} stop
        eval ${0} start
        ;;
    status)
        if ${busybox} [[ -d ${bftpd_home} ]] ; then
        if ${busybox} [[ "`${toolbox} ps | ${busybox} grep 'bftpd'`" = "" ]] ; then
            ${busybox} echo "BFTPD      NO RUNUING"
        else ${busybox} echo "BFTPD      RUNUING" ; fi ; fi
    
        if ${busybox} [[ -d ${nginx_home} ]] ; then
        if ${busybox}  [[ "`${toolbox} ps | ${busybox} grep 'nginx'`" = "" ]] ; then
            ${busybox} echo "NGINX      NO RUNUING"
        else ${busybox} echo "NGINX      RUNUING" ; fi ; fi

        if ${busybox} [[ -d ${mysql_home} ]] ; then
        if ${busybox} [[ "`${toolbox} ps | ${busybox} grep 'mysqld'`" = "" ]] ; then
            ${busybox} echo "MYSQL      NO RUNUING"
        else ${busybox} echo "MYSQL      RUNUING" ; fi ; fi

        if ${busybox} [[ -d ${php_fpm_home} ]] ; then
        if ${busybox} [[ "`${toolbox} ps | ${busybox} grep 'php-fpm'`" = "" ]] ; then
            ${busybox} echo "PHP-FPM    NO RUNUING"
        else ${busybox} echo "PHP-FPM    RUNUING" ; fi ; fi

        if ${busybox} [[ -d ${pgsql_home} ]] ; then 
        if ${busybox} [[ "`${toolbox} ps | ${busybox} grep 'postgres'`" = "" ]] ; then
            ${busybox} echo "POSTGRESQL NO RUNUING"
        else ${busybox} echo "POATGRESQL RUNUING" ; fi ; fi
    
        function_ipaddres
        ;;
    my-sql)
        function_uid
        ${mysql} -h 127.0.0.1 -P 3306 -u root -p
        ;;
    pg-sql)
        function_uid
        : function_mount
        ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/psql" postgres
        ;;
    version)
        ${busybox} echo "Anmpp Service Shell Script."
        ${busybox} echo "Anmpp Forun : http://webthen.net"
        ;;
    shell)
        export PATH=${bftpd_home}/sbin:${nginx_home}/sbin:${mysql_home}/bin:${php_fpm_home}/bin:${mysql_home}/bin:${pgsql_home}/pgsql/bin:${PATH}
        export LD_LIBRARY_PATH=/vendor/lib/:/system/lib/:{$LD_LIBRARY_PATH}
        ${sh}
        ;;
    *)
        function_help
        ;;
esac
else
    function_help
    exit 0
fi
fi
else
    function_help
    exit 0
fi


if ${busybox} [[ ${#} -le 6 ]] ; then
if ${busybox} [[ ${#} -ge 2 ]] ; then
    aixiao=$(${busybox} echo $(eval echo "\$$#"))
if ${busybox} [[ "$aixiao" = "start" ]] || ${busybox} [[ "$aixiao" = "stop" ]] || ${busybox} [[ "$aixiao" = "reload" ]] || ${busybox} [[ "$aixiao" = "status" ]] ; then
if ${busybox} [[ "$1" != "start" ]] || ${busybox} [[ "$1" != "stop" ]] || ${busybox} [[ "$1" != "reload" ]] || ${busybox}  [[ "$1" != "status" ]] ; then
    ai="$@"; xiaoai=$(${busybox} echo ${ai%% ${aixiao}})
fi 
XIAOAI=($xiaoai)
for zhy in "${XIAOAI[@]}"
do
    if ${busybox} [[ "$zhy" = "bftpd" ]] ; then :;
    elif ${busybox} [[ "$zhy" = "nginx" ]] ; then :;
    elif ${busybox} [[ "$zhy" = "mysql" ]] ; then :;
    elif ${busybox} [[ "$zhy" = "php-fpm" ]] ; then :;
    elif ${busybox} [[ "$zhy" = "postgresql" ]] ; then :;
    else
        function_help
        exit 0
    fi
done
for nyl in "${XIAOAI[@]}"
do
case "$nyl" in
    bftpd)
        case "$aixiao" in 
        start)
            function_uid
            ${bftpd} -c ${bftpd_conf} -i -D -d &> ${null} &
            ;;
        stop)
            function_uid
            ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'bftpd' | ${busybox} awk '{print $2}'` &> ${null} &
            ;;
        reload)
            function_uid
            eval ${0} bftpd stop
            eval ${0} bftpd start
            ;;
        status) 
            if $busybox [[ "`function_status bftpd status`" = "bftpd" ]] ; then
                ${busybox} echo "BFTPD      RUNUING"
            else ${busybox} echo "BFTPD      NO RUNUING" ; fi
            ;;
        esac
        ;;
    nginx)
        case "$aixiao" in
            start)
            function_uid
            ${nginx} &> ${null} &
            ;;
            stop)
                function_uid
                if ${busybox} [[ -e ${nginx_pid} ]] ; then
                    ${nginx} -s stop &
                else
                    ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'nginx' | ${busybox} awk '{print $2}'` &> ${null} &
                fi
                ;;
            reload)
                function_uid
                eval ${0} nginx stop
                eval ${0} nginx start
                ;;
            status)
                if ${busybox} [[ "`function_status nginx status`" = "nginx" ]] ; then
                    ${busybox} echo "NGINX      RUNUING"
                else ${busybox} echo "NGINX      NO RUNUING" ; fi
                ;;
            esac
            ;;
    mysql)
        case "${aixiao}" in
            start)
                function_uid
                ${mysqld} --defaults-file=${mysql_conf} --user=root &> ${null} &
                ;;
            stop)
                function_uid
                ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'mysqld' | ${busybox} awk '{print $2}'` &> ${null} &
                ;;
            reload)
                function_uid
                eval ${0} mysql stop
                eval ${0} mysql start
                ;;
            status)
                if ${busybox} [[ "`function_status mysqld status`" = "mysqld" ]] ; then
                    ${busybox} echo "MYSQL      RUNUING"
                else ${busybox} echo "MYSQL      NO RUNUING" ; fi
                ;;
            esac
            ;;
    php-fpm)
        case "${aixiao}" in
        start)
            function_uid
            ${php_fpm} -R -p ${php_fpm_home} &> ${null} &
            ;;
        stop)
            function_uid
            ${busybox} kill -9 `$toolbox ps | $busybox grep 'php-fpm' | $busybox awk '{print $2}'` &> ${null} &
            ;;
        reload)
            function_uid
            eval ${0} php-fpm stop
            eval ${0} php-fpm start
            ;;
        status)
            if ${busybox} [[ "`function_status php-fpm status`" = "php-fpm" ]] ; then
            ${busybox} echo "PHP-FPM    RUNUING" ; else
            ${busybox} echo "PHP-FPM    NO RUNUING" ;  fi
            ;;
        esac
        ;;
    postgresql)
        case "${aixiao}" in
        start)
            function_uid
            if ${busybox} [[ -d ${pgsql_home} ]] ; then
                function_mount
                ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/start" postgres &> ${null}
            fi
            ;;           
        stop)
            function_uid
            if ${busybox} [[ -d ${pgsql_home} ]] ; then
                ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/stop" postgres &> ${null}
                function_umount
            fi
            ;;
        reload)
            function_uid
            if ${busybox} [[ -d ${pgsql_home} ]] ; then
                function_mount
                ${busybox} chroot ${pgsql_home} /bin/su -c "/init /etc/reload" postgres &> ${null}
            fi
            ;;
        status)
            if ${busybox} [[ "`function_status postgres status`" = "postgres" ]] ; then
                ${busybox} echo "POSTGRESQL RUNUING"
            else ${busybox} echo "POSTGRESQL NO RUNUING" ; fi                    
            ;;
        esac
        ;;
esac 
done
else
    function_help
    exit 0
fi
fi
fi
