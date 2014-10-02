#!/bin/bash

set -e
set -x

mkdir ~/screen && cd ~/screen

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
RPATH=/opt/lib
DEST=$BASE/opt
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include -I$DEST/include/ncursesw"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

########### #################################################################
# NCURSES # #################################################################
########### #################################################################

mkdir $SRC/curses && cd $SRC/curses
$WGET http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz
tar zxvf ncurses-5.9.tar.gz
cd ncurses-5.9

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--enable-widec \
--disable-database \
--with-fallbacks=xterm

$MAKE
make install DESTDIR=$BASE
ln -s libncursesw.a $DEST/lib/libcurses.a

########## ##################################################################
# SCREEN # ##################################################################
########## ##################################################################

mkdir $SRC/screen && cd $SRC/screen
$WGET http://ftp.gnu.org/gnu/screen/screen-4.2.1.tar.gz
tar zxvf screen-4.2.1.tar.gz
cd screen-4.2.1

$WGET https://raw.github.com/lancethepants/tomatoware/master/patches/screen/screen.patch
patch < screen.patch

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE LIBS="-static -lcurses -lcrypt"
make install DESTDIR=$BASE/screen
