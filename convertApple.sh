#!/bin/bash

DIRECTORY="/users/flojo/music"
APPLEDIR="$DIRECTORY/apple"
#filetype="flac"


embedArtwork(){
    local file="$1"
    #tageditor
    # https://github.com/Martchus/tageditor

    mp4art -z add "cover.png" "$file"
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
             # ffmpeg -i "$file" -i cover.jpg -c:a libmp3lame -q:a 2
             # -map_metadata 0:s:0 -map 0 -map 1"$OUTPUT"
            ;;
        flac)
             # flac conversion to apple lossless
             echo "Doing FLAC conversion"
             # ffmpeg -i "$file" -c:a alac "$OUTPUT"
             # embedArtwork
             ;;
        *)
            echo "Copying $file"
            ;;
    esac

done

