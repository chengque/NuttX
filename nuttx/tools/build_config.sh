#!/bin/sh

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

cd nuttx/tools
./configure.sh $CONFIG
cd ..
if ! (make &> $BUILDLOG); then
	echo "CONFIG $CONFIGPATH FAILED BUILD\n\n\n"
	exit 1;
else
	cp nuttx $LOGDIR/.
	cp nuttx.bin $LOGDIR/.
	exit 0;
fi
