#! /usr/local/bin/bash

EP_COUNTER_LT=0
EP_COUNTER_MM=0
EP_COUNTER_BR=0
EP_COUNTER_GLOB=0
ERROR=false
FILE_EXTENSION="mp4"

find . -type f -iname \*.${FILE_EXTENSION} -print | sort -n | \
{
    while IFS= read -r videofile; do
        
        EP_COUNTER_GLOB=$((EP_COUNTER_GLOB+1))
        TAG="$(echo "${videofile}" | awk -F'[ .]' '{ print $(NF-1) }')"
        YEAR="$(echo "$(dirname "${videofile}")" | awk -F'/' '{ print $2 }')"
        RAW_NAME="$(basename "${videofile}")"
        NAME="$(echo "${RAW_NAME}" | awk -v ext="${FILE_EXTENSION}" -v tag="${TAG}" -F' ' '{ $1=$NF="" } { gsub(/^ +| +$/,"") } { print $0 " - " tag "." ext  }')"
        RANDOM_NUMBER="$(echo "${RAW_NAME}" | awk -F'DVD' '{ print $1 }')"
        
        if [[ "${TAG}" == "LT" ]]
        then
            EP_COUNTER_LT=$((EP_COUNTER_LT+1))
            EP_COUNTER="${EP_COUNTER_LT}"
        elif [[ "${TAG}" == "MM" ]]
        then
            EP_COUNTER_MM=$((EP_COUNTER_MM+1))
            EP_COUNTER="${EP_COUNTER_MM}"
        elif [[ "${TAG}" == "BR" ]]
        then
            EP_COUNTER_BR=$((EP_COUNTER_BR+1))
            EP_COUNTER="${EP_COUNTER_BR}"
        else
            echo "An error occurred in the labelling and episode numbering of ${videofile}."
            ERROR=true
        fi
        
        [ $ERROR ] || mv -v "${videofile}" "./S${YEAR}E${EP_COUNTER_GLOB} - ${NAME}"
        
    done
}
