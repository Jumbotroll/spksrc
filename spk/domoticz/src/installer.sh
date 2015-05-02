#!/bin/sh

# Package
PACKAGE="domoticz"
DNAME="Domoticz"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PATH="${INSTALL_DIR}/bin:${PATH}"
USER="domoticz"
GROUP="nobody"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"

SERVICETOOL="/usr/syno/bin/servicetool"
FWPORTS="/var/packages/${PACKAGE}/scripts/${PACKAGE}.sc"

preinst ()
{
    exit 0
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Install busybox stuff
    ${INSTALL_DIR}/bin/busybox --install ${INSTALL_DIR}/bin    

    # Create user
    adduser -h ${INSTALL_DIR}/var -g "${DNAME} User" -G ${GROUP} -s /bin/sh -S -D ${USER}

    # Correct the files ownership
    chown -R ${USER}:root ${SYNOPKG_PKGDEST}

    # Add firewall config
    ${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Remove the user (if not upgrading)
    if [ "${SYNOPKG_PKG_STATUS}" != "UPGRADE" ]; then
        delgroup ${USER} ${GROUP}
        deluser ${USER}
    fi

    # Remove firewall config
    if [ "${SYNOPKG_PKG_STATUS}" == "UNINSTALL" ]; then
        ${SERVICETOOL} --remove-configure-file --package ${PACKAGE}.sc >> /dev/null
    fi

    exit 0
}

postuninst ()
{
    # Remove link
    rm -f ${INSTALL_DIR}
    # remove rules for USB serial permission setting
    rm -f /lib/udev/rules.d/50-usbttyacm.rules
    exit 0
}

preupgrade ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # Save some stuff
    rm -fr ${TMP_DIR}/${PACKAGE}
    mkdir -p ${TMP_DIR}/${PACKAGE}
    mv ${INSTALL_DIR}/var ${TMP_DIR}/${PACKAGE}/
    #if there's backups
    if [ -d ${INSTALL_DIR}/backups ];then
    mv ${INSTALL_DIR}/backups ${TMP_DIR}/${PACKAGE}/
    fi
    if [ -d ${INSTALL_DIR}/scripts ];then 
    mv ${INSTALL_DIR}/scripts ${TMP_DIR}/${PACKAGE}/
    fi

    exit 0
}

postupgrade ()
{
    # Restore some stuff
    rm -fr ${INSTALL_DIR}/var
    mv ${TMP_DIR}/${PACKAGE}/var ${INSTALL_DIR}/
    if [ -d ${TMP_DIR}/${PACKAGE}/backups ];then
    mv ${TMP_DIR}/${PACKAGE}/backups ${INSTALL_DIR}/
    fi
    if [ -d  ${TMP_DIR}/${PACKAGE}/scripts ];then
    #preserve the USB serial permissions rules file
    cp ${INSTALL_DIR}/scripts/50-usbttyacm.rules ${TMP_DIR}/${PACKAGE}/scripts/
    #preserve the new scripts dir just in case there's new/updated templates
    mv ${INSTALL_DIR}/scripts/ ${INSTALL_DIR}/scripts.new/
    #place the pre upgrade scripts dir into the install dir
    mv ${TMP_DIR}/${PACKAGE}/scripts ${INSTALL_DIR}/
    fi
    rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
