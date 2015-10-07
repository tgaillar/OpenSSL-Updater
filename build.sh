#!/bin/sh

if [ -z "$1" ]; then
  echo 2>&1 "ERROR, no architecture specified"
  exit 2
else
  ARCH="$1"
fi

if [ -z "$2" ]; then
  PKGDIR=`pwd`
else
  PKGDIR="$2"
fi

if [ ! -r $PKGDIR/appinfo.json ]; then
  echo 1>&2 "ERROR, current/specified directory does not reference a Palm app ($PKGDIR)"
  exit 2
fi

(cd src; make install ARCH=$ARCH)

SRCDIR="src/build/$ARCH"

if [ ! -d $SRCDIR ]; then
  echo 1>&2 "ERROR, could not find package source directory for $ARCH ($SRCDIR)"
  exit 2
fi

palm_gen_ipk.sh $PKGDIR \
  "
    control/postinst
    control/prerm
  " \
  \
  "
    appinfo.json
    icon.png
    icon_splash.png
    index.html
    app
    sources.json

    install=$SRCDIR
    src/Makefile
    src/patch

    control/postinst
    control/prerm
  " \
  \
  $ARCH
