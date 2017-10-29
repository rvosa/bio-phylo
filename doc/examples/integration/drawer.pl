#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::Factory;
use Bio::Phylo::Treedrawer;
use Bio::Phylo::IO 'parse_tree';
use Bio::Phylo::Util::Logger ':levels';

my $template = 'http://www.eol.org/search?q=%s';

# process command line arguments
my $width  = 12000;
my $height = 12000;
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
		'Bio::Phylo::Treedrawer::Svg',
		'Bio::Phylo::Treedrawer::Abstract'
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
	'-padding' => 100,
	'-branch_width'     => 4,
	'-text_width'       => 120,
	'-node_radius'      => 0,
	'-text_vert_offset' => 3,
);

# clade label font
my %font = (
	'-face'   => 'Verdana',
	'-size'   => 8,
	'-weight' => 'bold',
);

# rename taxa to "G. species" for genus >= 10 taxa, label, apply font
my @nodes  = @{ $tree->get_entities };

# mark up the tip labels
for my $tip ( grep { $_->is_terminal } @nodes ) {
	my $name = $tip->get_name;
	$name =~ s/ /+/g;
	$tip->set_font_face($font{'-face'});
	$tip->set_font_size($font{'-size'});
	$tip->set_font_style('Italic');
	$tip->set_link(sprintf $template, $name	);
}

for my $l ( grep { $_->get_clade_label } @nodes ) {
	my @tips = @{ $l->get_terminals };
	if ( scalar(@tips) >= 3 ) {
		for my $t ( @tips ) {
			my $name = $t->get_name;
			$name =~ s/^([A-Z])[a-z]+/$1./;
			$t->set_name($name);
		}
		$l->set_clade_label_font(\%font);
	}
	else {
		$l->set_clade_label('');
	}
}



# draw tree
print $draw->draw;