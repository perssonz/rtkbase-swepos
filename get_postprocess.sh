#!/bin/bash

# Copyright (C) 2024 Daniel Persson - All Rights Reserved
# You may use, distribute and modify this code under the terms of the MIT
# license.
#
# You should have received a copy of the MIT license with this file. If not,
# please visit https://github.com/perssonz/rtkbase-swepos.

TMP_DIR=/tmp/process_rtk
STATION="0SIB00SWE_S"
USERNAME=
PASSWORD=
RTKBASE_USERNAME="basegnss"
RTKBASE_PASSWORD="basegnss!"
RTKBASE_HOSTNAME="basegnss.local"
RESULT_FILE="positions.txt"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

usage() {
    printf "Usage: $0 -s <station> -u <username> -p <password> --rtkbase-user <rtkbase username> --rtkbase-pass <rtkbase password> --rtkbase-hostname <rtkbase hostname>\n\nRequired:\n\tusername\t\tUsername for Swepos\n\tpassword\t\tPassword for Swepos\nOptional:\n\tstation\t\t\tSwepos station to use as reference [0SIB]\n\trtkbase username\tUsername for RTKBase server [basegnss]\n\trtkbase password\tPassword for RTKBase server [basegnss!]\n\trtkbase hostname\tHostname for RTKBase server [basegnss.local]\n"
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -s|--station)
        STATION="$2"
        shift # past argument
        shift # past value
        ;;
    -u|--user)
        USERNAME="$2"
        shift # past argument
        shift # past value
        ;;
    -p|--pass)
        PASSWORD="$2"
        shift # past argument
        shift # past value
        ;;
    --rtkbase-user)
        RTKBASE_USERNAME="$2"
        shift # past argument
        shift # past value
        ;;
    --rtkbase-pass)
        RTKBASE_PASSWORD="$2"
        shift # past argument
        shift # past value
        ;;
    --rtkbase-hostname)
        RTKBASE_HOSTNAME="$2"
        shift # past argument
        shift # past value
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
    esac
done

if [ -z $USERNAME ]; then
    usage
    exit 1
fi

if [ -z $PASSWORD ]; then
    usage
    exit 1
fi

if ! [ -d $SCRIPT_DIR/data ]; then
    mkdir $SCRIPT_DIR/data
fi

# Get observation files from rtkbase
rsync -ratlvz --rsh="/usr/bin/sshpass -p $RTKBASE_PASSWORD ssh -o StrictHostKeyChecking=no -l $RTKBASE_USERNAME" --info=progress2 --info=name0 --remove-source-files $RTKBASE_USERNAME@$RTKBASE_HOSTNAME:/home/basegnss/rtkbase/data/*.zip $SCRIPT_DIR/data
rv=$?

if [ $rv == 23 ]; then
    echo "No files to get."
elif ! [ $rv == 0 ]; then
    echo "Could not get observations from $RTKBASE_HOSTNAME."
    exit 1
fi

if [ -d $TMP_DIR ]; then
    rm -rf $TMP_DIR
fi

mkdir $TMP_DIR

for filename in data/*.zip; do
    # Get date from filename
    kREGEX_DATE='^.*([0-9]{4}[-/][0-9]{2}[-/][0-9]{2})'
    [[ $filename =~ $kREGEX_DATE ]]
    if [ $? == 0 ]; then
        date=${BASH_REMATCH[1]}
    else
        echo "Unknown file name format, supposed to contain date."
        exit 1
    fi

    # Skip files that have already been processed
    prev_result_for_date=$(grep -c $date $RESULT_FILE)
    if [ $prev_result_for_date -gt 0 ]; then
        continue
    fi

    # Unpack observations to temp location
    unzip $filename -d $TMP_DIR

    pushd $TMP_DIR

    # Convert date to day of year and get Swepos reference statiion measurements for that day
    day_of_year=$(date -d $date +%j)
    year=$(date -d $date +%Y)
    wget "ftp://$USERNAME:$pass@swepos-open.lantmateriet.se/rinex3/$year/$day_of_year/$STATION*.gz"
    gunzip $STATION*

    # Convert files to correct formats and run rtklib
    observations_base=$(find -type f -name '*.crx')
    nav_base=$(find -type f -name '*_GN.rnx')
    observations_rover=$(find -type f -name '*.ubx')
    convbin -ti 30.0 $observations_rover
    observations_rover_converted="${observations_rover%.*}.obs"
    crx2rnx $observations_base
    observations_base_converted="${observations_base%.*}.rnx"
    rnx2rtkp -p 3 $observations_rover_converted $observations_base_converted $nav_base -r 3442037.2736 870801.0703 5280932.1136 -o pos.txt

    # Get final position from file
    pos=$(tail -n 1 pos.txt)

    popd

    rm -rf $TMP_DIR/*

    echo "$date: $pos" >> $RESULT_FILE
done

rm -rf $TMP_DIR