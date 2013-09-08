#!/bin/bash

# Script which renames photos

OUTPUT_DIR=$OUTPUT_DIR
SIZE_MAX=1000
RESIZE=1024


while getopts "o:r:" opt; do
  case $opt in
    r)
      RESIZE=$OPTARG
      ;;
    o)
      OUTPUT_DIR=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


# Nombre de fichier à taiter
NB_FILES=$(ls -l *.jpg *.JPG *.jpeg 2>/dev/null |wc -l)

# Summary
echo "OUTPUT_DIR=$OUTPUT_DIR"
echo "RESIZE=$RESIZE"
echo "NB_FILES=$NB_FILES"

if [ -d "$OUTPUT_DIR" ]; then
	echo "Output dir ($OUTPUT_DIR) allready exists, remove? (y/N)"
	read c
	if [ "$c" = y ]; then
		rm -rf $OUTPUT_DIR
	else
		exit 0
	fi
fi

# create output dir
mkdir  "$OUTPUT_DIR"

find  -maxdepth 1 -name "*.jpg" -o -name "*.JPG" -o -name "*.jpeg" | while read i
do
	FILESIZE=$(du "$i" | cut -f1)
	SIZE=$(du -h "$i" | cut -f1)
	if [ $FILESIZE -gt $SIZE_MAX ]; then 
		cp "$i" "$OUTPUT_DIR/$i"
		SIZE=$(du -h "$i" | cut -f1)
		SIZE2=$(du -h "$OUTPUT_DIR/$i" | cut -f1)
		echo "Copy $i ($SIZE) into $OUTPUT_DIR/$i ($SIZE2)"
	else
		convert "$i" -resize "${RESIZE}>x${RESIZE}>" "$OUTPUT_DIR/$i"
		SIZE=$(du -h "$i" | cut -f1)
		SIZE2=$(du -h "$OUTPUT_DIR/$i" | cut -f1)
		echo "Resize $i ($SIZE) into $OUTPUT_DIR/$i ($SIZE2)"
	fi
done

# rename
cd $OUTPUT_DIR
find  -maxdepth 1 -name "*.jpg" | while read i
do
	NAME=$(exiftool -TAG -CreateDate "$i" -d "%Y-%m-%d.%Hh%Mmin%Ss" -s -s -s)
	if [ $? -eq 1 -o -z "$NAME" ]; then
		echo "Retrieving creation date failed"
		continue
	fi
	if [ -f "$NAME.jpg" ]; then
		echo "$NAME.jpg allready exits, don't rename $i"
		continue
	fi
	mv "$i" "$NAME.jpg"
	echo "Rename $i into $NAME.jpg"
done


NB_FILES_RENAMED=$(ls -l *.jpg *.JPG 2>/dev/null |wc -l)


# stat
echo ""
echo "$NB_FILES file(s) before resizing"
echo "$NB_FILES_RENAMED file(s) after resizing"





