#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::Factory;
use Bio::Phylo::Treedrawer;
use Bio::Phylo::IO 'parse_tree';
use Bio::Phylo::Util::Logger ':levels';

# process command line arguments
my $width  = 3000;
my $height = 3000;
my $shape  = 'radial';
my $nexml  = 'tree.xml';
my $verbosity = WARN;
GetOptions(
	'width=i'  => \$width,
	'height=i' => \$height,
	'shape=s'  => \$shape,
	'nexml=s'  => \$nexml,
	'verbose+' => \$verbosity,
);

# instantiate helper objects
my $log = Bio::Phylo::Util::Logger->new(
	'-level'   => $verbosity,
	'-class'   => [ 
		'main', 
		'Bio::Phylo::Treedrawer',
		'Bio::Phylo::Treedrawer::Svg' 
	],
);
$log->info("going to read tree '$nexml'");
my $tree = parse_tree(
	'-format'  => 'nexml',
	'-file'    => $nexml,
);
$log->info("going to instantiate tree drawer");
my $draw = Bio::Phylo::Treedrawer->new(
	'-format'  => 'svg',
	'-mode'    => 'phylo',
	'-shape'   => $shape,
	'-width'   => $width,
	'-height'  => $height,
	'-tree'    => $tree,
	'-padding' => 400,
	'-branch_width' => 6,
	'-node_radius'  => 0,
);

# draw tree
$log->info("going to draw tree");
print $draw->draw;