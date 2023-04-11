#!/bin/bash
# Converts files from a directory, retaining the directory structure and files not to be converted.
# Deletes the original files!
# ffmpeg is required for conversion, and rsgain for replaygain tags

#= settings =====================================
ROOT=/share/Public/automation/2mp3
OUTDIR=MP3
REPLAYGAIN=true
#=================================================
export LOGFILE=${OUTDIR}/log.txt
LOCKFILE=/var/lock/2mp3.lock
if test -f "$LOCKFILE"; then
    exit 0
fi

cd "$ROOT" ||  exit 1
touch "$LOCKFILE"
CONVERTED=false

SAVEIFS=$IFS
IFS=$'\n'

while read i
do
    CONVERTED=true
    mkdir -p ./${OUTDIR}$(dirname "${i:1}")
    echo "$i" >> "$LOGFILE"

    if [[ $i =~ .*\.(ogg|flac)$ ]]
    then
        len=$(($(echo   ${BASH_REMATCH[1]} |  awk '{print length}')+1))
        OUTFILE="./${OUTDIR}${i:1:-${len}}.mp3"
        ffmpeg -y -hide_banner -loglevel error  -nostdin -i "$i" -vn -ar 44100 -ac 2 -q:a 2 -map_metadata 0  "$OUTFILE"  && rm "$i" && echo "Converted to $OUTFILE and removed" >> "$LOGFILE"
        if [[ $REPLAYGAIN = true ]]
        then
            rsgain custom  --output --clip-mode=a --true-peak  "$OUTFILE" |  sed 's/^/    /' >> "$LOGFILE"
        fi
    else
        OUTFILE="./${OUTDIR}${i:1}" # drop leading dot (.) in filename $i
        mv -f "$i" "$OUTFILE"
        echo "Moved (not converted) to $OUTFILE" >> "$LOGFILE"
    fi

    echo "" >> "$LOGFILE"
done < <(find . -type f -not -path "./${OUTDIR}/*" -mmin +1)

if [[ $CONVERTED == true ]]
then
    echo Remove empty dirs >> "$LOGFILE"
    #chmod  a+rw -R "./${OUTDIR}"
    find . -type d -empty -delete
    echo "Complete!" >> "$LOGFILE"
fi
rm "$LOCKFILE"
IFS=$SAVEIFS
