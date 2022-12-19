#!/usr/bin/env bash

set -e

separator=$1
if [[ -z $separator ]]; then
  separator="\n"
fi

first=true

while IFS= read -r line; 
do
  if [[ $line == '' ]]; then
    continue
  fi

  if [ "$first" = false ]; then
    printf "$separator"
  fi
  first=false

  quoted=${line//\'/\'\\\'\'}
  printf "'%s'" "$quoted"
done

echo ''
