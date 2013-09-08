#!/bin/bash


mkdir -p renamed
find  -maxdepth 1 -name "*.jpg" -o -name "*.JPG" | while read i
do
    NAME=$(exif -m "$i" | perl -lne 'print "$1-$2-$3_$4.$5.$6" if /Date and Time \(Original\)\t(\d+):(\d+):(\d+) (\d+):(\d+):(\d+)/')
    if [ -z "$NAME" ]
    then
        NAME=$i
        echo "Cannot not rename $i"
    fi
    FILESIZE=$(du "$i" | cut -f1)
    if [ $FILESIZE -gt 1000 ]; then 
            convert "$i" -resize x1920 "renamed/$NAME.jpg"
            echo "Resize $i ==> $NAME.jpg"
    else
            cp "$i" "renamed/$NAME.jpg"
            echo "Copy $i ==> $NAME.jpg"
    fi
done





