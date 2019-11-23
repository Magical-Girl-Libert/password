#!/bin/bash
basedir="$(dirname $BASH_SOURCE)"
for file in `find ${basedir} -follow -type f -name '*.profile'`; do
    source $file
done
