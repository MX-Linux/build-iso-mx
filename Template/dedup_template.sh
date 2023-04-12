#!/bin/bash

PREFIX=$1
if [[ $PREFIX ]]
then
    PREFIX=${PREFIX}/
fi

if [[ $2 ]]
then
    COMMON_DIR=$2
else
    COMMON_DIR='COMMON'
fi

TMPFILE="/tmp/tmp_dedup_$(date +%s).txt"

for template_dir in ${PREFIX}* ; do if [[ -d $template_dir && $template_dir != ${PREFIX}${COMMON_DIR} ]] ; then
    for common_file in ${PREFIX}${COMMON_DIR}/*.list ; do
        current_file=${template_dir}/$(basename $common_file)
        if [[ -f $current_file ]] ; then
            grep -vxFf $common_file $current_file > $TMPFILE
            mv $TMPFILE $current_file
        fi
    done
fi ; done

