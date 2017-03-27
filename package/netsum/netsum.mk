#############################################################
#
# netsum
#
#############################################################

NETSUM_SITE = git://lacie-nas.org/netsum.git
NETSUM_VERSION = 613515d678d702949cb79b60f98f8eded692cf9a
NETSUM_LICENSE = GPLv3
NETSUM_LICENSE_FILES = COPYING

define NETSUM_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(TARGET_CPPFLAGS) -DHAVE_GETOPT_LONG"
endef

define NETSUM_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install \
		DESTDIR=$(TARGET_DIR)
endef

define HOST_NETSUM_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) \
		$(HOST_CONFIGURE_OPTS) \
		CPPFLAGS="$(HOST_CPPFLAGS) -DHAVE_GETOPT_LONG"
endef

define HOST_NETSUM_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install \
		DESTDIR=$(HOST_DIR)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
