################################################################################
#
# libmaxminddb
#
################################################################################

LIBMAXMINDDB_VERSION = 1.2.0
LIBMAXMINDDB_SITE = $(call github,maxmind,libmaxminddb,$(LIBMAXMINDDB_VERSION))
LIBMAXMINDDB_INSTALL_STAGING = YES
LIBMAXMINDDB_LICENSE = Apache-2.0
LIBMAXMINDDB_LICENSE_FILES = LICENSE
# Fetched from Github, with no configure script, and we're patching
# configure.ac
LIBMAXMINDDB_AUTORECONF = YES
LIBMAXMINDDB_CONF_OPTS = --disable-tests

$(eval $(autotools-package))
