#!/bin/sh

CLIP_LENGTH=10

split_file() {
    FILENAME="$1"
    DURATION_RAW=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILENAME")
    DURATION=$(echo "$DURATION_RAW" | cut -d '.' -f1)
    NUMBER_OF_CLIPS=$((DURATION / CLIP_LENGTH - 1))
    for i in $(seq 0 $NUMBER_OF_CLIPS); do
        echo "$FILENAME,$((i * CLIP_LENGTH)),$CLIP_LENGTH" >> playlist-temp.edl
    done
    LAST=$((DURATION % CLIP_LENGTH))
    LAST_SPARE=$(echo "$DURATION_RAW" | cut -d '.' -f2)
    echo "$FILENAME,$(((NUMBER_OF_CLIPS + 1) * CLIP_LENGTH)),$LAST.$LAST_SPARE" >> playlist-temp.edl
}

for file in * ; do
    if file -i "$file" | grep -q video; then
        split_file "$file"
    fi
done

echo '# mpv EDL v0' > playlist.edl
shuf playlist-temp.edl >> playlist.edl
rm playlist-temp.edl

mpv playlist.edl