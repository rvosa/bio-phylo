#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::Factory;
use Bio::Phylo::Treedrawer;
use Bio::Phylo::IO 'parse_tree';

# need to configure this first so that we instantiate
# the right objects when parsing the newick string
my $fac = Bio::Phylo::Factory->new(
    'node' => 'Bio::Phylo::Forest::DrawNode',
    'tree' => 'Bio::Phylo::Forest::DrawTree',
);

# simple newick string, for example
my $newick = '((A,B),C);';

# parse as a tree object
my $tree = parse_tree(
    '-format' => 'newick',
    '-string' => $newick,
    '-as_project' => 1,
);

# instantiate tree drawer
my $drawer = Bio::Phylo::Treedrawer->new(
    '-width'  => 800,
    '-height' => 600,
    '-shape'  => 'RECT', # rectangular tree
    '-mode'   => 'CLADO', # cladogram
    '-format' => 'SVG'
);

# pass in the tree object
$drawer->set_tree($tree);

# compute the coordinates
$drawer->compute_coordinates;

# this we just do to create properly nested NeXML
my $proj = $fac->create_project;
my $forest = $fac->create_forest;
$forest->insert($tree);
$proj->insert($forest);
print $proj->to_xml;