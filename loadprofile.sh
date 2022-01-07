#!/bin/bash
shopt -s expand_aliases
alias passinfoshow='passinfo.get'
basedir="$(dirname $BASH_SOURCE)"
for file in `find ${basedir} -follow -type f -name '*.profile'`; do
    source $file
done
