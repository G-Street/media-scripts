#!/usr/bin/env bash
# Moomin (1990–1992)

echo -e "\033[1;34m:: \033[0;38m\033[1;38mDownloading episodes\033[0;38m"
mkdir moom
cd moom
youtube-dl --yes-playlist https://www.youtube.com/playlist?list=PLL0kUUHCSZA6VQjBcZ8TJ-tshEMyPsSt6
echo -e "\033[1;34m:: \033[0;38m\033[1;38mDownloading the superior theme\033[0;38m"
cd ..
youtube-dl --extract-audio --audio-format wav -o "superior_intro.%(ext)s" 'https://www.youtube.com/watch?v=BUIpX3XVVb8'
echo -e "\033[1;34m:: \033[0;38m\033[1;38mConstructing fade-out using first verse (as is what is used in the downloaded episodes)\033[0;38m"
< /dev/null ffmpeg -nostdin -i 'superior_intro.wav' -af 'afade=out:st=79:d=5' superior_intro_audio_fade_out.wav # fade out of intro at 79 seconds
< /dev/null ffmpeg -nostdin -i superior_intro_audio_fade_out.wav -c copy -t 81 superior_intro_cut.wav # cut the latter half of the superior intro
echo -e "\033[1;34m:: \033[0;38m\033[1;38mOverlaying the superior theme onto the videos\033[0;38m"
cd moom

for clip in ./*; do
    EXT="$(echo "${clip}" | awk -F'.' '{print $NF}')"
    < /dev/null ffmpeg -nostdin -i "${clip}" -c copy -t 00:01:30 seg1.$EXT # segment the clip at time=90 seconds
    < /dev/null ffmpeg -nostdin -i "${clip}" -c copy -ss 00:01:30 seg2.$EXT # obtain the remainder of the clip
    < /dev/null ffmpeg -nostdin -i seg1.$EXT -i ../superior_intro_cut.wav -c copy -map 0:v:0 -map 1:a:0 new-seg.$EXT # replace audio from the first 90 seconds of the original clip using in.wav
    < /dev/null ffmpeg -nostdin -i new-seg.$EXT -i seg2.$EXT -filter_complex "concat=n=2:v=1:a=1" -vn "${clip%.*}-new.${EXT}" # concatenate them back together; v=1 and a=1 are telling ffmpeg that both files have video and audio; n=2 tells ffmpeg that you are concatenating two files
    rm seg1.$EXT seg2.$EXT new-seg.$EXT # clean up
done

