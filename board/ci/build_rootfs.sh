#!/bin/bash
#
# Skia < skia AT libskia DOT so >
#
# Beerware licensed software - 2017
#

cd $(dirname $0)
BASE="$(pwd)"
BUILDROOT_ROOT_PATH="$BASE/../.."
OUTPUT="$BUILDROOT_ROOT_PATH/output"
BUILDROOT_LOG="$BASE/buildroot.log"
BUSYBOX_DEFCONFIG="$BASE/ci_defconfig"
OVERLAY="$BASE/overlay"
TEST_REPO="https://github.com/free-electrons/custom_tests"
TEST_FOLDER="$OVERLAY/tests"


cd $OVERLAY
echo "Cleaning old tests"
test -d $TEST_FOLDER&&rm -rf $TEST_FOLDER
echo "Fetching latest tests"
git clone $TEST_REPO $TEST_FOLDER
echo "Remove .git folder to save some space"
rm -rf $TEST_FOLDER/.git


cd $BUILDROOT_ROOT_PATH

echo "Starting the build"
echo "Launching Buildroot" > $BUILDROOT_LOG
make ci_defconfig >> $BUILDROOT_LOG 2>&1
make -j 4 >> $BUILDROOT_LOG 2>&1
if [ "$?" != 0 ]; then
    echo "Build failed, see $BUILDROOT_LOG"
    exit 1
fi
echo "Build finished!"


