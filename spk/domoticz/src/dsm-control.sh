#!/bin/sh

# Package
PACKAGE="domoticz"
DNAME="Domoticz"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PATH="${INSTALL_DIR}/bin:${PATH}"
USER="domoticz"
DOMOTICZ="${INSTALL_DIR}/bin/domoticz"
PID_FILE="${INSTALL_DIR}/var/domoticz.pid"
LOGFILE="${INSTALL_DIR}/var/domoticz.log"
DB_FILE="${INSTALL_DIR}/var/domoticz.db"
PORT="8084"

start_daemon ()
{
    insmod /lib/modules/usbserial.ko
    insmod /lib/modules/ftdi_sio.ko
    insmod ${INSTALL_DIR}/modules/cp210x.ko
    insmod ${INSTALL_DIR}/modules/pl2303.ko
    
    if [ `/bin/get_key_value /etc.defaults/VERSION buildnumber` -ge "5004" ]; then
        # DSM 5.1 supports UDEV rules. Create udev rules to set permissions to 666 
        # Doing this at package start so it gets done even after DSM upgrade.  
        cp ${INSTALL_DIR}/scripts/50-usbttyacm.rules /lib/udev/rules.d/50-usbttyacm.rules
    else
        # DSM 5.0 and earlier versions don't dynamically create devices, so create device for everything before build 5004.
        test -e /dev/ttyUSB0 || mknod /dev/ttyUSB0 c 188 0
        chmod 666 /dev/ttyUSB0
    fi
    
    su - ${USER} -c "${DOMOTICZ} -www ${PORT} -approot ${INSTALL_DIR}/ -dbase ${DB_FILE} &> $LOGFILE & echo \$! > ${PID_FILE}"
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20 || kill -9 `cat ${PID_FILE}`
    rm -f ${PID_FILE}
}

daemon_status ()
{
    if [ -f ${PID_FILE} ] && kill -0 `cat ${PID_FILE}` > /dev/null 2>&1; then
        return
    fi
    rm -f ${PID_FILE}
    return 1
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
            exit 0
        else
            echo Starting ${DNAME} ...
            start_daemon
            exit 0
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
            exit $?
        else
            echo ${DNAME} is not running
            exit 0
        fi
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo ${LOGFILE}
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
