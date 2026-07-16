#!/bin/sh
set -e

clear

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

case "$1" in
	cross-compiler)
		shift
		"$SCRIPT_DIR/scripts/cross-compiler.sh"
		;;
	b-txboot)
		shift
		cd txboot
		make all
		;;
	*)
		echo "Usage:"
		echo "$0 cross-compiler"
		echo "$0 b-txboot"
		echo "$0 b-txkrnl"
		echo "$0 d-txkrnl"
		echo "$0 b-all"
		echo "$0 b-iso"
		echo "$0 run\n"
		;;
esac

