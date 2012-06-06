#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::CONSTANT qw':namespaces :objecttypes';

my ($tree) = @{ parse(
	'-format'     => 'adjacency',
	'-handle'     => \*DATA,
	'-as_project' => 1,
	'-namespaces' => {
		'dcterms' => _NS_DCTERMS_
	},
)->get_items(_TREE_) };

ok( $tree->to_newick );

my $output = unparse(
	'-format' => 'adjacency',
	'-phylo'  => $tree,
	'-predicates' => [ 'dcterms:identifier' ],
);

ok( $output );

__DATA__
child	parent	length	node:dcterms:identifier
n2		0	35462
n1	n2	3	34987
A	n1	1	73843
B	n1	2	98743
C	n2	4	39847