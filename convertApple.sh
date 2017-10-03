#!/bin/bash

DIRECTORY="/users/flojo/music/"
APPLEDIR="$DIRECTORY/apple"
#filetype="flac"

findArtwork(){
    # echo "Find in: $1"
    # find artwork and return first found
    find "$1" -type f -iname 'cover.jpg' -o -iname 'cover.png' -o -iname 'front.jpg' -o -iname 'front.png' | head -1
}

embedArtwork(){
    #tageditor
    # https://github.com/Martchus/tageditor
    
    local file="$1"
    local targetfile="$2"
    local COVER=$(findArtwork $(dirname "$file"))
    # echo "Cover: $COVER"
    if [ -n "$COVER" ]; then
        if [ -e "$targetfile" ]; then
            mp4art -z --add "$COVER" "$targetfile"
        else
            echo "Error while embedding Art. File: $targetfile"
        fi
    else
        echo "No coverart found"
    fi
}

space2Underscore(){
    mv "$1" "${1// /_}";
}

### main loop ###

# find "$directory" -type f -name "*.$filetype" -print0 | while IFS= read -r -d '' file; do
find "$DIRECTORY" -type f -print0 | while IFS= read -r -d '' file; do
    PARENT=$(dirname "$file")
    FILESTUB=$(basename "$file")
    FILETYPE=${file##*.}
    FILEEXT="m4a"
    # ALOSSLESS="$PARENT/apple"
    ALOSSLESS="$APPLEDIR"
    SUBDIR="${PARENT#$DIRECTORY}"       #cut the root directory from front
    OUTPUTDIR="$ALOSSLESS/$SUBDIR"
    OUTPUT="$OUTPUTDIR/${FILESTUB%.*}.$FILEEXT"
    printf '%s\n' "$file"
    echo "Filetype: $FILETYPE"
    echo "Parent: $PARENT"
    echo "New: $OUTPUT"
#    check if a directory doesn't exist:
    if [ ! -d "$OUTPUTDIR" ]; then
      # Control will enter here if $DIRECTORY doesn't exist.
      echo "Creating Directory $OUTPUTDIR"
      mkdir -p "$OUTPUTDIR" 2> /dev/null
    fi
     # ffmpeg -i "$name" -ab 128k -map_metadata 0:s:0 -id3v2_version 3 -write_id3v1 1 "${name/.ogg/.mp3}"
    case "$FILETYPE" in
        ogg)
             # Ogg need map_metadata
             echo "Doing OGG to MP3 conversion"
             # ffmpeg -i "$file" -i cover.jpg -c:a libmp3lame -q:a 2 -map_metadata 0:s:0 -map 0 -map 1"$OUTPUT"
            ;;
        flac)
             # flac conversion to apple lossless
             echo "Doing FLAC conversion"
             # ffmpeg -i "$file" -c:a alac "$OUTPUT"
             echo "Adding Coverart"
             embedArtwork "$file" "$OUTPUT"
             ;;
        *)
            echo "Copying $file"
            # rsync -az --exclude ".DS_Store" "$file" "$OUTPUTDIR"
            ;;
    esac

done

