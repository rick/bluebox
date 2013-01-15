LENGTH=`/Applications/mplayer2.app/Contents/MacOS/mplayer2 -vc null -vo null -identify -frames 0 "$*" 2>&1 | grep ID_LENGTH | sed 's:^.*=::'`
echo "$LENGTH	$*"
