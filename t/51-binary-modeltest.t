#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Models::Substitution::Binary;

eval { require Statistics::R };

SKIP: {
	skip 'Statistics::R not installed', 2, if $@;
	my $tree = parse_tree(
		'-format' => 'newick',
		'-handle' => \*DATA,
	);
	
	ok( 'here we test $matrix->replicate' );
	ok( 'here we check if the result is reasonable' );
};

__DATA__
((A,B),C);