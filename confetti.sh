#!/bin/sh

CLIP_LENGTH=10

split_file() {
	FILENAME="$1"
	printf %s%n "$FILENAME" FILENAME_LENGTH >/dev/null
	DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILENAME" | cut -d '.' -f1)
	NUMBER_OF_CLIPS=$((DURATION / CLIP_LENGTH))
	for i in $(seq 0 $NUMBER_OF_CLIPS); do
		case $i in
		"$NUMBER_OF_CLIPS")
			unset LENGTH
			;;
		*)
			LENGTH=",$CLIP_LENGTH"
			;;
		esac
		echo "%$FILENAME_LENGTH%$FILENAME,$((i * CLIP_LENGTH))$LENGTH" >>confetti-temp.edl
	done
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
