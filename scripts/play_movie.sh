/Applications/mplayer2.app/Contents/MacOS/mplayer2 -quiet -nomouseinput -noconsolecontrols -vo gl -vf scale=800:600:1 -fs -ss $2 -nosub "$1" &
sleep $3
killall mplayer2
