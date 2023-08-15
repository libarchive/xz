#!/bin/sh
set -x -e
brew update > /dev/null
for pkg in autoconf automake libtool gettext doxygen
do
	brew list $pkg > /dev/null && brew upgrade $pkg || brew install $pkg
done
