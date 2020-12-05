#!/bin/bash
# create workspace for catkin - compilation for ros environment

ROS_DEPS="std_msgs rospy roscpp"

print_help() {
    cat << EOF
ROS Package Creator Script

Creates a new ROS package in an existing ROS workspace.

Usage:
 $0 [OPTIONS] WORKSPACE PACKAGE

Options:
 -d     Dependency list for new ROS package. Default: $ROS_DEPS. Valid
        delimiters: ,|;:
 -v     Print out all commands as they are executed
 -h     Print this help and exit

Arguments:
 WORKSPACE      Catkin workspace under which to create new package
 PACKAGE        New package name
EOF
}

while getopts ":vhd:" opt; do
    case ${opt} in
        v) set -x ;;
        h) print_help ; exit 0 ;;
        d) ROS_DEPS="$(echo $OPTARG | sed 's/[,|;:]/ /g')" ;;
        \?) echo "Invalid option -$OPTARG" ; exit 1 ;;
        :) echo "Invalid option -$OPTARG requires an argument" ; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

if [[ "$#" -eq 2 ]]; then
    WS_PATH="$1"
    PKG_NAME="$2"
else
    echo "Need a workspace location and a new package name!" >&2
    print_help
    exit 1
fi

SRC_PATH="$WS_PATH/src"

PKG_FULL_PATH="$WS_PATH/src/$PKG_NAME"

if [[ -e "$PKG_FULL_PATH" ]]; then
    while true; do
        read -p "Project $PKG_NAME exists in workspace $WS_PATH! Remove and replace? [y|n]: " REPLACE
        case $REPLACE in
            y) rm -r $PKG_FULL_PATH ;;
            n) echo "Package $PKG_NAME in workspace $WS_PATH already exists. Nothing to do" ; exit 0 ;;
            *) echo "Unknown option. Try again" ; continue ;;
        esac
        break
    done
fi

pushd $SRC_PATH
catkin_create_pkg "$PKG_NAME" $ROS_DEPS
popd

pushd $WS_PATH
catkin_make
popd

