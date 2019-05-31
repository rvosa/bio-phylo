#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::Factory;
use Bio::Phylo::Treedrawer;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger ':levels';
use Bio::Phylo::Util::CONSTANT qw':objecttypes';

# clade label font
my %font = (
	'-face'   => 'Verdana',
	'-size'   => 8,
	'-weight' => 'bold',
);

# process command line arguments
my $width  = 12000;
my $height = 12000;
my $shape  = 'radial';
my $nexus  = 'Bininda-emonds_2007_mammals.nex';
GetOptions(
	'width=i'  => \$width,
	'height=i' => \$height,
	'shape=s'  => \$shape,
	'nexus=s'  => \$nexus,
);

# parse the nexus file
my $proj = parse(
	'-format'     => 'nexus',
	'-file'       => $nexus,
	'-as_project' => 1,
);

# fetch tree from nexus; fetch all its nodes, internal/terminal
my ($tree) = @{ $proj->get_items(_TREE_) };
my @nodes  = @{ $tree->get_entities };

# mark up the tip labels
for my $tip ( grep { $_->is_terminal } @nodes ) {

	# tip is domesticated
	if ( grep { !!$_ } map { $_->get_char } @{ $tip->get_taxon->get_data } ) {
		$tip->set_font_face($font{'-face'});
		$tip->set_font_size($font{'-size'});
		$tip->set_name('←');
	}
	else {
		$tip->set_name('');
	}	
}

# mark up the clade labels
for my $node ( grep { $_->get_name } grep { $_->is_internal } @nodes ) {
	$node->set_clade_label_font(\%font);
	$node->set_clade_label($node->get_name);
}

# instantiate tree drawer
my $draw = Bio::Phylo::Treedrawer->new(
	'-format'  => 'svg',
	'-mode'    => 'phylo',
	'-shape'   => $shape,
	'-width'   => $width,
	'-height'  => $height,
	'-tree'    => $tree,
	'-padding' => 100,
	'-branch_width'     => 4,
	'-text_width'       => 120,
	'-node_radius'      => 0,
	'-text_vert_offset' => 3,
);

# draw tree
print $draw->draw;