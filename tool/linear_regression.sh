#!/bin/bash
arg=$1
MAX_FILE_SIZE=$((arg * 1024 * 1024 * 1024))

    #Generate memory access sequence of linear_regression
    cd apps/metis
    ../../pintool/pin -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so -- ./Metis/obj/linear_regression ./Metis/data/lr_40GB.txt -p 8 &
    sleep 20s
    pid_pin=$!
    while :; do
        if ! kill -0 $pid_pin 2>/dev/null; then
            echo "linear regression finished"
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out" 2>/dev/null)
            if [ $? -eq 0 ] && [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_pin
                sleep 1s
                if ! kill -0 $pid_pin 2>/dev/null;then
                    echo "linear regression reach max file size"
                    break
                fi
            fi
            sleep 1s
        fi
    done
    
    mkdir ../../../src/Metis
    mv pinatrace.out ../../../src/Metis/metis.out
    cd ../../
    head -n -1 ../src/Metis/metis.out > temp.out && mv temp.out ../src/Metis/metis.out
