#!/bin/bash

service ssh restart
ldconfig
ln -s /dev/null /dev/raw1394

OPTIND=1
while getopts "db" opt; do
    case $opt in
        d)
            while true; do sleep 1000; done
            ;;
        b)
            /bin/bash
            ;;
    esac
done

shift $((OPTIND-1))


