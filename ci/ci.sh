#!/bin/sh
#
# Automated build and test of libarchive on CI systems
#
# Variables that can be passed via environment:
# BS=			# build system (autotools or cmake)
# BUILDDIR=		# build directory
# SRCDIR=		# source directory
# CONFIGURE_ARGS=	# configure arguments
# CMAKE_ARGS=		# cmake arguments
# MAKE_ARGS=		# make arguments
# DEBUG=		# set -g -fsanitize=address flags

ACTIONS=
BS="${BS:-autotools}"
MAKE="${MAKE:-make}"
CMAKE="${CMAKE:-cmake}"
CURDIR=`pwd`
SRCDIR="${SRCDIR:-`pwd`}"
RET=0

usage () {
	echo "Usage: $0 [-b autotools|cmake] [-a autogen|configure|build|test|install ] [ -a ... ] [ -d builddir ] [-s srcdir ]"
}
inputerror () {
	echo $1
	usage
	exit 1
}
case `uname` in
	Darwin)
		PATH=/usr/local/opt/gettext/bin:$PATH
	;;
esac
while getopts a:b:c:d:s: opt; do
	case ${opt} in
		a)
			case "${OPTARG}" in
				autogen) ;;
				configure) ;;
				build) ;;
				test) ;;
				install) ;;
				distcheck) ;;
				artifact) ;;
				*) inputerror "Invalid action (-a)" ;;
			esac
			ACTIONS="${ACTIONS} ${OPTARG}"
		;;
		b) BS="${OPTARG}"
			case "${BS}" in
				autotools) ;;
				cmake) ;;
				*) inputerror "Invalid build system (-b)" ;;
			esac
		;;
		d)
			BUILDDIR="${OPTARG}"
		;;
		s)
			SRCDIR="${OPTARG}"
		;;
	esac
done
if [ -z "${MAKE_ARGS}" ]; then
	if [ "${BS}" = "autotools" ]; then
		MAKE_ARGS="V=1"
	elif [ "${BS}" = "cmake" ]; then
		MAKE_ARGS="VERBOSE=1"
	fi
fi
if [ -n "${DEBUG}" ]; then
	if [ -n "${CFLAGS}" ]; then
		export CFLAGS="${CFLAGS} -g -fsanitize=address"
	else
		export CFLAGS="-g -fsanitize=address"
	fi
	if [ "${BS}" = "cmake" ]; then
		CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_C_CFLAGS=-g -fsanitize=address"
	fi
fi
if [ -z "${ACTIONS}" ]; then
	ACTIONS="autogen configure build test install"
fi
if [ -z "${BS}" ]; then
	inputerror "Missing build system (-b) parameter"
fi
if [ -z "${BUILDDIR}" ]; then
	BUILDDIR="${CURDIR}/build_ci/${BS}"
fi
mkdir -p "${BUILDDIR}"
for action in ${ACTIONS}; do
	cd "${BUILDDIR}"
	case "${action}" in
		autogen)
			case "${BS}" in
				autotools)
					cd "${SRCDIR}"
					if type po4a; then
						sh autogen.sh
					else
						sh autogen.sh --no-po4a
					fi
					RET="$?"
				;;
			esac
		;;
		configure)
			case "${BS}" in
				autotools) "${SRCDIR}/configure" ${CONFIGURE_ARGS} ;;
				cmake) ${CMAKE} ${CMAKE_ARGS} "${SRCDIR}" ;;
			esac
			RET="$?"
		;;
		build)
			${MAKE} ${MAKE_ARGS}
			RET="$?"
		;;
		test)
			case "${BS}" in
				autotools)
					${MAKE} ${MAKE_ARGS} check
					;;
				cmake)
					# not yet supported
					# ${MAKE} ${MAKE_ARGS} test
					;;
			esac
			RET="$?"
		;;
		install)
			${MAKE} ${MAKE_ARGS} install DESTDIR="${BUILDDIR}/destdir"
			RET="$?"
			cd "${BUILDDIR}/destdir" && ls -lR .
		;;
	esac
	if [ "${RET}" != "0" ]; then
		exit "${RET}"
	fi
	cd "${CURDIR}"
done
exit "${RET}"
