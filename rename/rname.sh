#! /usr/local/bin/bash


start=$(python3 -c 'import time; print(time.time())')

### Pokémon
pokemon() {
    for i in *
    do
        
        # EPISODE="$(echo "${i}" | awk -F' ' '{ print $5 }')"
        # EXTENSION="$(echo "${i}" | awk -F'.' '{ print $NF }')"
        # TITLE="$(echo "${i}" | awk -F' ' $'{ for(i=7;i<=NF-4;i++){out=out" "$i}; print out }')"
        # echo mv -v "${i}" "Pokémon - S04E${EPISODE} -${TITLE}.${EXTENSION}"
        
        
        # EPISODE="$(echo "${i}" | awk -F'_' '{ print $5 }')"
        # TITLE="$(echo "${i}" | awk -F'_' $'{ for(i=6;i<=NF;i++){out=out" "$i}; print out }')"
        # echo mv -v "${i}" "Pokémon - S05E${EPISODE}${TITLE}"
        
        # EPISODE="$(echo "${i}" | awk -F' ' '{ print $3 }' | sed 's/EP//g')"
        # TITLE="$(echo "${i}" | awk -F' ' $'{ for(i=5;i<=NF;i++){out=out" "$i}; print out }')"
        # echo mv -v "${i}" "Pokémon - S06E${EPISODE} -${TITLE}"
        
        # EPISODE="$(echo "${i}" | awk -F' ' '{ print $3 }' | sed 's/EP//g')"
        # EXTENSION="$(echo "${i}" | awk -F'.' '{ print $NF }')"
        # TITLE="$(echo "${i}" | awk -F' ' $'{ for(i=5;i<=NF-4;i++){out=out" "$i}; print out }')"
        # echo mv -v "${i}" "Pokémon - S07E${EPISODE} -${TITLE}.${EXTENSION}"
        
        # EPISODE="$(echo "${i}" | awk -F' ' '{ print $3 }' | sed 's/EP//g')"
        # EXTENSION="$(echo "${i}" | awk -F'.' '{ print $NF }')"
        # TITLE="$(echo "${i}" | awk -F' ' $'{ for(i=5;i<=NF;i++){out=out" "$i}; print out }' | sed 's/Salman Sk Silver RG//g' | awk -F' ' '{ $NF=""; gsub(/^ +| +$/,""); print $0 }')"
        # echo mv -v "${i}" "Pokémon - S08E${EPISODE} - ${TITLE}.${EXTENSION}"
        
        # EPISODE="$(echo "${i}" | awk -F' ' '{ print $1 }')"
        # EXTENSION="$(echo "${i}" | awk -F'.' '{ print $NF }')"
        # TITLE="$(echo "${i}" | awk -F' ' $'{ for(i=3;i<=NF-4;i++){out=out" "$i}; print out }')"
        # mv -v "${i}" "Pokémon - S09E${EPISODE} -${TITLE}.${EXTENSION}"
        :
        
    done
}


### One Piece

onepiece() {
    # Define array globally (using declare.  If I want to define within the scope of a function, I will use local).
    unset infoArray
    declare -A infoArray


    # read episodes file and parse into array
    while read -r episodeinfo
    do

    # if [[ ${episodeinfo} =~ ^[[:digit:]] ]]
    if echo ${episodeinfo} | grep -e '^Episode [[:digit:]]' > /dev/null
    then

        EPISODE_NUMBER="$(echo "${episodeinfo}" | awk -F' ' '{ gsub("^Episode ","",$0); printf "%04d\n", $1 }')"
        EPISODE_NAME="$(echo "${episodeinfo}" | awk -F' ' $'{ for(i=3;i<=NF;i++){out=out" "$i}; print out }' | sed 's/"//g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        
        #Construct array
        infoArray["${EPISODE_NUMBER}"]="${EPISODE_NAME}"

    fi

    done < "Episode List.txt"


    # parse video files
    find . -type f \( -iname \*.mkv -o -iname \*.mp4 \) -print | \
    while read -r videofile
    do
        
        # VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ print $1 }' | sed 's|^\./OP-||g' |  awk '{printf "%04d\n", $1}')"
        # VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ gsub("^./OP-","",$1); printf "%04d\n", $1 }')"
        VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ printf "%04d\n", $3 }')"
        
        for key in "${!infoArray[@]}"
        do
        
            if [[ "${key}" == "${VIDEO_NUMBER}" ]]
            then
                
                EXTENSION="$(echo "${videofile}" | awk -F'.' '{ print $NF }')"
                
                mv -v "${videofile}" "One Piece - S17E${key} - ${infoArray[$key]}.${EXTENSION}"
                
            fi
        
        done
        
    done
}
    
    

twopiece() {
    
    find . -iname \*.mp4 -print | \
    while read -r videofile
    do
        
        EPISODE_NUMBER="$(echo "${videofile}" | awk -F'.' '{ print $2 }' | sed 's|/||g' |  awk '{printf "%04d\n", $0}')"
        EPISODE_NUMBER_MINUS_PADDING="$(echo "${videofile}" | awk -F'.' '{ print $2 }' | sed 's|/||g')"
        EXTENSION="$(echo "${videofile}" | awk -F'.' '{ print $NF }')"
        EPISODE_NAME="$(echo "${videofile}" | awk -F' ' $'{ for(i=2;i<=NF;i++){out=out" "$i}; print out }' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        EPISODE_NAME_MINUS_EXTENSION="$(echo ${EPISODE_NAME} | awk -F'.' '{ $NF=""; print $0 }')"
        PROPER_EPISODE_NAME_WITH_EXTENSION="$(echo "${EPISODE_NAME}" | sed 's/ - Part [[:digit:]]\(.mp4\)$/\1/g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        PROPER_EPISODE_NAME_MINUS_EXTENSION="$(echo "${PROPER_EPISODE_NAME_WITH_EXTENSION}" | awk -F'.' '{ $NF=""; print $0 }' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        
        # echo "Episode ${EPISODE_NUMBER_MINUS_PADDING}: \"${PROPER_EPISODE_NAME_MINUS_EXTENSION}\"" >> "/Users/jakeireland/Desktop/Episode List 15.txt"
        mv -v "${videofile}" "One Piece - S15E${EPISODE_NUMBER} - ${PROPER_EPISODE_NAME_WITH_EXTENSION}"
        
    done
    
}


threepiece() {
    
    
    # Define array globally (using declare.  If I want to define within the scope of a function, I will use local).
    unset infoArray
    declare -A infoArray


    # read episodes file and parse into array
    while read -r episodeinfo
    do

    # if [[ ${episodeinfo} =~ ^[[:digit:]] ]]
    if echo ${episodeinfo} | grep -e '^Episode [[:digit:]]' > /dev/null
    then

        EPISODE_NUMBER="$(echo "${episodeinfo}" | awk -F' ' '{ gsub("^Episode ","",$0); printf "%04d\n", $1 }')"
        EPISODE_NAME="$(echo "${episodeinfo}" | awk -F' ' $'{ for(i=3;i<=NF;i++){out=out" "$i}; print out }' | sed 's/"//g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        
        #Construct array
        infoArray["${EPISODE_NUMBER}"]="${EPISODE_NAME}"

    fi

done < "/Users/jakeireland/Desktop/Episode List 15.txt"


    # parse video files
    find . -type f \( -iname \*.mkv -o -iname \*.mp4 \) -print | \
    while read -r videofile
    do
        
        # VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ print $1 }' | sed 's|^\./OP-||g' |  awk '{printf "%04d\n", $1}')"
        # VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ gsub("^./OP-","",$1); printf "%04d\n", $1 }')"
        VIDEO_NUMBER="$(echo "${videofile}" | awk -F' ' '{ printf "%04d\n", $5 }')"
        for key in "${!infoArray[@]}"
        do
            if [[ "${key}" == "${VIDEO_NUMBER}" ]]
            then
                
                EXTENSION="$(echo "${videofile}" | awk -F'.' '{ print $NF }')"
                
                mv -v "${videofile}" "One Piece - S15E${key} - ${infoArray[$key]}.${EXTENSION}"
                
            fi
        
        done
        
    done
    
}

threepiece



end=$(python3 -c 'import time; print(time.time())')
runtime=$(echo "( $end - $start ) / 60" | bc -l )

echo -e "\u001b[1;34m++++++ Finished renaming in $runtime minutes at $(date) ++++++\u001b[0;38m"
