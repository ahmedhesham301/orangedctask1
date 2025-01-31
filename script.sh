#!/bin/bash

diskWarningThreshold=80
outputFile="system_monitor.log"

while getopts "t:f:" opt; do
  case $opt in
    t) diskWarningThreshold=$OPTARG ;;
    f) outputFile=$OPTARG ;;
    *) echo "Usage: $0 [-t threshold -f filename]" >&2; exit 1 ;;
  esac
done

df| awk -v threshold="$diskWarningThreshold" '/^\/dev/ {print $1"\t"$5; if(($3 / $2) *100 > threshold) print "Warning: " $1 " has less than low free space"}' | tee -a "$outputFile"

top -bn1|awk '/%Cpu/ {print "cpu usage: " $2}' | tee -a "$outputFile"

free -h|awk '/Mem/ {print "used memory:" $3" ""free memory:" $4}' | tee -a "$outputFile"

echo "top 5 memory consuming processes" | tee -a "$outputFile"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | tee -a "$outputFile"