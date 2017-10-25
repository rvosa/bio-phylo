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
my $clade  = 5;
my $shape  = 'radial';
my $nexml  = 'tree.xml';
my $verbosity = WARN;
GetOptions(
	'width=i'  => \$width,
	'height=i' => \$height,
	'clade=i'  => \$clade,
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

# prune monotypic genera
my @prune;
for my $tip ( @{ $tree->get_terminals } ) {
	$log->debug("checking tip ".$tip->get_name);
	unless ( grep { $_->get_clade_label } @{ $tip->get_ancestors } ) {
		push @prune, $tip;
		$log->info("pruning tip ".$tip->get_name);
	}
}
$tree->prune_tips(\@prune);
$log->info("pruned ".scalar(@prune)." monotypic genera");

# prune clades < 10
my @clade;
$tree->visit_depth_first(
	'-post' => sub {
		my $n = shift;
		if ( $n->is_terminal ) {
			$n->set_generic( 'weight' => 1 );
		}
		else {
			my $weight;
			for my $c ( @{ $n->get_children } ) {
				$weight += $c->get_generic('weight');
			}
			$n->set_generic( 'weight' => $weight );
			if ( my $label = $n->get_clade_label ) {
				push @clade, [ $label, $n, $weight ];
				$log->debug("visiting clade $label ($weight)");
			}
		}
	}
);
for my $c ( grep { $_->[2] <= $clade } @clade ) {
	$log->info("pruning clade ".$c->[0]);
	$tree->prune_tips( $c->[1]->get_terminals );
}

# draw tree
$log->info("going to draw tree n=".scalar(@{$tree->get_terminals}));
print $draw->draw;