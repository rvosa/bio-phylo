#!/usr/bin/perl
#$Id: nexvl.pl 51 2009-03-11 06:02:22Z maj@fortinbras.us $#
# nexml validator script

=head1 NAME

nexvl.pl - Command-line NeXML validation script

=head1 SYNOPSIS

 $ ./nexvl.pl my-nex.xml her-nex.xml our-nex.xml
 -or if that doesn't work-
 $ perl nexvl.pl my-nex.xml her-nex.xml our-nex.xml

 $ ./nexvl.pl -q 01_basic.xml Fang_2003.xml
 01_basic.xml : Success!
 Fang_2003.xml : FAIL
 
 $ if (./nexvl.pl -Q Fang_2003.xml) ;
 > then echo Excellent\!
 > else echo Gnarly\!
 > fi
 Gnarly!

 $ ./nexvl.pl -v 01_basic.xml
 01_basic.xml : Success!
 --messages--
  debug: created helper objects
  debug: going to read file '01_basic.xml'
  debug: reading from handle
  debug: created temporary file '/tmp/_0sNAnwOGL'
  debug: copied uploaded data to '/tmp/_0sNAnwOGL'
  debug: read file '01_basic.xml', copied contents to '/tmp/_
  debug: created java validator invocation
  info : executing java validator
  info : executing perl validator
  [ and many, many more... ]
  debug: set char: '0' (line 85)
  debug: processed <nex:nexml/> (line 86)
  info : Processed nexml element (line 86)
  info : validation succeeded
 --end messages--

 $ ./nexvl.pl -V 01_basic.xml
 01_basic.xml : Success!
 --messages--
  debug: created helper objects
  debug: going to read file '01_basic.xml'
  [...]
  info : Processed nexml element (line 86)
  info : validation succeeded
 --end messages--
 --submitted--
 1       <nex:nexml generator="Bio::Phylo::Project v.0.17_RC9_841" version="0.8" xmlns="http://www.nexml.org/1.0" xmlns:nex="http://www.nexml.org/1.0" xmlns:rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns" xmlns:xml="http://www.w3.org/XML/1 98/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaL cation="http://www.nexml.org/1.0 http://www.nexml.org/1.0/nexml.xsd">
 2       <otus id="otus1">
 3       <otu id="otu2" label="otuA"/>
 4       <otu id="otu3" label="otuB"/>
 5       <otu id="otu4" label="otuC"/>
 6       <otu id="otu5" label="otuD"/>
 7       <otu id="otu6" label="otuE"/>
 8       <otu id="otu7" label="otuF"/>
 9       </otus>
 10      [...]
 [...]
 85      </characters>
 86      </nex:nexml>
 --end submitted--

=head1 DESCRIPTION

C<nexvl.pl> will send your NeXML files off to Rutger Vos' web validator at
L<http://nexml.org/nexml/validator.cgi>, and parse the response, returning 
success or fail results for each file, and if desired, the detailed comments
the validator makes on each file. The script strips all HTML tags and decodes
HTML entities before output. 

The validator returns the following comment types (in order of decreasing severity): C<fatal>, C<error>, C<warning>, C<info>, and C<debug>. Command line options are available to control comment verbosity; see the OPTIONS section.

Comments always welcome; see the AUTHOR section.

=head1 OPTIONS

The default behavior is to return validator comments if a file fails validation, and a simple success message if it succeeds. Valid options are as follows:

 -v : verbose - return all validator comments, regardless of 
      success/fail
 -V : very verbose - return all validator comments, plus the 
      validator's echo of the NeXML file you sent
 -q : quiet - return only success/fail message
 -Q : very quiet - return 0 on success for all files, 1 on failure 
      of any file
 -[n], where n is [1|2|3|4|5]
    : return validator comments of decreasing severity, 
      from -1 (only fatal exceptions) to -5 (same as -v)

=head1 AUTHOR - Mark Jensen

Email L<maj@fortinbras.us>

=cut

use strict;
use LWP::UserAgent;
use HTML::Parser;
use Getopt::Std;
use File::Spec;
use constant VURL =>'http://nexml.org/nexml/validator.cgi';

$main::VERSION = 0.1;
my %opts;
getopts('qQvV12345', \%opts);

my ($rsp, $fmref);
# parser globals...
my ( $p, $in_main, $check_text, $collecting, $slurp_msg, $slurp_subm, $cur_type, $div_depth);
my @msg_types = qw(fatal error warn info debug);
my @msg_store;
my $submitted;
my ($success, $any_fail);

my $ua = LWP::UserAgent->new();
$ua->agent( 'nexml-val/0.1 '.$ua->_agent);

my $vidx = 3; # default for fails

if ( !($opts{q} || $opts{Q}) ) {
    map { $vidx = $_ if $opts{$_} } (1..5);
    $vidx = 5 if ( $opts{v} || $opts{V} );
    if ($vidx) {
	@msg_types = @msg_types[0..$vidx-1];
    }
    else {
	@msg_types = ();
    }
}
else {
    @msg_types = ();
}

foreach (@ARGV) {

    unless ( -e && -f ) {
	warn "Issue with uploaded file '$_': $@";
	$any_fail=1;
	next;
    }

    $fmref = [$_,undef];
    $rsp = $ua->post( VURL, 
		      Content_type => 'form-data',
		      Content => [ 'file' => $fmref ] );
    if ($rsp->is_error and $rsp->code != 400) {
	warn "Issue with HTTP response: ".$rsp->status_line;
	$any_fail=1;
	next;
    }
    $success = ($rsp->content =~ /nexml: success/i);
    $any_fail ||= !$success;
    exit (1) if ($any_fail && $opts{Q});
    if (((grep {defined} @opts{qw(v V 1 2 3 4 5)}) || !$success) && @msg_types) {
	clear_globals();
	$p = HTML::Parser->new( empty_element_tags => 1,
				start_h => [\&start, "self, tagname, attr, text"],
				end_h => [\&end, "self, tagname"],
				text_h => [\&text, "self, tagname, dtext"],
				ignore_elements => [qw(head)],
				unbroken_text => 1
	    );
	$p->parse($rsp->content);
	$p->eof;
    }
    
    #output
    unless ($opts{Q}) {
	print join('', (File::Spec->splitpath($_))[2], " : ", $success ? "Success!" : "FAIL", "\n");
	if (((grep {defined} @opts{qw(v V 1 2 3 4 5)}) || !$success) && @msg_types) {
	    if (@msg_store) {
		print "--messages--\n";
		while (@msg_store) {
		    my ($ty, $msg) = (shift @msg_store, shift @msg_store);
		    ($ty) = split(/ /, $ty);
		    printf(" %-5s: %s\n",$ty,$msg) if grep /$ty/, @msg_types;
		}
		print "--end messages--\n";
	    }
	    else {
		print "--no messages--\n";
	    }
	}
	if ($opts{V}) {
	    if ($submitted) {
		print "--submitted--\n";
		print $submitted;
		print "--end submitted--\n";
	    }
	    else {
		print "--submitted nil--\n";
	    }
	};
    }
}
exit ($any_fail ? 1 : 0);


sub start {
    my ($self, $tagname, $attrh, $text) = @_;
    ($$attrh{id} eq 'main') && do {
	$in_main = 1;
    };
    ($tagname eq 'h3') && $in_main && do {
	$check_text = 1;
    };
    ($tagname eq 'li') && $collecting && do {
	$cur_type = $$attrh{class};
	$slurp_msg++;
    };
    ($tagname eq 'div') && $collecting && do {
	$slurp_subm++;

    };
    return;
}

sub text {
    my ($self, $tagname, $text) = @_;
    $text =~ s/^\s*//g;
    $text =~ s/\s*$//g;
    if ($check_text) {
	$collecting = 1 if ( $text =~ /Detailed results/ or
			     $text =~ /Submitted content/ );
	$check_text = 0;
    }
    if ($slurp_msg) {
	push @msg_store, ($cur_type => $text) if $text;
    }
    if ($slurp_subm) {
	$submitted .= $text.($text=~/^[0-9]+$/ ? "\t" : "\n") if $text;
    }
    return;
}
    

sub end {
    my ($self, $tagname) = @_;
    ($tagname eq 'main') && do {
	$in_main = 0;
    };
    ($tagname eq 'ul') && $collecting && do {
	$cur_type = '';
	$collecting = 0;
    };
    ($tagname eq 'li') && $collecting && do {
	$slurp_msg && $slurp_msg--;
    };
    ($tagname eq 'div') && $collecting && do {
	$slurp_subm && $slurp_subm--;
	$collecting = 0 unless $slurp_subm;
    };

    return;
}

# clear parser globals
sub clear_globals {
    @msg_store = ();
    $submitted = '';
    $collecting = 0;
    $in_main = $slurp_subm = $slurp_msg = 0;
    $cur_type = '';
    return;
}

#Help!
sub HELP_MESSAGE {
    print "Usage: nexvl.pl [-qQvV12345] NEXML-FILE [NEXML-FILE...]\n";
    print <<HELP;
Options:
-q quiet (success/fail msg only)
-Q very quiet (exit value only)
-v verbose (+ all validator detail msgs)
-V very verbose (+ validator input file echo)
-1..-5 severity reporting level
--help this message
HELP
return;
}
