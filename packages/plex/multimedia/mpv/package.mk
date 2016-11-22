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

PKG_NAME="mpv"
PKG_VERSION="master"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://nightlies.plex.tv"
PKG_URL="$PKG_SITE/directdl/plex-oe-sources/$PKG_NAME-dummy.tar.gz"
PKG_DEPENDS_TARGET="toolchain libass qt5 libdrm alsa"
PKG_PRIORITY="optional"
PKG_SECTION="multimedia"
PKG_SHORTDESC="MPV Movie Player
PKG_LONGDESC="

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

PKG_CONFIGURE_OPTS_TARGET="--enable-libmpv-shared --disable-libsmbclient --disable-apple-remote --prefix=${SYSROOT_PREFIX}/usr"

MPV_EXTRA_CFLAGS="-I$PWD/$BUILD/${PKG_NAME}-${PKG_VERSION}/extraheaders"

# generate debug symbols for this package
# if we want to
DEBUG=$PLEX_DEBUG

# Handle ffmpeg / codec dependencies
if [ "$CODECS" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET ffmpeg-codecs gnutls"

  case $PROJECT in
    Generic)
      PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libva-intel-driver libvdpau"
    ;;
  esac 
else
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET ffmpeg-plex" 
fi

unpack() {
  mkdir $BUILD/${PKG_NAME}-${PKG_VERSION}
  git clone --depth 1 -b $PKG_VERSION git@github.com:wm4/mpv.git $BUILD/${PKG_NAME}-${PKG_VERSION}/.
  case $PROJECT in
    RPi|RPi2|Odroid_C2)
      # Before changing the subtitle renderer to EGL/GLES
      # These are needed on RPI only. Without, RPI output support
      # will not be compiled.
      mkdir $BUILD/${PKG_NAME}-${PKG_VERSION}/extraheaders || true
      cp -r $PKG_DIR/GL/ $BUILD/${PKG_NAME}-${PKG_VERSION}/extraheaders
    ;;
  esac
}

configure_target() {
  cd ${ROOT}/${BUILD}/${PKG_NAME}-${PKG_VERSION}
  ./bootstrap.py
  CFLAGS="$MPV_EXTRA_CFLAGS" ./waf configure ${PKG_CONFIGURE_OPTS_TARGET}
}

make_target() {
  cd ${ROOT}/${BUILD}/${PKG_NAME}-${PKG_VERSION}
  ./waf build
}

makeinstall_target() {
  cd ${ROOT}/${BUILD}/${PKG_NAME}-${PKG_VERSION}
  ./waf install

  mkdir -p $INSTALL/usr/lib
  cp ${SYSROOT_PREFIX}/usr/lib/libmpv.so ${INSTALL}/usr/lib

  cd ${INSTALL}/usr/lib/
  ln -s libmpv.so libmpv.so.1

  cd ${ROOT}

  debug_strip ${INSTALL}/usr/lib
}

pre_install()
{
 deploy_symbols
}
