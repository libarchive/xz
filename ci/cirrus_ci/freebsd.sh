#!/bin/sh
set -x -e
env ASSUME_ALWAYS_YES=yes pkg bootstrap -f
pkg update
pkg install -y autoconf automake libtool cmake gettext po4a
