#!/usr/bin/perl -w

use Time::HiRes qw(usleep);
use Device::SerialPort;
use FileHandle;

#
#  piece - engine to run a blackbox
#
#  Rick Bradley (rick@rickbradley.com)
#  All rights reserved.
#

use strict;
use vars qw($states $me $switch $mine $port %bits $state $DEBUG $OPT $PRINTER $pid $INTRO $BUFFER);

# actually print to the line printer?
$PRINTER = 1;
$INTRO = 1;

# which button states trigger which events?
$states = {	
	'left' => [ \&fixed_jazz, \&poetry ],
	'right' => [ \&random_jazz, \&spoken_word ],
};

# which serial port bits correspond to which switches
%bits = (
	'left' => 64,
	'right' => 32,
	);

# figure out what our actions are
$me = shift(@ARGV) or die "$0 <switch>\n";
$mine = $states->{$me} or die "$0 <switch>\n";

# play a startup sound
if ($INTRO) {
	if ('left' eq $me) {
		play_mp3('/root/intro.mp3');	
		sleep 10
	} else {
		sleep 20;
	}
}

$port = new Device::SerialPort('/dev/ttyS0') or die "crapped out!: $!\n";

# handle button events
while (1) {
	$state = get_button_state($me);
	&{$mine->[$state]}($state);
}


sub fixed_jazz {
	my $state = shift;
	my ($path, $list, $time, $start, $song, $sleep, $i);
	$path = '/home/rick/sounds/blue_train/';
	$list = get_mp3s($path);
	$song = $list->[int(rand(scalar(@{$list})))];

	$time = int(rand(140))+40;	# max duration to play this piece

	$start = time();
	while (time()-$start < $time) {	
		play_mp3($song);
		if ($state != get_button_state($me)) {
			return;
		}
	}

	$sleep = int(rand(45))-5;		# time to sleep (shifted)
	$sleep = $sleep < 0 ? 0 : $sleep;

	print STDERR "Sleeping [$sleep]\n";
	for ($i = 0; $i < $sleep; $i++) {
		if ($state != get_button_state($me)) {
			return;
		}
		sleep 1;
	}
}


sub random_jazz {
	my $state = shift;
	my ($path, $list, $sleep, $i);
	print STDERR "RANDOM JAZZ\n";
	$path = '/home/rick/sounds/blue_train/';
	$list = get_mp3s($path);
	play_mp3($list->[rand(scalar(@{$list}))]);
	$sleep = int(rand(12))-5;		# time to sleep (shifted)
	$sleep = $sleep < 0 ? 0 : $sleep;

	print STDERR "Sleeping [$sleep]\n";
	for ($i = 0; $i < $sleep; $i++) {
		if ($state != get_button_state($me)) {
			return;
		}
		sleep 1;
	}
}


sub spoken_word {
	my $state = shift;

	if (int(rand(4)) == 0) {
		spoken_word_repeat($state);
	} else {
		spoken_word_once($state);
	}
}

sub spoken_word_once {
	my $state = shift;
	my ($path, $list, $sleep, $time, $intra, $i, $start, $song);

	if (int(rand(10))<3) {
		$path = '/home/rick/sounds/spoken/silver/';
	} else {
		$path = '/home/rick/sounds/spoken/word/';
	}

	print STDERR "ONCE spoken_word\n";
	$list = get_mp3s($path);
	$song = $list->[rand(scalar(@{$list}))];
	$sleep = int(rand(50))-10;		# time to sleep (shifted) - between pieces
	$sleep = $sleep < 0 ? 0 : $sleep;

	play_mp3($song);
	if ($state != get_button_state($me)) {
		return;
	}

	print STDERR "SLEEP [$sleep]\n";
	for ($i = 0; $i < $sleep; $i++) {
		if ($state != get_button_state($me)) {
			return;
		}
		sleep 1;
	}
}

sub spoken_word_repeat {
	my $state = shift;
	my ($path, $list, $sleep, $time, $intra, $i, $start, $song);

	print STDERR "REPEATED spoken_word\n";

	if (int(rand(10))<2) {
		$path = '/home/rick/sounds/spoken/silver/';
	} else {
		$path = '/home/rick/sounds/spoken/word/';
	}

	$list = get_mp3s($path);
	$song = $list->[rand(scalar(@{$list}))];
	$sleep = int(rand(50))-10;		# time to sleep (shifted) - between pieces
	$sleep = $sleep < 0 ? 0 : $sleep;
	$intra = int(rand(25))-4;		# time to sleep (shifted) - between pieces
	$intra = $intra < 0 ? 0 : $intra;

	$time = int(rand(90)); 	# max duration to repeat this piece
	print "REPEAT DURATION [$time]\n";
	$start = time();
	while (time()-$start < $time) {	
		play_mp3($song);
		if ($state != get_button_state($me)) {
			return;
		}

		print STDERR "sleeping [$intra] seconds\n";
		for ($i = 0; $i < $intra; $i++) {
			if ($state != get_button_state($me)) {
				return;
			}
			sleep 1;
		}
	}
	

	print STDERR "sleeping [$sleep] seconds";
	for ($i = 0; $i < $sleep; $i++) {
		if ($state != get_button_state($me)) {
			return;
		}
		sleep 1;
	}
}


# poetry print buffer
sub RESET {
	$BUFFER = '';
}
sub PUSH {
	$BUFFER .= shift;
}
sub GET {
	my $buff = $BUFFER;
	RESET();
	$buff;
}

# print a poem
sub poetry {
	my ($rand, $line, $ref, $word, $done, $i, $sleep, $text);
	$OPT = pick_poem_style();

	if ($PRINTER or $OPT->{'say'}) {
		if ($OPT->{'say'}) {
			open (PRINTER, "| /usr/bin/esddsp /usr/bin/festival --tts") or do {
				print STDERR "Couldn't run festival under esddsp:  $!\n";
				return;
			};
		} else {
		open(PRINTER, "> /dev/lp0") or do {
			print STDERR "Couldn't open the printer: $!\n";
			return;
		}; 
		}
	} else {
		*PRINTER=*STDOUT;
	}

	print PRINTER "\n" x (int(rand(12))+2);

	$OPT->{'source'} = '/home/rick/all.sorted';
	$OPT->{'line_count'} = 50979822;
	$OPT->{'line_length'} = int(((stat($OPT->{'source'}))[7])/$OPT->{'line_count'});

	# get a handle for this file
	$ref = make_handle($OPT->{'source'}, $OPT->{'line_count'}, $OPT->{'line_length'});

	if (not $OPT->{'topic'}) {
    		# choose a first line like that provided
    		$line = get_word_line($ref, $OPT->{'topic'}, word_count($OPT->{'topic'}));
	} else {
		# choose a random first line
		$rand = int(rand($OPT->{'line_count'}));
		$line = fetch_line($ref, $rand);
	}

	# write a poem
	$done = 0;
	while (! $done) {
		# display line
		($done, $line) = display_line($line);

		# find link word(s)
		$word = last_word($line, $OPT->{'link'});
		print "                                            word [$word]\n" if $DEBUG;

		# get next line
		$line = get_word_line($ref, $word, $OPT->{'link'});
	}

	# cleanup
	close_handle($ref);

	# now, retrieve the ready-to-print text.
	$text = GET();

	# end with a clean sentence
	$text = trunc($text);

	# stagger text if indicated
	$text = stagger($text) if $OPT->{'staggered'};

	# dump to printer
	print PRINTER "$text\n";

	close(PRINTER) if $PRINTER or $OPT->{'say'};

	$sleep = int(rand(40))+10;		# time to sleep (shifted)

	for ($i = 0; $i < $sleep; $i++) {
		if ($state != get_button_state($me)) {
			return;
		}
		sleep 1;
	}
}

sub trunc {
	my $text = shift;
	$text =~ s:\n:@#@%:g;
	$text =~ s/([.?!])[^.?!]*$/$1/;
	$text =~ s:@#@%:\n:g;
	$text;
}

sub stagger {
	my $text = shift;
	my ($pick, $current);

	$pick = int(rand(5)) ? 1 : 0;

	$text = join ("\n", map {
		if ($pick) {
			(' ' x (int(rand(12))+1)).$_;
		} else {
			$current .= (' ' x (int(rand(3))));
			$current . $_;
			}
	} split("\n", $text));

	$text;
}

sub pick_poem_style {	
	my ($pick, $opt);

	# how many words wide is a line?
	$opt->{'width'} = int(rand(5))+1;

	# get our eecummings lower-case style on?
	$opt->{'lower'} = (int(rand(5)) == 0) ? 1 : 0;

	# should we insert dashes, as some poets are wont to do?
	$opt->{'dashes'} = (int(rand(5)) == 0) ? 1 : 0;

	# how many lines in this poem?
	$opt->{'lines'} = int(rand(20))+6;

	# line break character
	$opt->{'break'} = "\n";

	# how many words to link from one line to the next
	$opt->{'link'} = 1;

	# poem topic
	$opt->{'topic'} = '';

	# do we punctuate?
	$opt->{'punct'} = (int(rand(10)) == 0) ? 0 : 1;

	# stanza length
	$opt->{'stanza'} = (int(rand(5)) == 0) ? 4 : $opt->{'stanza'};

	# stagger poem spacing horizontally?
	$opt->{'staggered'} = int(rand(3)) == 0 ? 1 : 0;

	# flush our buffers?  (this is a scoreboarding flag, actually)
	$opt->{'doflush'} = 0;

	# do we flush repeated words?  leaving this off gives a gertrude stein feel
	$opt->{'flush'} ||= int(rand(9)) == 0 ? 0 : 1;

	# say the poem rather than print it?
	$opt->{'say'} = int(rand(4)) == 0 ? 1 : 0;
	$opt->{'break'} = ' ' if $opt->{'say'};

	$opt;
}

sub get_button_state {
	my $me = shift;
	my ($status);
	$status = $port->modemlines();
	($status & $bits{$me}) ? 1 : 0;
}


# play an mp3 song
sub play_mp3 {
	my $song = shift;
	system('/usr/bin/mpg123-esd', '-T', $song);
}

# find all mp3 files below $path
sub get_mp3s {
	my $path = shift;
	my ($file, $full, $result);

	opendir(DIR, "$path") or do {
		print STDERR "could not read path [$path]: $!\n";
		return;
	};

	$result = [];
	foreach $file (readdir(DIR)) {
		next if $file =~ /^\./;
		if (-d "$path/$file") {
			# recurse on directories
			my $recurse = get_mp3s("$path/$file");
			push @{$result}, @{$recurse} if $recurse;
		} else {
			push @{$result}, "$path/$file";	
		}
	}
	print STDERR "Found [".(scalar(@{$result}))."] mp3s under [$path]\n";
	
	$result;
}


# display a line of a poem
sub display_line {
    my $line = shift;
    my $finish = shift || 0;
    my ($stanza, $lines);

    # grab counters
    $stanza = $OPT->{'stanzacount'} || 0;
    $lines = $OPT->{'linecount'} || 0;

    # post-process line
    $line = lc($line) if $OPT->{'lower'};
    $line = strip_punct($line) if not $OPT->{'punct'};
    $line = add_dashes($line) if $OPT->{'dashes'};

    if ($OPT->{'width'}) {
	# update buffer
	$line =~ s/^\s+//;
	$OPT->{'buffer'} = '' unless exists $OPT->{'buffer'};
	$OPT->{'buffer'} .= ' ' unless '' eq $OPT->{'buffer'};
	$OPT->{'buffer'} .= $line; 

	# time already printed linked words
	$OPT->{'buffer'} = strip_first_word($OPT->{'buffer'}, $OPT->{'link'}) 
	    if ($OPT->{'flush'} and $OPT->{'link'} and $OPT->{'doflush'});

	# print buffer lines until underflow
	while (word_count($OPT->{'buffer'}) > $OPT->{'width'}) {
	    $line = get_first_word($OPT->{'buffer'}, $OPT->{'width'});
	    PUSH("$line".$OPT->{'break'});
	    return (1, '') if (++$lines > $OPT->{'lines'});

	    # do stanza breaks
	    PUSH($OPT->{'break'}) if $OPT->{'stanza'} and (!(++$stanza % $OPT->{'stanza'}));

	    $OPT->{'buffer'} = strip_first_word($OPT->{'buffer'}, $OPT->{'width'});
	}

	# time to clear out the last of the buffer?
	if ($finish) {
	    $line = $OPT->{'buffer'};
	    PUSH("$line".$OPT->{'break'});
	}

	# flush the buffer
	$OPT->{'buffer'} = '';
    } else {
	# time already printed linked words
	$line = strip_first_word($line, $OPT->{'link'}) 
	    if ($OPT->{'flush'} and $OPT->{'link'} and $OPT->{'doflush'});

	PUSH("$line".$OPT->{'break'});
	return (1, '') if (++$lines > $OPT->{'lines'});

	# do stanza breaks
	PUSH($OPT->{'break'}) if $OPT->{'stanza'} and (!(++$stanza % $OPT->{'stanza'}));
    }

    # make sure that we clear linked words next time through
    $OPT->{'doflush'} = 1;

    # stash counters
    $OPT->{'stanzacount'} = $stanza;
    $OPT->{'linecount'} = $lines;

    # we're not done yet
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;

    (0, $line);
}

# add dashes in opportune places
sub add_dashes {
    my $line = shift;

    # end of line dashes are quite common
    $line =~ s/\s*$/--/ if (rand() > 0.80);

    # and mid-line dashes are occasional
    if (word_count($line) > 3 and rand() > 0.90) {
	$line = get_first_word($line, 2) . '--' . strip_first_word($line, 2);
    }
    $line;
}

# strip all punctuation
sub strip_punct {
    my $line = shift;
    $line =~ s{\[}{}g;
    $line =~ s{\]}{}g;
    $line =~ s:/::g;
    $line =~ s:\\::g;
    $line =~ s/[-~`!@#$%^&*()_+={}|:;'",.?<>]//g;
    $line;
}

# find the first occurrence of a starting word, return line #
sub find_first {
    my $ref = shift;
    my $word = shift;
    my $count = shift || 1;
    my ($bottom, $top, $current, $line, $first);

    $bottom = 0;
    $top = $ref->{'line_count'} - 1;

    while ($bottom < $top-1) {
	$current = $bottom + int(($top - $bottom)/2);
	$first = first_word(fetch_line($ref, $current), $count);
	if ($first ge $word) {
	    $top = $current - 1;
	} else {
	    $bottom = $current;
	}
    }
    $bottom + 1;
}

# find the last occurrence of a starting word, return line #
sub find_last {
    my $ref = shift;
    my $word = shift;
    my $count = shift || 1;
    my ($bottom, $top, $current, $line, $first);

    $bottom = 0;
    $top = $ref->{'line_count'} - 1;

    while ($bottom < $top-1) {
	$current = $bottom + int(($top - $bottom)/2);
	$first = first_word(fetch_line($ref, $current), $count);
	if ($first gt $word) {
	    $top = $current - 1;
	} else {
	    $bottom = $current;
	}
    }
    $bottom + 1;
}

# find the (normalized) first word(s) of a line
sub first_word {
    my $line = shift;
    my $count = shift || 1;
    my ($i, $temp, $where, $prev);

    return '' unless $line;
    $line =~ s/^\s*//;	# trim any leading whitespace

    # extract first $count words
    for ($i = $prev = 0, $temp = ''; $i < $count; $i++) {
	$where = index($line, ' ', $prev);  # find next space
	last unless ($where > 0);
	$temp .= (($temp eq '') ? '' : ' '). 
	    substr($line, $prev, $where-$prev);  # copy word
	$prev = $where+1;   # mark found space
    }
    normalize($temp);
}

# find the (normalized) last word(s) of a line
sub last_word {
    my $line = shift;
    my $count = shift || 1;

    my $result = first_word(join('', reverse (split('', $line))), $count);
    join('', reverse(split('', $result)));
}

# strip the first word(s) from a line
sub strip_first_word {
    my $line = shift;
    my $count = shift || 1;
    my ($i, $where, $prev);

    $line =~ s/\s*$//;

    for ($i = $prev = 0; $i < $count; $i++) {
	$where = index($line, ' ', $prev);  # find next space
	last unless ($where > 0);
	$prev = $where + 1;
    }
    substr($line, $where + 1);
}

# strip the last word(s) from a line
sub strip_last_word {
    my $line = shift;
    my $count = shift || 1;

    my $result = strip_first_word(join('', reverse (split('', $line))), $count);
    join('', reverse(split('', $result)));
}

# return the (non-normalized) first word(s) from a line
sub get_first_word {
    my $line = shift;
    my $count = shift || 1;
    my ($result);

    $line =~ s/^\s*//;
    $result = strip_first_word($line, $count);
    substr($line, 0, length($line) - length($result));
}

# return the (non-normalized) last word(s) from a line
sub get_last_word {
    my $line = shift;
    my $count = shift || 1;
    my ($result);

    $line =~ s/\s*$//;
    $result = strip_last_word($line, $count);
    substr($line, length($result)-1);
}

# pick a random line beginning with the specified word(s)
sub get_word_line {
    my $ref = shift;
    my $word = normalize(shift);
    my $count = shift || 1;
    my ($first, $last);

    $first = find_first($ref, $word, $count);
    $last = find_last($ref, $word, $count);
    fetch_line($ref, int(rand($last - $first) + $first));   
}

# return the count of words in a line
sub word_count {
    my $line = shift;
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    $line =~ s/\s+/ /g;
    ($line =~ s/ //g) + 1;
}

# normalize a file word for matching purposes
sub normalize {
    my $word = shift;

    $word =~ s/[^a-zA-Z0-9 ]//g;
    $word = lc($word);
}

# make an easy-to-pass hash ref containing file info
sub make_handle {
    my $name = shift;
    my $count = shift;
    my $length = shift;

    my $fh = new FileHandle("< $name") or 
	die "$0: cannot open source file [$name]: $!\n";

    {
	'handle' => $fh,
	'name'   => $name, 
	'line_count' => $count,
	'line_length' => $length,
    }
}

# close filehandle stored in a ref
sub close_handle {
    my $ref = shift;
    my $fh = $ref->{'handle'};
    $fh->close();
}

# seek (approximately) to a certain line in the file and return its contents
sub fetch_line {
    my $ref = shift;
    my $line = shift;	# line # to find
    my ($seek, $text, $fh);

    $seek = int($line * $ref->{'line_length'});
    $fh = $ref->{'handle'};
    seek($fh, $seek, 0);
    <$fh>;
    $text = <$fh> || '';
    chomp($text);
    $text;
}

# command line processing
sub process_cmdline
{
    my $prog = $0;                  # what's my name baby?
    $prog =~ s:.*?([^/]+)$:$1:;     # just a little trim job

    # allow CVS to keep track of versions and last updates :-)
    my $version = '(CVS revision #) $Revision: 1.24 $';     
       $version    =~ s/\$//g;
    my $lastupdate = '$Date: 2003/05/25 23:55:43 $';      
       $lastupdate =~ s/\$//g;

    my $usage = <<EOU;
Usage:  $0 [options]

Write me a poem.

    options

    --source <file>        Sorted text file to use as source
    --filelines <num>      Length of source file in lines (use 'wc -l')

    --lines  <num>         Length of poem in lines
    --link   <num>         Number of words to link between lines
    --width  <num>         Line width
    --topic  <phrase>      Topic to use for this poem
    --stanza <num>         Number of lines in a stanza
    --dickinson            Use lots of dashes
    --hd                   1 word lines, no stanzas
    --eecummings           use only lower case
    --olson                Strip all punctuation
    --wcwilliams           In William Carlos Williams style
    --stein                Gertrude Stein mode
    --web                  Wrap in rickbradley.com web post formatting

    -h, -?, --help         Display this message
    -v, --version          Output version info and exit
    -d, --debug            Turn on debugging (default = off)

Rick Bradley <rick at rickbradley.com>

EOU

    # variables to store commandline args
    my ($arg_source, $arg_filelines, $arg_lines, $arg_link, $arg_topic,
	$arg_stanza, $arg_eecummings, $arg_nopunctuation, $arg_dickinson,
	$arg_stein, $arg_wcwilliams, $arg_web, $arg_hd, $arg_help, $arg_olson,
	$arg_width, $arg_version, $arg_debug, $opt);

    # don't ignore case -- in case we want to differentiate between '-x'/'-X'
    Getopt::Long::Configure('no_ignore_case');

    # retrieve the command line options
    GetOptions(
	       'source=s'      => \$arg_source,
	       'filelines=i'   => \$arg_filelines,
	       'lines=i'       => \$arg_lines,
	       'link=i'        => \$arg_link,
	       'stanza=i'      => \$arg_stanza,
	       'topic=s'       => \$arg_topic,
	       'dickinson'     => \$arg_dickinson, 
	       'eecummings'    => \$arg_eecummings,
	       'olson'         => \$arg_olson,
	       'hd'            => \$arg_hd,
	       'wcwilliams'    => \$arg_wcwilliams,
	       'stein'         => \$arg_stein,
	       'width=i'       => \$arg_width,
	       'web'           => \$arg_web,
	       'help|h|?'      => \$arg_help,
	       'version|v'     => \$arg_version,
	       'debug|d'       => \$arg_debug,
    ) &&!$arg_help &&!$arg_version or die $usage;

    die $usage if $arg_version;

    # prepare for the inevitable
    my $dieflag = 0;
    my $dieerror = '';

    # process command-line arguments
    $opt = { };

    $opt->{'source'} = $arg_source || '/home/rick/all.sorted';
    if (! -f $opt->{'source'}) {
	$dieflag = 1;	
	$dieerror = "$0: cannot locate source file [".$opt->{'source'}."]\n";
    }

    $opt->{'line_count'} = $arg_filelines || 50979822;
    $opt->{'line_length'} = int(((stat($opt->{'source'}))[7])/$opt->{'line_count'});

    # validate lines
    if (defined $arg_lines and $arg_lines <= 0) {
        $dieflag = 1;
        $dieerror .= "--lines must specify a number > 0\n";
    }

    # validate linkage
    if (defined $arg_link and $arg_link <= 0) {
        $dieflag = 1;
        $dieerror .= "--link must specify a number > 0\n";
    }

    # validate width
    if (defined $arg_width and $arg_width <= 0) {
        $dieflag = 1;
        $dieerror .= "--width must specify a number > 0\n";
    }

    # validate stanza
    if (defined $arg_stanza and $arg_stanza <= 0) {
        $dieflag = 1;
        $dieerror .= "--stanza must specify a number > 0\n";
    }

    # set option values
    $opt->{'debug'} = $arg_debug || 0;
    $opt->{'lines'} = ($arg_lines || 8) - 1;
    $opt->{'link'} = $arg_link || 1;
    $opt->{'width'} = $arg_width || 0;
    $opt->{'stanza'} = $arg_stanza || 0;
    $opt->{'topic'} = $arg_topic || '';
    $opt->{'dashes'} = $arg_dickinson || 0;
    $opt->{'lower'} = $arg_eecummings || 0;
    $opt->{'punct'} = ($arg_olson ? 0 : 1);
    $opt->{'flush'} = $arg_stein ? 0 : 1;
    $opt->{'web'} = $arg_web || 0;

    # set combo-poet options
    #
    if ($arg_wcwilliams) {
	$opt->{'stanza'} = 4;
	$opt->{'punct'} = 0;
    }

    if ($arg_hd) {
	$opt->{'stanza'} = 0;
	$opt->{'width'} = 1;
    }

    # set stanza break string
    $opt->{'break'} = $opt->{'web'} ? "<br />\n" : "\n";

    # seasons don't fear the reaper
    die "\n$dieerror\n$usage" if $dieflag;   

    # return the options hash
    $opt;
}

__END__
use vars qw($source $ref $rand $line $word $OPT $DEBUG $done);

# retrieve command-line arguments
$OPT = process_cmdline();
$DEBUG = $OPT->{'debug'};

# get a handle for this file
$ref = make_handle($OPT->{'source'}, $OPT->{'line_count'}, $OPT->{'line_length'});

if ('' ne $OPT->{'topic'}) {
    # choose a first line like that provided
    $line = get_word_line($ref, $OPT->{'topic'}, word_count($OPT->{'topic'}));
} else {
    # choose a random first line
    $rand = int(rand($OPT->{'line_count'}));
    $line = fetch_line($ref, $rand);
}

# write a poem
$done = 0;
while (! $done) {
    # display line
    ($done, $line) = display_line($OPT, $line);

    # find link word(s)
    $word = last_word($line, $OPT->{'link'});
    print "                                            word [$word]\n" if $DEBUG;

    # get next line
    $line = get_word_line($ref, $word, $OPT->{'link'});
}

# cleanup
close_handle($ref);


