sed 's:^[^A-Z]*::' | /art/scripts/wrap 5000 | sed 's:\([\.!?]\+\):\1\n:g' | sed 's:^[ 	]*::' | perl -ne 'print unless length($_) > 100'
