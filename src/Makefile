# ===============================================================================
# Copyright (C) 2015 Thibaud Gaillard <thibaud.gaillard@gmail.com>
# Copyright (C) 2015 WebOS Internals <support@webos-internals.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA  02110-1301, USA.
# ===============================================================================

NAME = openssl
VERSION = 0.9.8k

DEPENDS =

#
# SOURCE
#
SRC_URL = http://www.openssl.org/source/$(NAME)-$(VERSION).tar.gz
SRC_PKG = $(notdir $(SRC_URL))
SRC_TZJ = $(patsubst %gz,-z,$(patsubst %bz2,-j,$(SRC_PKG))) 

#
# PATCH
#
PATCH += $(wildcard patch/openssl-$(VERSION)-palm.patch)

#
# BUILD
#
BUILD_DIR     = /srv/preware/build
TOOLCHAIN_DIR = $(BUILD_DIR)/toolchain
STAGING_DIR   = $(BUILD_DIR)/staging/$(ARCH)

#
# COMPILER & APPLICATION COMPILE FLAGS
#
ifeq (arm,$(ARCH))
  ARCH = armv7
endif
ifeq (armv7,$(ARCH))
CROSS_COMPILE  = $(TOOLCHAIN_DIR)/cs07q3armel/build/arm-2007q3/bin/arm-none-linux-gnueabi-
OPENSSL_CFLAGS = -mcpu=cortex-a8 -mfpu=neon -mfloat-abi=softfp -mthumb-interwork -mno-thumb \
                 -fPIC -fexpensive-optimizations -fomit-frame-pointer -frename-registers -fno-strict-aliasing -fno-inline-functions \
                 -DOPENSSL_PIC -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DL_ENDIAN -DTERMIO \
                 -O2 -Wall
endif
ifeq (armv6,$(ARCH))
CROSS_COMPILE  = $(TOOLCHAIN_DIR)/cs09q1armel/build/arm-2009q1/bin/arm-none-linux-gnueabi-
OPENSSL_CFLAGS = -mcpu=arm1136jf-s -mfpu=vfp -mfloat-abi=softfp -mthumb-interwork -mno-thumb \
                 -fPIC -fexpensive-optimizations -fomit-frame-pointer -frename-registers \
                 -DOPENSSL_PIC -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DL_ENDIAN -DTERMIO \
                 -O2 -Wall
endif
ifeq (i686,$(ARCH))
CROSS_COMPILE  = $(TOOLCHAIN_DIR)/i686-unknown-linux-gnu/build/i686-unknown-linux-gnu/bin/i686-unknown-linux-gnu-
OPENSSL_CFLAGS = -fPIC -fexpensive-optimizations -fomit-frame-pointer -frename-registers -fno-strict-aliasing -fno-inline-functions \
                 -DOPENSSL_PIC -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -DL_ENDIAN -DTERMIO \
                 -O3 -Wall \
#                 -DOPENSSL_BN_ASM_PART_WORDS -DOPENSSL_IA32_SSE2 -DSHA1_ASM -DMD5_ASM -DRMD160_ASM -DAES_ASM
endif
CC     = $(CROSS_COMPILE)gcc
AR     = $(CROSS_COMPILE)ar
RANLIB = $(CROSS_COMPILE)ranlib

# A remnant of the past...
#
SB2 = CC="$(CC)" AR="$(AR) r" RANLIB="$(RANLIB)"


ifneq (,$(DEBUG))
OPENSSL_CFLAGS += -g
endif

#
# Process general targets
#
ifeq (,$(ARCH))
  $(warning ERROR, ARCH is not defined...)

  .PHONY: all
  all: install-armv7 install-armv6 install-i686

  .PHONY: armv7 armv6 i686
  armv7 armv6 i686: 
	$(MAKE) ARCH="$@" stage

  .PHONY: install-armv7 install-armv6 install-i686
  install-armv7 install-armv6 install-i686: install-%:
	$(MAKE) ARCH="$*" install

# 
# Or make sure the BUILD has the bare minimum setup done
# 
else
ifeq (,$(wildcard $(STAGING_DIR)))
  $(error ERROR, could not find a BUILD staging directory for $(ARCH))
endif
ifeq (,$(CROSS_COMPILE))
$(error Undefined CROSS_COMPILE environment, did you define ARCH (arm, armv7, armv6 or i686)?)
endif

endif

#
# Default target
#
.PHONY: all
all: build/$(ARCH).installed

#
# Identify the local source files this service depends on
#
SRC_FILES = 

#
# Here is the build stuff...
#

.PHONY: download unpack stage install
download:     build/downloaded
unpack:       build/unpacked
stage::       build/$(ARCH).staged
install::     build/$(ARCH).installed

BUILD_SRC_DIR  = build/src
BUILD_MAKE_DIR = build/src
BUILD_INST_DIR = build/$*

.SECONDARY: build/downloaded
build/downloaded: download/$(SRC_PKG)
	mkdir -p build
	touch $@

download/$(SRC_PKG):
	rm -f $@
	mkdir -p build
	mkdir -p download
	rm -f download/$(SRC_PKG).tmp
	curl -f -R -L $(SRC_URL) > download/$(SRC_PKG).tmp
	mv download/$(SRC_PKG).tmp download/$(SRC_PKG)
	touch $@

.SECONDARY: build/unpacked
build/unpacked: build/downloaded
	rm -f $@
	rm -rf $(BUILD_SRC_DIR)
	mkdir -p build
	tar -C build $(SRC_TZJ) -x -f download/$(SRC_PKG) 2>build/$(NAME)-$(VERSION).tar.log; \
	  exitcode="$$?"; \
	  [ -s build/$(NAME)-$(VERSION).tar.log ] && awk '{ print "  | " $$0}' build/$(NAME)-$(VERSION).tar.log; \
	  if [ "$${exitcode}" != "0" ]; then exit $${exitcode}; fi
	mv build/$(NAME)-$(VERSION) $(BUILD_SRC_DIR)
	[ -z "$(strip $(PATCH))" ] || (for patch in $(PATCH); do if [ ! -f "$${patch}" ]; then echo 1>&2 "ERROR: patch not found ($${patch})"; exit 2; else patch -d build/src -p 1 < $${patch}; fi; done)
	(cd $(BUILD_SRC_DIR); etags `find . -type f -print`)
	touch $@

.SECONDARY: build/$(ARCH).staged
build/%.staged: build/unpacked
	rm -f $@
	cd $(BUILD_MAKE_DIR); \
	  $(SB2) ./Configure --prefix="/usr" --openssldir="/usr/lib/ssl" shared no-zlib no-asm linux-elf $(OPENSSL_CFLAGS)
	cd $(BUILD_MAKE_DIR); \
	  $(SB2) $(MAKE) ARCH=$(ARCH) clean all
	touch $@


.SECONDARY: build/$(ARCH).installed
build/%.installed: build/$(ARCH).staged
	rm -f $@
	rm -rf $(BUILD_INST_DIR)
	mkdir -p $(BUILD_INST_DIR)
	mkdir -p $(BUILD_INST_DIR)/usr/bin
	install -m 755 $(BUILD_MAKE_DIR)/apps/openssl $(BUILD_INST_DIR)/usr/bin
	mkdir -p $(BUILD_INST_DIR)/usr/lib
	install -m 755 $(BUILD_MAKE_DIR)/libcrypto.so.* $(BUILD_INST_DIR)/usr/lib
	install -m 755 $(BUILD_MAKE_DIR)/libssl.so.*    $(BUILD_INST_DIR)/usr/lib
	mkdir -p package
	tar cvzf package/openssl-$(VERSION)_$*.tar.gz -C $(BUILD_INST_DIR) usr
	touch $@


.PHONY: clean realclean
clean:
	/bin/rm -f core *~

realclean: clean
	/bin/rm -rf build

