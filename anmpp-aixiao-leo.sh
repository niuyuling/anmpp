#!/system/bin/sh
#
#   ANMPP SERVE SHELL SCRITP.
#
#   Author: aixiao@aixiao.me.
#   Email: 1605227279@qq.com.
#
#   2015/09/24 write.
#   20170404 Last Review.
#

function function_init() {
PATH="/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin:${PATH}"
LD_LIBRARY_PATH="/data/data/xiaoqidun.anmpp/files/root/android.glibc/lib:/vendor/lib/:/system/lib"
export LD_LIBRARY_PATH
export PATH

box="/data/data/xiaoqidun.anmpp/files/exec/busybox"
busybox="/system/xbin/busybox"
toolbox="/system/bin/toolbox"
toybox="/system/bin/toybox"
null="/dev/null"
sh="/system/bin/sh"

anmpp_main=/data/data/xiaoqidun.anmpp/files/root

glibc=${anmpp_main}/android.glibc

bftpd_home=${anmpp_main}/android.bftpd
bftpd=${bftpd_home}/sbin/bftpd
bftpd_conf=${bftpd_home}/etc/bftpd.conf

nginx_home=${anmpp_main}/android.nginx
nginx=${nginx_home}/sbin/nginx
nginx_conf=${nginx_home}/conf/nginx.conf
nginx_pid=${nginx_home}/logs/nginx.pid

php_fpm_home=${anmpp_main}/android.php-fpm
php_fpm=${php_fpm_home}/bin/php-fpm
php_fpm_conf=${php_fpm_home}/etc/php-fpm.conf
php_fpm_conf_ini=${php_fpm_home}/etc/php-fpm.ini
php_fpm_pid=${php_fpm_home}/tmp/php-fpm.pid

mysql_home=${anmpp_main}/android.mysql
mysql=${mysql_home}/bin/mysql
mysqld=${mysql_home}/bin/mysqld
mysql_conf=${mysql_home}/etc/my.cnf
mysql_pid=${mysql_home}/data/localhost.pid

pgsql_home=${anmpp_main}/android.pgsql
pgsql_bin=${pgsql_home}/bin/postgres
pgsql_pid=${pgsql_home}/data/postmaster.pid
}

function function_busybox_bin(){
    if ${busybox} > ${null} 2>&1 ; then busybox=${busybox} ; else if ${box} > ${null} 2>&1 ; then busybox=${box} ; else echo "Can Not Find Busybox" ; exit 1 ; fi ; fi
}

anmpp_setbbx() {
    if /data/data/xiaoqidun.anmpp/files/exec/busybox >> /dev/null 2>&1 ; then
        bbx=/data/data/xiaoqidun.anmpp/files/exec/busybox
    elif /system/bin/busybox >> /dev/null 2>&1 ; then
        bbx=/system/bin/busybox
    elif /system/xbin/busybox >> /dev/null 2>&1 ; then
        bbx=/system/xbin/busybox
    else
        echo "Can Not Find Busybox"
        exit 0
    fi
}

anmpp_exists() {
    if $busybox [ ! -e "/data/data/xiaoqidun.anmpp/files/root/android.glibc/lib/libc.so.6" ] || $bbx [ ! -e "/data/data/xiaoqidun.anmpp/files/root/android.glibc/etc/passwd" ] ; then
        $busybox echo "error : anmpp not installed"
        $busybox echo "error : anmpp can not find file"
        exit 0
    fi
}

function function_uid() {
    if ${busybox} [[ "`${busybox} id -u`" != "0" ]] ; then
        #${busybox} echo "ONLY RUN IS ROOT USER"
        ${busybox} echo "Only Run As Root User"
        exit 0 ; fi
}

function function_ipaddres()
{
    if ${busybox} [[ "`which netcfg`" != "" ]] ; then
        netcfg | ${busybox} grep 'UP' | ${busybox} awk '{print $3}' | ${busybox} cut -d '/' -f 1 | ${busybox} sed 's/^/YOURIPADDR /'
    else
       ${busybox} ifconfig | ${busybox} grep 'inet' | ${busybox} grep -v 'inet6' | ${busybox} awk '{print $2}' | ${busybox} cut -d ':' -f 2 | ${busybox} sed 's/^/YOURIPADDR /'
    fi
}

function function_status()
{
    if ${busybox} [[ "${2}" = "status" ]] ; then
    if ${busybox} [[ "${1}" = "bftpd" ]] ; then
        ${busybox} ps | ${busybox} grep "${bftpd} -d" | ${busybox} grep -v "${busybox} grep ${bftpd} -d" | ${busybox} awk '{print $4}' | ${busybox} cut -d '/' -f 9 ; fi
    if ${busybox} [[ "${1}" = "nginx" ]] ; then 
        ${busybox} ps | ${busybox} grep "${nginx}" | ${busybox} grep -v "${busybox} grep "${nginx}"" | ${busybox} awk '{print $7}' | ${busybox} cut -d '/' -f 9 ; fi 
    if ${busybox} [[ "${1}" = "php-fpm" ]] ; then
        ${toolbox} ps | ${busybox} grep 'php-fpm' | ${busybox} awk 'NR==1 {print $9}' | ${busybox} cut -d ':' -f 1 ; fi
    if ${busybox} [[ "${1}" = "mysqld" ]] ; then
        ${busybox} ps | ${busybox} grep "${mysqld} --defaults-file=${mysql_conf} --user=root" | ${busybox} grep -v "${busybox} grep ${mysqld} --defaults-file=${mysql_conf} --user=root" | ${busybox} awk '{print $4}' | ${busybox} cut -d '/' -f 9 ; fi
    if ${busybox} [[ "${1}" = "postgres" ]] ; then
        ${busybox} ps | ${busybox} grep "${pgsql_bin} -D ${PGDATA}" | ${busybox} grep -v "${busybox} grep ${pgsql_bin} -D ${PGDATA}" | ${busybox} awk 'NR==1 {print $4}' | ${busybox} cut -d '/' -f 9 ; fi
    if ${busybox} [[ "${1}" = "ngrok" ]] ; then
        ${busybox} ps | ${busybox} grep "ngrokc" | ${busybox} awk 'NR==1 {print $4}' | ${busybox} cut -d '/' -f 6 ; fi ; fi
}

function anmpp_pid() {
if test "${2}" = "pid" ; then
if test "${1}" = "bftpd" ; then
${busybox} ps | ${busybox} grep "${bftpd} -d" | ${busybox} grep -v "${busybox} grep ${bftpd} -d" | ${busybox} awk '{print $1}' ; fi
if test "${1}" = "nginx" ; then
${busybox} ps | ${busybox} grep "${nginx}" | ${busybox} grep -v "${busybox} grep "${nginx}"" | ${busybox} awk '{print $1}' || if test -e ${nginx_pid} ; then cat ${nginx_pid} ; fi ; fi
if test "${1}" = "mysql" ; then
${busybox} ps | ${busybox} grep "${mysqld} --defaults-file=${mysql_conf} --user=root" | ${busybox} grep -v "${busybox} grep ${mysqld} --defaults-file=${mysql_conf} --user=root" | ${busybox} awk '{print $1}' || if test -e ${mysql_pid} ; then cat ${mysql_pid} ; fi ; fi
if test "${1}" = "pgsql" ; then
${busybox} ps | ${busybox} grep "${pgsql_bin} -D ${PGDATA}" | ${busybox} grep -v "${busybox} grep ${pgsql_bin} -D ${PGDATA}" | ${busybox} awk 'NR==1 {print $1}' || if test -e ${pgsql_pid} ; then head -n1 ${pgsql_pid} ; fi ; fi
if test "${1}" = "php-fpm" ; then
${busybox} ps | ${busybox} grep "php-fpm" | ${busybox} awk 'NR==1 {print $1}' || if test -e ${php_fpm_pid} ; then cat ${php_fpm_pid} ; fi ; fi ; fi
}

function function_help()
{
${busybox} echo "${0} [service] stop   : stop server"
${busybox} echo "${0} [service] start  : start server"
${busybox} echo "${0} [service] reload : reload server"
${busybox} echo "${0} [service] status : status server"
${busybox} echo "${0} [service] start|stop|reload|status"
}

#function function_mount() {
#    ${busybox} mount -o bind /dev ${pgsql_home}/dev &> $null &
#    ${busybox} mount -o bind /proc ${pgsql_home}/proc &> $null &
#}

#function function_umount() {
#    ${busybox} umount -f ${pgsql_home}/dev &> $null &
#    ${busybox} umount -f ${pgsql_home}/proc &> $null &
#    if ${busybox} [[ "`${toolbox} mount | ${busybox} grep '/data/data/.*'`" != "" ]] ; then
#        parts=$(${busybox} cat /proc/mounts | ${busybox} awk '{print $2}' | ${busybox} grep '^/data/data/.*')
#        for p in ${parts} ; do
#            ${busybox} umount ${parts} &> ${null}
#        done
#    fi
#    exit 0
#}

function_init
function_busybox_bin
anmpp_exists

while getopts t LM
do
    case ${LM} in
        t)
            LOG="1"
            ;;
    esac
done
shift $((OPTIND-1))
${busybox} [ "${LOG}" = "1" ] && set -x

if ${busybox} [[ ${#} -le 6 ]] ; then
if ${busybox} [[ ${#} -le 1 ]] ; then
if ${busybox} [[ "$1" = "start" ]] || ${busybox} [[ "$1" = "stop" ]] || ${busybox} [[ "$1" = "reload" ]] || ${busybox} [[ "$1" = "status" ]] || ${busybox} [[ "$1" = "my-sql" ]] || ${busybox} [[ "$1" = "pg-sql" ]] || ${busybox} [[ "$1" = "version" ]] || ${busybox} [[ "$1" = "shell" ]] || ${busybox} [[ "$1" = "" ]] ; then
case "$1" in
    start)
        function_uid
        if ${busybox} [[ -d ${bftpd_home} ]] ; then
            ${bftpd} -d &> ${null}
        fi
        if ${busybox} [[ -d ${nginx_home} ]] ; then
            ${nginx} &> ${null} &
        fi
        if ${busybox} [[ -d ${mysql_home} ]] ; then
            ${mysqld} --defaults-file=${mysql_conf} --user=root &> ${null} &
        fi
        if ${busybox} [[ -d ${php_fpm_home} ]] ; then
            ${php_fpm} -R -p ${php_fpm_home} -c ${php_fpm_conf_ini} &> ${null} &
        fi
        if ${busybox} [[ -d ${pgsql_home} ]] ; then
            #function_mount
            #${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/start" postgres &> ${null}
            pgsql_lib() {
            LD_LIBRARY_PATH=/data/data/xiaoqidun.anmpp/files/root/android.glibc/lib:/vendor/lib/:/system/lib
            PGLIB=${anmpp_main}/android.glibc/lib:${anmpp_main}/android.pgsql/lib
            PGDATA="${anmpp_main}/android.pgsql/data"
            export LD_LIBRARY_PATH="${LD_LIBRART_PARH}:${PGLIB}"
            export PGHOST="127.0.0.1"
            export PGPORT="5432"
            }
            pgsql_lib
            ${pgsql_bin} -D ${PGDATA} &> ${null} &
        fi
        ;;
    stop)
        function_uid
        if test -d ${bftpd_home} ; then
            ${busybox} kill -9 `anmpp_pid bftpd pid` &> ${null} &
            fi

        if test -d ${nginx_home} ; then
            ${nginx} -s stop &> ${null} &
        else
            ${busybox} kill -9 `anmpp_pid nginx pid` &> ${null} &
            fi

        if test -d ${php_fpm_home} ; then
            ${busybox} kill -QUIT `${busybox} cat ${php_fpm_pid} 2> ${null}` &> ${null} &
        else
            ${busybox} kill -9 `anmpp_pid php-fpm pid` &> ${null} &
            fi

        if test -d ${mysql_home} ; then
            ${busybox} kill -9 `${busybox} cat ${mysql_pid}` &> ${null} ; ${busybox} kill -9 `anmpp_pid mysql pid` &> ${null} &
        else
            ${busybox} kill -9 `anmpp_pid mysql pid` &> ${null} &
            fi

        if test -d ${pgsql_home} ; then
	        #${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/stop" postgres &> ${null}
            #function_umount
            ${busybox} kill -KILL `${busybox} head -n1 ${pgsql_pid}` &> ${null} &
            if ${busybox} [[ "`${busybox} ps | ${busybox} grep 'postgres'`" != "" ]] ; then
                ${busybox} kill -KILL `anmpp_pid pgsql pid` &> ${null} &
            fi
        fi
        ;;
    reload)
        function_uid
        eval ${0} stop
        eval ${0} start
        ;;
    status)
        if test -d ${bftpd_home} ; then
        ! test "$(anmpp_pid bftpd pid)" && pid=$(anmpp_pid bftpd pid)
        test -d "/proc/${pid}" && bf_proc=/proc/${pid} && if test "${bf_proc}" = "/proc/" ; then bf_proc="" ; fi
        if test "${bf_proc}" = "" && test "`${busybox} ps | ${busybox} grep "${bftpd} -d" | ${busybox} grep -v "${busybox} grep ${bftpd} -d"`" = "" ; then
            ${busybox} echo "BFTPD      NO RUNUING"
        else ${busybox} echo "BFTPD      RUNUING" ; fi ; fi
    
        if test -d ${nginx_home} ; then
        test -e ${nginx_pid} && pid=$(${busybox} cat ${nginx_pid})
        test -d "/proc/${pid}" && ng_prox=/proc/${pid} && if test "${ng_proc}" = "/proc/" ; then ng_proc="" ; fi
        if test "${ng_proc}" = "" && test "`${busybox} ps | ${busybox} grep ${nginx} | ${busybox} grep -v "${busybox} grep ${nginx}"`" = "" ; then
            ${busybox} echo "NGINX      NO RUNUING"
        else ${busybox} echo "NGINX      RUNUING" ; fi ; fi

        if test -d ${mysql_home} ; then
        test -e ${mysql_pid} && pid=$(${busybox} cat ${mysql_pid}) 
        test -d "/proc/${pid}" && my_proc=/proc/${pid} && if test "${my_proc}" = "/proc/" ; then my_proc="" ; fi
        if test "${my_proc}" = "" && test "`${busybox} ps | ${busybox} grep "${mysqld} --defaults-file=${mysql_conf} --user=root" | ${busybox} grep -v "${busybox} grep ${mysqld} --defaults-file=${mysql_conf} --user=root"`" = "" ; then
            ${busybox} echo "MYSQL      NO RUNUING"
        else ${busybox} echo "MYSQL      RUNUING" ; fi ; fi

        if test -d ${php_fpm_home} ; then
        test -e ${php_fpm_pid} && pid=$(${busybox} cat ${php_fpm_pid})
        test -d "/proc/${pid}" && php_proc="/proc/${pid}" && if test "${php_proc}" = "/proc/" ; then php_proc="" ; fi
        if test "${php_proc}" = "" && test "`${busybox} ps | ${busybox} grep "php-fpm" | ${busybox} grep -v "${busybox} grep "php-fpm""`" = "" ; then
            ${busybox} echo "PHP-FPM    NO RUNUING"
        else ${busybox} echo "PHP-FPM    RUNUING" ; fi ; fi

        if test -d ${pgsql_home} ; then
        test -e ${pgsql_pid} && pid=$(${busybox} head -n1 ${pgsql_pid})
        test -d "/proc/${pid}" && pg_proc=/proc/${pid}
        if test "${pd_proc}" = "" && test "$(${busybox} ps | ${busybox} grep "${pgsql_bin} -D ${PGDATA}" | ${busybox} grep -v "${busybox} grep ${pgsql_bin} -D ${PGDATA}")" = "" ; then
            ${busybox} echo "POSTGRESQL NO RUNUING"
        else ${busybox} echo "POATGRESQL RUNUING" ; fi ; fi
    
        function_ipaddres
        ;;
    my-sql)
        exit 1
        function_uid
        ${mysql} -h 127.0.0.1 -P 3306 -u root -p
        ;;
    pg-sql)
        exit 1
        function_uid
        : function_mount
        ${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/psql" postgres
        ;;
    version)
        ${busybox} echo "Anmpp Service Shell Script."
        ${busybox} echo "Anmpp Version 15 develop."
        ${busybox} echo "Anmpp Official Website : http://aite.xyz."
        ${busybox} echo "Anmpp Forum : http://webthen.net"
        ;;
    shell)
        exit 1
        export PATH=${bftpd_home}/sbin:${nginx_home}/sbin:${mysql_home}/bin:${php_fpm_home}/bin:${mysql_home}/bin:${pgsql_home}/bin:${PATH}
        export LD_LIBRARY_PATH=/vendor/lib/:/system/lib:{$LD_LIBRARY_PATH}
        PGLIB="/data/data/android.glibc/lib:/data/data/android.pgsql/lib"
        PGDATA="/data/data/android.pgsql/data"
        export LD_LIBRARY_PATH="${LD_LIBRART_PARH}:${PGLIB}"
        export PGHOST="127.0.0.1"
        export PGPORT="5432"
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
    ai="$@"
    xiaoai=$(${busybox} echo ${ai%% ${aixiao}})
fi 
    XIAOAI=($xiaoai)
for zhy in "${XIAOAI[@]}"
do
    if ${busybox} [[ "$zhy" = "bftpd" ]] ; then
        :
    elif ${busybox} [[ "$zhy" = "nginx" ]] ; then
        :
    elif ${busybox} [[ "$zhy" = "mysql" ]] ; then
        :
    elif ${busybox} [[ "$zhy" = "php-fpm" ]] ; then
        :
    elif ${busybox} [[ "$zhy" = "postgresql" ]] ; then
        :
    else
        echo $zhy            
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
                ${bftpd} -d &> ${null} &
                ;;
            stop)
                function_uid
                ${busybox} kill -9 `${toolbox} ps | ${busybox} grep 'bftpd' | ${busybox} awk '{print $2}'` &> ${null} || ${busybox} kill -9 `anmpp_pid bftpd pid` &> ${null}
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
                ${nginx} &> ${null}
                ;;
            stop)
                function_uid
                if ${busybox} [[ -e ${nginx_pid} ]] ; then
                    ${nginx} -s stop &
                else
                    ${busybox} kill -9 `anmpp_pid nginx pid` &> ${null}
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
                ${busybox} kill -9 `anmpp_pid mysql pid` &> ${null}
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
                ${php_fpm} -R -p ${php_fpm_home} -c ${php_fpm_conf_ini} &> ${null}
                ;;
            stop)
                function_uid
                ${busybox} kill `anmpp_pid php-fpm pid` &> ${null}
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
                    #function_mount
                    #${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/start" postgres &> ${null}
                    pgsql_lib() {
                    LD_LIBRARY_PATH=/data/data/xiaoqidun.anmpp/files/root/android.glibc/lib:/vendor/lib/:/system/lib
                    PGLIB=${anmpp_main}/android.glibc/lib:${anmpp_main}/android.pgsql/lib
                    PGDATA="${anmpp_main}/android.pgsql/data"
                    export LD_LIBRARY_PATH="${LD_LIBRART_PARH}:${PGLIB}"
                    export PGHOST="127.0.0.1"
                    export PGPORT="5432"
                    }
                    pgsql_lib
                    ${pgsql_bin} -D ${PGDATA} &> ${null} &
                fi
                ;;           
            stop)
                function_uid
                if ${busybox} [[ -d ${pgsql_home} ]] ; then
                    #${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/stop" postgres &> ${null}
                    #function_umount
                    if ${busybox} [[ -e ${pgsql_pid} ]] ; then 
                        pgsql_pid=$(${busybox} head -n1 ${pgsql_pid})
                        ${busybox} kill -KILL ${pgsql_pid} &> ${null}
                    fi
                    if test "`anmpp_pid pgsql pid`" ; then
                        ${busybox} kill -KILL `anmpp pgsql pid` &> ${null}
                    fi
                fi
                ;;
            reload)
                function_uid
                if ${busybox} [[ -d ${pgsql_home} ]] ; then
                    #function_mount
                    #${bbox} chroot ${pgsql_home} /bin/su -c "/init /etc/reload" postgres &> ${null}
                    eval ${0} postgresql stop
                    eval ${0} postgresql start
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
