#!/bin/sh
cd "${0%/*}" || exit 1

TARGET="${TARGET:-rtef}"
PREFIX="${PREFIX:-/usr}"
PROGNAME="${PROGNAME:-rtef}"
INSTALL_PATH="${INSTALL_PATH:-${DESTDIR}${PREFIX}/bin/${TARGET}}"

CC="${CC:-cc}"
LD="${LD:-cc}"

OBJECTS="$(grep -E '^OBJECTS=' GNUmakefile)"
OBJECTS="${OBJECTS#OBJECTS=}"

WFLAGS="
	-Werror=pedantic
    -D_POSIX_C_SOURCE=0
	-DPROGNAME=\"\\\"$PROGNAME\\\"\"
    -std=c99"

erun() {
	echo $*
	$*
}

CC() {
    OUTFILE="$1"
    shift
	erun $CC -c $WFLAGS $CFLAGS $* -o $OUTFILE
}

LD() {
    OUTFILE="$1"
    shift
	erun $LD $CFLAGS $* -o $OUTFILE
}

case "$1" in
    clean)
		erun rm -f $OBJECTS
        ;;
    install)
        erun install -Dm755 $TARGET $INSTALL_PATH
        ;;
    uninstall)
        erun rm -f $INSTALL_PATH
        ;;
    *)
        [ "$1" = debug ] && CFLAGS="$CFLAGS -O0 -g"
        for object in $OBJECTS; do
            CC $object "${object%.o}.c"
        done
        LD "$TARGET" $OBJECTS
        ;;
esac