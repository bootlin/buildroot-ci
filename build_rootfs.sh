#!/bin/bash
#
# Florent Jacquet <florent.jacquet@free-electrons.com>
#

cd $(dirname $0)
BASE="$(pwd)"
BUILDROOT_ROOT_PATH="$BASE"
BUILDROOT_TMP_DEFCONFIG="/tmp/defconfig"
OUTPUT="$BUILDROOT_ROOT_PATH/out"
OVERLAY="$BASE/board/ci/overlay"
TEST_REPO="https://github.com/free-electrons/test_suite"
TEST_FOLDER="$OVERLAY/tests"
COMMAND=""

print_help () {
    echo -e "Usage: $0 <command> ARCH [<command> ARCH ...]\n"
    echo -e "\n\tAvailable commands:"
    echo -e "\t\tbuild         run make -j 4"
    echo -e "\t\tdefconfig     run make defconfig with the proper defconfig in BR2_DEFCONFIG"
    echo -e "\t\tsavedefconfig run make savedefconfig and save to the appropriate file"
    echo -e "\n\tAvailable ARCHs:"
    echo -e "\t\tarmv4"
    echo -e "\t\tarmv5"
    echo -e "\t\tarmv6"
    echo -e "\t\tarmv7"
    echo -e "\t\taarch64"
    echo -e "\n\tExamples:"
    echo -e "\n\t$0 defconfig armv7"
    echo -e "\t\t This will setup the proper environment to build an armv7 rootfs"
    echo -e "\n\t$0 build armv7"
    echo -e "\t\t This will actually build an armv7 rootfs"
    echo -e "\n\t$0 savedefconfig armv7"
    echo -e "\t\t This will save the armv7 defconfig after you made some changes in the .config with \`make menuconfig\`"
    echo -e "\n\t$0 defconfig armv5 build armv5 defconfig armv7 build armv7"
    echo -e "\t\t This will build both armv5 and armv7 rootfs after setuping each defconfig"
    echo -e "\n All rootfs will be stored in the $OUTPUT folder."
    echo -e "\n\n"
    exit 1
}

if [ "$#" -eq 0 ]; then
    print_help;
fi

prepare_overlay () {
    cd $OVERLAY
    echo "Cleaning old tests"
    test -d $TEST_FOLDER&&rm -rf $TEST_FOLDER
    echo "Fetching latest tests"
    git clone $TEST_REPO $TEST_FOLDER
    echo "Remove .git folder to save some space"
    rm -rf $TEST_FOLDER/.git
}

defconfig () {
    cd $BUILDROOT_ROOT_PATH
    set -x
    echo "Making $1"
    cat configs/ci_common_defconfig configs/ci_${1}_defconfig > $BUILDROOT_TMP_DEFCONFIG
    make BR2_DEFCONFIG="$BUILDROOT_TMP_DEFCONFIG" defconfig
    set +x
}

savedefconfig () {
    cd $BUILDROOT_ROOT_PATH
    echo "Saving defconfig to configs/ci_${1}_defconfig"
    make savedefconfig
    comm --nocheck-order -23 ${BUILDROOT_TMP_DEFCONFIG} configs/ci_common_defconfig >  ./configs/ci_${1}_defconfig
}

build () {
    cd $BUILDROOT_ROOT_PATH
    echo "Cleaning old build"
    make clean
    echo "Starting the build for $1"
    echo "Launching Buildroot"
    make -j 4
    if [ "$?" != 0 ]; then
        echo -e "\033[31mBuild failed\033[39m"
        exit 1
    fi
    echo -e "\033[32mBuild finished!\033[39m"
    echo "Copying and renaming file"
    test -d $OUTPUT || mkdir $OUTPUT
    cp output/images/rootfs.cpio.gz $OUTPUT/rootfs_$1.cpio.gz
    cp output/images/rootfs.tar.gz $OUTPUT/rootfs_$1.tar.gz
    echo -e "\033[32mYour new rootfs is available:
    - $OUTPUT/rootfs_$1.cpio.gz
    - $OUTPUT/rootfs_$1.tar.gz
    \033[39m"
}


for arg in "$@"
do
    case $arg in
        "defconfig"|"build"|"savedefconfig")
            COMMAND=$arg
            ;;
        "armv7"|"armv6"|"armv5"|"armv4"|"aarch64")
            case $COMMAND in
                "defconfig")
                    defconfig $arg
                    ;;
                "build")
                    prepare_overlay
                    build $arg
                    ;;
                "savedefconfig")
                    savedefconfig $arg
                    ;;
                *)
                    print_help
            esac
            ;;
        *)
            print_help
    esac
done

