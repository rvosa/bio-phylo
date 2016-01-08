#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse_tree';

# distance between identical trees should be 0, regardless whether normalized or not
{
	my $newick = '((A,B),C);';
	my $t1 = parse_tree( '-format' => 'newick', '-string' => $newick );
	my $t2 = parse_tree( '-format' => 'newick', '-string' => $newick );	
	ok( $t1->calc_symdiff($t2) == 0, 'identical topologies have symdiff == 0' );
	ok( $t1->calc_symdiff($t2,1) == 0, 'identical topologies have normalized symdiff == 0' );
}

# three taxon trees that differ have symdiff 2, normalized symdiff 1. Reason:
# $n1 has split 'A,B' (and 'A,B,C')
# $n2 has split 'A,C' (and 'A,B,C')
# hence, symmetrically, there are two splits unique to one tree ('A,B' and 'A,C'), so
# the un-normalized symdiff == 2. The normalized symdiff should be 1 because (apart from
# the root) there is no single shared split so the distance should be fully realized if
# our metric ranges between 0 and 1
{
	my $n1  = '((A,B),C);';
	my $n2  = '((A,C),B);';
	my $t1  = parse_tree( '-format' => 'newick', '-string' => $n1 );
	my $t2  = parse_tree( '-format' => 'newick', '-string' => $n2 );
	my $sd  = $t1->calc_symdiff($t2);
	my $nsd = $t1->calc_symdiff($t2,1);
	ok( $sd == 2, "different 3-taxon trees have symdiff == 2 (obs: $sd)" );
	ok( $nsd == 1, "different 3-taxon trees have normalized symdiff == 1 (obs: $nsd)" );
}

# four taxon trees that are partly compatible, e.g. ((A,B),(C,D)); and (((A,B),C),D);
# share the split A,B, but t1 also has C,D and t2 has A,B,C. Hence, the symdiff should
# be 2 (because there are two splits unique to one tree), and the normalized symdiff 
# should be 2/3
{
	my $n1 = '((A,B),(C,D));';
	my $n2 = '(((A,B),C),D);';
	my $t1  = parse_tree( '-format' => 'newick', '-string' => $n1 );
	my $t2  = parse_tree( '-format' => 'newick', '-string' => $n2 );
	my $sd  = $t1->calc_symdiff($t2);
	my $nsd = $t1->calc_symdiff($t2,1);
	ok( $sd == 2, "4-taxon trees with 1 shared split have symdiff == 2 (obs: $sd)" );
	ok( $nsd == (2/3), "4-taxon trees  with 1 shared split have normalized symdiff == 2/3 (obs: $nsd)" );
}
