#!/bin/sh

CLIP_LENGTH=10

function split_file() {
    FILENAME="$1"
    DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILENAME" | cut -d '.' -f1)
    NUMBER_OF_CLIPS=$(($DURATION / $CLIP_LENGTH + 1))
    for (( i = 0; i < $NUMBER_OF_CLIPS; i++ )); do
        echo "$FILENAME,$((i * CLIP_LENGTH)),$CLIP_LENGTH" >> playlist-temp.edl
    done
}

for file in * ; do
    if file -i $file | grep -q video; then
        split_file "$file"
    fi
done

echo '# mpv EDL v0' > playlist.edl
shuf playlist-temp.edl >> playlist.edl
rm playlist-temp.edl

mpv playlist.edl