################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="icu"
PKG_VERSION="52_1"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://nightlies.plex.tv"
PKG_URL="$PKG_SITE/directdl/plex-oe-sources/icu4c-$PKG_VERSION-src.tgz"
PKG_DEPENDS_TARGET="toolchain icu:host"
PKG_PRIORITY="optional"
PKG_SECTION="multimedia"
PKG_SHORTDESC="LibICU"
PKG_LONGDESC="ICU is a mature, widely used set of C/C++ and Java libraries providing Unicode and Globalization support for software applications. ICU is widely portable and gives applications the same results on all platforms and between C/C++ and Java software."

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

PKG_CONFIGURE_OPTS_HOST="--disable-samples --disable-test --prefix=$PWD/icu_host"
PKG_CONFIGURE_OPTS_TARGET="--disable-samples  --disable-test --with-cross-build=$ROOT/$BUILD/${PKG_NAME}-${PKG_VERSION}/icu_host"

unpack() {
  tar -xzf $SOURCES/${PKG_NAME}/icu4c-$PKG_VERSION-src.tgz -C $BUILD/
  mv $BUILD/icu/source $BUILD/${PKG_NAME}-${PKG_VERSION}
  rm -rf $BUILD/icu
  cp  $PKG_DIR/icudt52l.dat $BUILD/${PKG_NAME}-${PKG_VERSION}/data/in/
}

configure_host() {
  mkdir $ROOT/$BUILD/${PKG_NAME}-${PKG_VERSION}/icu_host
  cd $ROOT/$BUILD/${PKG_NAME}-${PKG_VERSION}/icu_host
  $ROOT/$BUILD/${PKG_NAME}-${PKG_VERSION}/runConfigureICU Linux --prefix=$ROOT/$TOOLCHAIN --enable-extras=no --enable-tests=no --enable-samples=no
}
