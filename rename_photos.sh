#!/bin/bash

# Script which renames photos

OUTPUT_DIR=$OUTPUT_DIR
DRYRUN=0
SIZE_MAX=1000
RESIZE=1920


while getopts "do:" opt; do
  case $opt in
    d)
      echo "Dry run mode" >&2
      DRYRUN=1
      ;;
    o)
      OUTPUT_DIR=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -d $OUTPUT_DIR ]; then
	echo "Output dir ($OUTPUT_DIR) allready exists!"
	exit 1;
fi

# Nombre de fichier à taiter
NB_FILES=$(ls -l *.jpg *.JPG 2>/dev/null |wc -l)

# create output dir
mkdir -p "$OUTPUT_DIR"

find  -maxdepth 1 -name "*.jpg" -o -name "*.JPG" | while read i
do
	NAME=$(exif -m "$i" | perl -lne 'print "$1-$2-$3_$4.$5.$6" if /Date and Time \(Original\)\t(\d+):(\d+):(\d+) (\d+):(\d+):(\d+)/')
	if [ $? -eq 1 -o -z "$NAME" ]; then
		echo "exif failed, try exiv2..."
		NAME==$(exiv2 -m "$i" | perl -lne 'print "$1-$2-$3_$4.$5.$6" if /Image timestamp : (\d+):(\d+):(\d+) (\d+):(\d+):(\d+)/')
		if [ $? -eq 1 -o -z "$NAME" ]; then
			echo "exiv2 failed, cannot rename $i"
			NAME=$i
		fi
	fi

	FILESIZE=$(du "$i" | cut -f1)
	if [ $FILESIZE -gt $SIZE_MAX ]; then 
		[ $DRYRUN -eq 0 ] && convert "$i" -resize x$RESIZE "$OUTPUT_DIR/$NAME.jpg"
		echo "Resize $i ==> $NAME.jpg"
	else
		[ $DRYRUN -eq 0 ] && cp "$i" "$OUTPUT_DIR/$NAME.jpg"
		echo "Copy $i ==> $NAME.jpg"
	fi
done

NB_FILES_RENAMED=$(cd $OUTPUT_DIR && ls -l *.jpg *.JPG 2>/dev/null |wc -l)


# stat
echo "Output directory: $OUTPUT_DIR"
echo "$NB_FILES file(s) before resizing"
echo "$NB_FILES_RENAMED file(s) after resizing"





