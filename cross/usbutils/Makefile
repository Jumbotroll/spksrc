PKG_NAME = usbutils
PKG_VERS = 005
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)_$(PKG_VERS).orig.$(PKG_EXT)
PKG_DIST_SITE = http://http.debian.net/debian/pool/main/u/$(PKG_NAME)/
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/glib cross/libusb

HOMEPAGE = http://www.freedesktop.org/wiki/Software/systemd/
COMMENT  = This package contains the files needed for developing applications that use libudev.
LICENSE  = GPL

GNU_CONFIGURE = 1
PRE_CONFIGURE_TARGET = myPreConfigure
CONFIGURE_ARGS = --disable-introspection

include ../../mk/spksrc.cross-cc.mk


.PHONY: myPreConfigure
myPreConfigure:
	$(RUN) autoconf
	$(RUN) aclocal
	$(RUN) autoreconf --install
	$(RUN) automake

