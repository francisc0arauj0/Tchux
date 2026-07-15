#!/bin/sh
set -e

clear

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

case "$1" in
	cross-compiler)
		shift
		"$SCRIPT_DIR/scripts/cross-compiler.sh"
		;;
	*)
		echo "Usage:"
		echo "$0 cross-compiler"
		echo "$0 build txboot"
		echo "$0 build txkrnl"
		echo "$0 debug txkrnl"
		echo "$0 build all"
		echo "$0 build iso"
		echo "$0 run\n"
		;;
esac

