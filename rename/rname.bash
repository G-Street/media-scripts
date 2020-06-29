#! /bin/bash

FILES="*.mkv"
REGEX="s01e([0-9][0-9])"

SERIES_NAME="Fullmetal Alchemist Brotherhood"
SEASON="01"

for F in $FILES
do
    if [[ $F =~ $REGEX ]]
    then
        EPISODE="${BASH_REMATCH[1]}"
        NEW_NAME="${SERIES_NAME} - S${SEASON}E${EPISODE}.mkv"
        echo "$NEW_NAME"
        mv "$F" "$NEW_NAME"
    fi
done
