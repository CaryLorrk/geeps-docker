#!/bin/bash

# Defaults
NUM_WORKER=4

# Parse arguments
OPTIND=1
OPTERR=0
while getopts ":w:" opt; do
    case $opt in
        p)
            NUM_WORKER="$OPTARG"
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Check cores
NUM=$(($NUM_PS+$NUM_WORKER))
if [[ $(($CORE*$NUM)) > $TOTAL_CORE ]]; then
    echo "Too much core used" >&2
    exit 1
fi

make killall
make rmall

# Create network
docker network create --driver bridge tensorflow

# Run container
PERIOD=50000
QUOTA=$(($PERIOD*$CORE))
mkdir -p $PWD/tensorflow
for i in $(seq 0 $((NUM-1))); do
    if [[ $i == 0 ]]; then
        VOLUME="-v $PWD/tensorflow:/root/tensorflow"
    else
        VOLUME="--volumes-from=tensorflow-0"
    fi
    docker run -d \
        --name tensorflow-$i \
        $VOLUME \
        --network tensorflow \
        -m $MEM \
        --cpu-period ${PERIOD} \
        --cpu-quota ${QUOTA} \
        carylorrk/tensorflow
done

# Create machinefile
truncate -s 0 tensorflow/ps_machinefile
truncate -s 0 tensorflow/worker_machinefile
for i in $(seq 0 $((NUM-1))); do
    IP=`docker inspect -f {{.NetworkSettings.Networks.tensorflow.IPAddress}} tensorflow-$i`
    if [[ $i < $NUM_PS ]]; then
        echo $IP >> tensorflow/ps_machinefile
    else
        echo $IP >> tensorflow/worker_machinefile
    fi
done

for i in $(seq $((NUM-1)) -1 0); do
    docker exec tensorflow-$i /root/tensorflow/server.py --task_index $i &
done

