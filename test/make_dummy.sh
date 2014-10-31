#!/bin/bash

PREFIX_DIR="testdir"

for d in `seq -f "$PREFIX_DIR%03g" 1 10`
do
  mkdir -p "$d"

#  for f in `seq -f "%03g" 1 5`
#  do
#    touch "$d/$f.txt"
#  done

#  # illegal format
#  touch "$d/2.txt"
#  touch "$d/000001.txt"

  for f in `seq 1 20`
  do
    touch "$d/$f.txt"
  done

done
