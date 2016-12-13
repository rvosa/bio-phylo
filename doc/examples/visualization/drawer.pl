#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Bio::Phylo::Treedrawer;
use Bio::Phylo::IO qw'parse_tree';

# Process command line arguments, with defaults.
my $infile  = 'infile.nhx';
my $outfile = 'outfile.svg';
GetOptions(
	'infile=s'  => \$infile,
	'outfile=s' => \$outfile,
);

# Data can be read from url, handle, file or string. In this case we are reading a tree 
# file formatted as New Hampshire eXtended, which is essentially Newick format, but with 
# embedded, special comments that are parsed. In this case, these special comments 
# indicate the taxonomic class the focal node (and its descendants) belongs to.
my $tree = parse_tree(
	'-format' => 'nhx',
	'-file'   => $infile,
);

# The contents of data objects can be traversed in a number of ways. One of which is to
# pass a code reference to the 'visit' method, which is then applied to all the objects
# in the container (in this case, all nodes in a tree). The focal object is passed as the
# first argument of the code reference.
$tree->visit(sub{
	my $node = shift;
	$node->set_font_face('Verdana');
	$node->set_font_style('Italic') if $node->is_terminal;
	
	# Annotations that are parsed from New Hampshire eXtended are stored as Meta objects
	# whose predicates have the 'nhx' namespace prefix. Hence, this method returns, if
	# anything, a taxonomic class name. This class name is used as a clade label that will
	# be applied by the tree visualizer.
	if ( my $class = $node->get_meta_object('nhx:class') ) {
		$node->set_clade_label($class);
		$node->set_clade_label_font({ 
			'-weight' => 'bold',
			'-style'  => 'normal',
		});
	}
});

# Format and write the output.
open my $fh, '>', $outfile or die $!;
print $fh Bio::Phylo::Treedrawer->new(
	'-format' => 'svg',
	'-width'  => 4000,
	'-height' => 4000,
	'-tree'   => $tree,
	'-shape'  => 'radial',
	'-mode'   => 'phylo',
	'-text_width' => 300,
	'-padding'    => 250,
)->draw;