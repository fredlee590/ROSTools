#!/bin/bash
# create workspace for catkin - compilation for ros environment

WS_NAME=catkin_ws

print_help() {
    cat << EOF
ROS Workspace Creator Script

Creates a new ROS workspace under a new named directory.

Usage:
 $0 [OPTIONS] WORKSPACE_LOC

Options:
 -w     Workspace name. Defaults to $WS_NAME
 -v     Print out all commands as they are executed
 -h     Print this help and exit

Arguments:
 WORKSPACE_LOC      Directory under which to create new catkin workspace. May
                    include new, unique name.
EOF
}

while getopts ":vhw:" opt; do 
    case ${opt} in
        v) set -x ;;
        h) print_help ; exit 0 ;;
        w) WS_NAME="$OPTARG" ;;
        \?) echo "Invalid option -$OPTARG" ; exit 1 ;;
        :) echo "Invalid option -$OPTARG requires an argument" ; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

if [[ "$#" -eq 1 ]]; then
    WS_PATH="$1"
else
    echo "Need a workspace location!" >&2
    print_help
    exit 1
fi

WS_FULL_PATH="$WS_PATH/$WS_NAME"

if [[ -e "$WS_FULL_PATH" ]]; then
    while true; do
        read -p "Workspace $WS_PATH exists! Remove and replace? [y|n]: " REPLACE
        case $REPLACE in
            y) rm -r $WS_PATH ;;
            n) echo "Workspace $WS_FULL_PATH already exists. Nothing to do" ; exit 0 ;;
            *) echo "Unknown option. Try again" ; continue ;;
        esac
        break
    done
fi

mkdir -p $WS_FULL_PATH/src
cd $WS_FULL_PATH
catkin_make

source devel/setup.bash

