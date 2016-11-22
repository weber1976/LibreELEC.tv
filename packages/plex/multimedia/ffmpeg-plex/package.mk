################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
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

PKG_NAME="ffmpeg-plex"
PKG_VERSION="master"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="LGPLv2.1+"
PKG_SITE="https://nightlies.plex.tv"
PKG_URL="$PKG_SITE/directdl/plex-oe-sources/$PKG_NAME-dummy.tar.gz"
PKG_DEPENDS_TARGET="toolchain yasm:host zlib bzip2 libvorbis libressl gnutls"

PKG_PRIORITY="optional"
PKG_SECTION="multimedia"
PKG_SHORTDESC="FFmpeg is a complete, cross-platform solution to record, convert and stream audio and video."
PKG_LONGDESC="FFmpeg is a complete, cross-platform solution to record, convert and stream audio and video."

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

# configure GPU drivers and dependencies:
get_graphicdrivers

# generate debug symbols for this package
# if we want to
DEBUG=$PLEX_DEBUG

case $PROJECT in
  WeTek_Hub|Odroid_C2)
    PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} libamcodec"
    PKG_VERSION="amlvideo"
  ;;
esac

unpack() {
  case $PROJECT in
    WeTek_Hub|Odroid_C2)
      git clone -b $PKG_VERSION git@github.com:LongChair/FFmpeg.git $BUILD/${PKG_NAME}-${PKG_VERSION}
    ;;

    *)
      git clone --depth 1 -b $PKG_VERSION git@github.com:wm4/FFmpeg.git $BUILD/${PKG_NAME}-${PKG_VERSION}
    ;;
  esac
}

if [ "$VAAPI_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libva-intel-driver"
  FFMPEG_VAAPI="--enable-vaapi"
else
  FFMPEG_VAAPI="--disable-vaapi"
fi

if [ "$VDPAU_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libvdpau"
  FFMPEG_VDPAU="--enable-vdpau"
else
  FFMPEG_VDPAU="--disable-vdpau"
fi

if [ "$DCADEC_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET dcadec"
  FFMPEG_LIBDCADEC="--enable-libdcadec"
else
  FFMPEG_LIBDCADEC="--disable-libdcadec"
fi

# We always want debugging on ffmpeg
FFMPEG_DEBUG="--enable-debug --disable-stripping"

case "$TARGET_ARCH" in
  arm)
      FFMPEG_CPU=""
      FFMPEG_TABLES="--enable-hardcoded-tables"
      FFMPEG_PIC="--enable-pic"
  ;;
  x86_64)
      FFMPEG_CPU=""
      FFMPEG_TABLES="--disable-hardcoded-tables"
      FFMPEG_PIC="--enable-pic"
  ;;
esac

case "$TARGET_FPU" in
  neon*)
      FFMPEG_FPU="--enable-neon"
  ;;
  vfp*)
      FFMPEG_FPU=""
  ;;
  *)
      FFMPEG_FPU=""
  ;;
esac

case $PROJECT in
  RPi|RPi2)
    FFMPEG_MMAL="--enable-mmal"
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET bcm2835-driver"
  ;;

  WeTek_Hub|Odroid_C2)
    FFMPEG_AML="--enable-aml"
  ;;
esac

pre_configure_target() {
  cd $ROOT/$PKG_BUILD
  rm -rf .$TARGET_NAME

# ffmpeg fails building with LTO support
  strip_lto

# ffmpeg fails running with GOLD support
  strip_gold
}

configure_target() {
  ./configure --prefix=/usr \
              --cpu=$TARGET_CPU \
              --arch=$TARGET_ARCH \
              --enable-cross-compile \
              --cross-prefix=$TARGET_PREFIX \
              --sysroot=$SYSROOT_PREFIX \
              --sysinclude="$SYSROOT_PREFIX/usr/include" \
              --target-os="linux" \
              --extra-version="$PKG_VERSION" \
              --nm="$NM" \
              --ar="$AR" \
              --as="$CC" \
              --cc="$CC" \
              --ld="$CC" \
              --host-cc="$HOST_CC" \
              --host-cflags="$HOST_CFLAGS" \
              --host-ldflags="$HOST_LDFLAGS" \
              --host-libs="-lm" \
              --extra-cflags="$CFLAGS" \
              --extra-ldflags="$LDFLAGS -fPIC" \
              --extra-libs="" \
              --extra-version="" \
              --build-suffix="" \
              --disable-static \
              --enable-shared \
              --disable-version3 \
              --disable-doc \
              $FFMPEG_DEBUG \
              $FFMPEG_PIC \
              --pkg-config="$ROOT/$TOOLCHAIN/bin/pkg-config" \
              --disable-armv5te --disable-armv6t2 \
              --disable-ffprobe \
              --disable-ffplay \
              --disable-ffserver \
              --disable-devices \
              --disable-x11grab \
              --enable-gnutls  \
              $FFMPEG_VAAPI \
              $FFMPEG_VDPAU \
              --disable-encoders \
              --enable-encoder=ac3 \
              --disable-muxers \
              --enable-muxer=spdif \
              --disable-indevs \
              --disable-outdevs \
              --disable-altivec \
              $FFMPEG_CPU \
              $FFMPEG_FPU \
              --disable-symver \
              $FFMPEG_AML \
              $FFMPEG_MMAL
}

pre_install()
{
 deploy_symbols
}

post_makeinstall_target() {
  rm -rf $INSTALL/usr/share/ffmpeg/examples
  rm -rf $INSTALL/usr/bin

  debug_strip $INSTALL/usr/lib
}
