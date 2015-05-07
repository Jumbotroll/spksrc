PKG_NAME = udev
PKG_VERS = 175
PKG_EXT = tar.bz2
PKG_DIST_NAME = $(PKG_NAME)_$(PKG_VERS).orig.$(PKG_EXT)
PKG_DIST_SITE = http://http.debian.net/debian/pool/main/u/$(PKG_NAME)/
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/glib cross/usbutils

HOMEPAGE = http://www.freedesktop.org/wiki/Software/systemd/
COMMENT  = This package contains the files needed for developing applications that use libudev.
LICENSE  = GPL

ENV+= USBUTILS_CFLAGS=" " USBUTILS_LIBS=" "
GNU_CONFIGURE = 1
CONFIGURE_ARGS = --disable-introspection --disable-gudev --with-pci-ids-path=$(INSTALL_DIR)/usr/local/share/pci.ids --with-usb-ids-path=$(INSTALL_DIR)/usr/local/share/usb.ids
PRE_CONFIGURE_TARGET = myPreConfigure
INSTALL_TARGET = myInstall

include ../../mk/spksrc.cross-cc.mk

.PHONY: myPreConfigure
myPreConfigure:
	$(RUN) wget https://pci-ids.ucw.cz/v2.2/pci.ids -P $(INSTALL_DIR)/usr/local/share/


.PHONY: myInstall
myInstall:
	$(RUN) $(MAKE) install DESTDIR=$(INSTALL_DIR)
