#!/bin/bash
#= settings =====================================
ROOT=/share/Public/automation/replaygain
OUTDIR=gained
SKIPEXISTING=false
#=================================================
export LOGFILE=${OUTDIR}/log.txt
LOCKFILE=/var/lock/rsgain.lock
if test -f "$LOCKFILE"; then
    exit 0
fi

cd "$ROOT" ||  exit 1
touch "$LOCKFILE"
CONVERTED=false

SAVEIFS=$IFS
IFS=$'\n'

sekey=""
if  [[ $SKIPEXISTING = true ]]
then
    sekey="--skip-existing"
fi


while read -r i
do
    CONVERTED=true
    mkdir -p ./${OUTDIR}$(dirname "${i:1}")
    echo "$i" >> "$LOGFILE"
    OUTFILE="./${OUTDIR}${i:1}" # drop leading dot (.) in filename $i
    mv -f "$i" "$OUTFILE"
    if [[ $OUTFILE =~ .*\.(ogg|mp3|flac)$  ]]
    then
        echo "$OUTFILE (selected audio, rsgain)" >> "$LOGFILE"
        rsgain custom  --output --clip-mode=a --true-peak $sekey  "$OUTFILE" |  sed 's/^/    /' >> "$LOGFILE"
    else
        echo "$OUTFILE (not selected audio, just moving)" >> "$LOGFILE"
    fi
    echo "" >> "$LOGFILE"
done < <(find . -type f -not -path "./${OUTDIR}/*" -mmin +1 )
#done < <(find . -type f -not -path "./${OUTDIR}/*" \( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.ogg'  \) -mmin +1 )


sync

if [[ $CONVERTED == true ]]
then
    echo Remove empty dirs >> "$LOGFILE"
    #chmod  a+rw -R "./${MP3DIR}"
    find . -type d -empty -delete
    echo "Complete!" >> "$LOGFILE"
fi
rm "$LOCKFILE"
IFS=$SAVEIFS
