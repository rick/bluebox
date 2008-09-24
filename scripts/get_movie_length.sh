LENGTH=`/usr/bin/mplayer -vc null -vo null -identify -frames 0 "$*" 2>&1 | grep ID_LENGTH | sed 's:^.*=::'`
echo "$LENGTH	$*"
