#!/bin/bash

CONFIGPATH=$1
BASE=`pwd`

CONFIGBASEPATH=`dirname $CONFIGPATH`
PREFIX=nuttx\/configs\/
LOGSDIR=$BASE/travis_output

IGNORED=`cat .travis_ignored_configs.txt | grep $CONFIGPATH`

if [[ $IGNORED ]]
then
	# echo "Ignoring config $CONFIG"
	exit 0
fi

# Config is valid, build it

echo "Building config $CONFIGPATH"

CONFIG=${CONFIGBASEPATH#$PREFIX}
LOGDIR="$LOGSDIR/${CONFIG//\//_}"
BUILDLOG="$LOGDIR/buildlog.txt"

echo "BUILDING CONFIG $CONFIG"
echo "LOGDIR: $LOGDIR"
echo "LOG: $BUILDLOG"
mkdir -p $LOGDIR

# Manually reconfigure for Linux toolchain
sed -i 's/# CONFIG_HOST_LINUX is not set/CONFIG_HOST_LINUX=y/g' $CONFIGPATH
sed -i 's/CONFIG_HOST_WINDOWS=y/# CONFIG_HOST_WINDOWS is not set/g' $CONFIGPATH
sed -i 's/CONFIG_ARMV7M_TOOLCHAIN_BUILDROOT=y/# CONFIG_ARMV7M_TOOLCHAIN_BUILDROOT is not set/g' $CONFIGPATH
sed -i 's/CONFIG_ARMV7M_TOOLCHAIN_CODEREDL=y/# CONFIG_ARMV7M_TOOLCHAIN_BUILDROOT is not set/g' $CONFIGPATH
sed -i 's/CONFIG_ARMV7M_TOOLCHAIN_CODESOURCERYL=y/# CONFIG_ARMV7M_TOOLCHAIN_BUILDROOT is not set/g' $CONFIGPATH
sed -i 's/# CONFIG_ARMV7M_TOOLCHAIN_GNU_EABIL is not set/CONFIG_ARMV7M_TOOLCHAIN_GNU_EABIL=y/g' $CONFIGPATH

# Clean build dir
git clean -d -f -x nuttx

cd nuttx/tools
./configure.sh $CONFIG
cd ..
if ! (make &> $BUILDLOG); then
	echo -e "\e[31mCONFIG $CONFIG: FAILED BUILD\e[0m\n\n"
	exit 1;
else
	echo -e "\e[32mCONFIG $CONFIG: SUCCESSFUL BUILD\e[0m\n\n"
	cp nuttx $LOGDIR/.
	exit 0;
fi
