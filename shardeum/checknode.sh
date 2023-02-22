#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
DELAY=100 ##in minutes
status="stopped"
##################
for (( ;; )); do
        # do something here before countdown
        #sudo echo "hello test restart"
        #service celestia-appd restart
        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
        # do something here after countdown
        #service celestia-appd restart
        current=$(docker exec shardeum-dashboard operator-cli status | grep 'state: ' | awk '{print $2}')
        if [ "$current" == "$status" ]; then
        echo "START SHARDEUM"
        #docker exec shardeum-dashboard operator-cli start
        else
        echo "no problem"
        fi
done
