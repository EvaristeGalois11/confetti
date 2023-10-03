#!/bin/sh

CLIP_LENGTH=10

split_file() {
	FILENAME="$1"
	DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILENAME" | cut -d '.' -f1)
	NUMBER_OF_CLIPS=$((DURATION / CLIP_LENGTH - 1))
	for i in $(seq 0 $NUMBER_OF_CLIPS); do
		echo "$FILENAME,$((i * CLIP_LENGTH)),$CLIP_LENGTH" >>confetti-temp.edl
	done
	echo "$FILENAME,$(((NUMBER_OF_CLIPS + 1) * CLIP_LENGTH))" >>confetti-temp.edl
}

for file in *; do
	if file -i "$file" | grep -q video; then
		split_file "$file"
	fi
done

echo '# mpv EDL v0' >confetti.edl
shuf confetti-temp.edl >>confetti.edl
rm confetti-temp.edl

mpv confetti.edl
