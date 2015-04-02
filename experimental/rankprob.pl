#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw[sum min max];
use Bio::Phylo::Util::Logger ':levels';
use constant True  => !undef;
use constant False => undef;

my $log = Bio::Phylo::Util::Logger->new( '-level' => INFO );

# # # # # # # # # # #
# Rank functions Daniel Ford, Tanja Gernhard 2006
# Functions:
# rankprob(t,u)     - returns the probability distribution
#                     of the rank of vertex "u" in tree "t"
# expectedrank(t,u) - returns the expected rank
#                     of vertex "u" and the variance
# compare(t,u,v)    - returns the probability that "u"
#                     is below "v" in tree "t"

# This is a more or less literal port to Perl of the functions developed by
# Daniel Ford and Tanja Stadler (nŽe Gernhard) during Tanja's dissertation
# research. Some minimal changes were made to make the code more idiomatic.

##########################################################################################
# Math functions. Maybe these should go into something like Bio::Phylo::Util::Math, 
# together with random_exponential, random_uniform, qnorm, qbeta

# Calculation of n choose j
# This version saves partial results for use later
my @nc_matrix; #stores the values of nchoose(n,j)
# -- note: order of indices is reversed
sub nchoose_static {
	my ( $n, $j, @nc_matrix ) = @_;
	return 0 if $j > $n;
	if ( @nc_matrix < $j + 1 ) {
		push @nc_matrix, [] for @nc_matrix .. $j;
	}
	if ( @{ $nc_matrix[$j] } < $n + 1 ) {	
		push @{ $nc_matrix[$j] }, 0 for @{ $nc_matrix[$j] } .. $j - 1;
	}
	push @{ $nc_matrix[$j] }, 1 if @{ $nc_matrix[$j] } == $j;
	for my $i ( @{ $nc_matrix[$j] } .. $n ) {
		push @{ $nc_matrix[$j] }, $nc_matrix[$j]->[$i-1] * $i / ( $i - $j );
	}
	return $nc_matrix[$j]->[$n];
}

# dynamic programming version
sub nchoose {
	my ( $n, $j ) = @_;
	return nchoose_static($n,$j,@nc_matrix);
}

# GCD - assumes positive integers as input
# (subroutine for compare(t,u,v))
sub gcd {
	my ( $n, $m ) = @_;
	return $n if $n == $m;
	( $n, $m ) =  ( $m, $n ) if $m > $n;
	my $i = int($n / $m);
	$n = $n - $m * $i;		
	return $m if $n == 0;
	
	# recurse
	return gcd($m,$n);
}

# Takes two large integers and attempts to divide them and give
# the float answer without overflowing
# (subroutine for compare(t,u,v))
# does this by first taking out the greatest common denominator
sub gcd_divide {
	my ( $n, $m ) = @_;
	my $x = gcd($n,$m);
	$n /= $x;
	$m /= $x;
	return $n/$m;
}

##########################################################################################
# Original comment:
# get the number of descendants of u and of all vertices on the
# path to the root (subroutine for rankprob(t,u))

# Interpretation:
# recurses from the root to the tips, returns an array reference at every step whose
# first element is a boolean set to true once the query node has been seen. The second
# element is an array that contains the number of subtended leaves - 1 for the query
# node and for all sisters of the nodes on the path from the query to the root
sub numDescendants {
	my ($node,$u) = @_;
	
	# focal node (subtree) is empty, i.e. a leaf 
	if ( not @{ $node } ) {
		$log->info("node is terminal");
		return [False,False];
	}
	else {
		$log->info("node is internal");
	}
	
	# focal node is u
	if ( $node->[2]->{"label"} == $u ) {
		$log->info("reached node $u");
		return [True,[$node->[2]->{"leaves_below"}-1]];
	}
	else {
		$log->info("not yet reached $u: ".$node->[2]->{"label"});		
	}
	
	# recurse left
	my $x = numDescendants( $node->[0], $u );
	if ( $x->[0] ) {
		$log->info("seen $u");
		my $n;
		
		# focal node has no sibling
		if ( not @{ $node->[1] } ) {
			$n = 0;
		}
		else {
			$n = $node->[1]->[2]->{"leaves_below"} - 1;
		}
		return [ True, [ @{ $x->[1] }, $n ] ];
	}
	else {
		$log->info("not seen $u");
	}
	
	# recurse right
	my $y = numDescendants( $node->[1], $u );
	if ( $y->[0] ) {
		$log->info("seen $u");
		my $n;
		
		# focal node has no sibling
		if ( not @{ $node->[0] } ) {
			$n = 0;
		}
		else {
			$n = $node->[0]->[2]->{"leaves_below"} - 1;
		}
		return [ True, [ @{ $y->[1] }, $n ] ];
	}
	else {
		$log->info("not seen $u");
		return [False,False];
	}
}

# returns the subtree rooted at the common ancestor of u and v
# (subroutine for compare(t,u,v))
# return
# True/False - have we found u yet
# True/False - have we found v yet
# the subtree - if we have found u and v
# the u half of the subtree
# the v half of the subtree
sub subtree {
	my ($node,$u,$v) = @_;
	
	# node is terminal
	if ( not @{ $node } ) {
		return False, False, False, False, False;
	}
	
	# recurse left and right
	my ( $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl ) = subtree( $node->[0], $u, $v );
	my ( $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr ) = subtree( $node->[1], $u, $v );
	
	# both were left descendants of focal node, return result
	if ( $found_ul and $found_vl ) {
		return $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl;
	}
	
	# both were right descendants of focal node, return result
	if ( $found_ur and $found_vr ) {
		return $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr;
	}
	
	# have we found either?
	my $found_u = ( $found_ul or $found_ur or $node->[2]->{"label"} == $u );
	my $found_v = ( $found_vl or $found_vr or $node->[2]->{"label"} == $v );
	
	# initialize and assign subtrees
	my ( $subtree_u, $subtree_v );		
	$subtree_u = $subtree_ul if $found_ul;
	$subtree_v = $subtree_vl if $found_vl;
	$subtree_u = $subtree_ur if $found_ur;
	$subtree_v = $subtree_vr if $found_vr;
	if ( $found_u and (not $found_v) ) {
		$subtree_u = $node;
	}
	elsif ( $found_v and (not $found_u) ) {
		$subtree_v = $node;
	}
	$subtree_u = $node if $node->[2]->{"label"} == $u;
	$subtree_v = $node if $node->[2]->{"label"} == $v;
	
	# return results
	return $found_u, $found_v, $node, $subtree_u, $subtree_v;
}

sub get_subtree {
	my ($node,$u,$v) = @_;
	
	# node is terminal
	my @child = @{ $node->get_children };
	if ( not @child ) {
		return False, False, False, False, False;
	}
	
	# recurse left and right
	my ( $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl ) = get_subtree( $child[0], $u, $v );
	my ( $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr ) = get_subtree( $child[1], $u, $v );
	
	# both were left descendants of focal node, return result
	if ( $found_ul and $found_vl ) {
		return $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl;
	}
	
	# both were right descendants of focal node, return result
	if ( $found_ur and $found_vr ) {
		return $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr;
	}
	
	# have we found either?
	my $found_u = ( $found_ul or $found_ur or $node->is_equal($u) );
	my $found_v = ( $found_vl or $found_vr or $node->is_equal($v) );
	
	# initialize and assign subtrees
	my ( $subtree_u, $subtree_v );		
	$subtree_u = $subtree_ul if $found_ul;
	$subtree_v = $subtree_vl if $found_vl;
	$subtree_u = $subtree_ur if $found_ur;
	$subtree_v = $subtree_vr if $found_vr;
	if ( $found_u and (not $found_v) ) {
		$subtree_u = $node;
	}
	elsif ( $found_v and (not $found_u) ) {
		$subtree_v = $node;
	}
	$subtree_u = $node if $node->is_equal($u);
	$subtree_v = $node if $node->is_equal($v);
	
	# return results
	return $found_u, $found_v, $node, $subtree_u, $subtree_v;
}

=item calc_rankprob()

Calculates the probabilities for all rank orderings that the invocant node can
occupy among all possible labeled histories. Uses Stadler's RANKPROB algorithm as 
described in: 

B<Gernhard, T.> et al., 2006. Estimating the relative order of speciation 
or coalescence events on a given phylogeny. I<Evolutionary Bioinformatics Online>. 
B<2>:285. L<http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2674681/>.

 Type    : Calculation
 Title   : calc_rankprob
 Usage   : my @rp = @{ $node->calc_rankprob() };
 Function: Returns the rank probabilities of the invocant node
 Returns : ARRAY, indices are ranks, values are probabilities
 Args    : NONE

=cut  

sub calc_rankprob {
	my ($t,$u) = @_;
	my $x = numDescendants($t,$u); # XXX
	$x = $x->[1];
	my $lhsm = $x->[0];
	my $k = scalar(@$x);
	my $start = 1;
	my $end = 1;
	my $rp = [0,1];
	my $step = 1;
	while ( $step < $k ) {
		my $rhsm = $x->[$step];
		my $newstart = $start+1;
		my $newend = $end + $rhsm + 1;
		my $rp2 = [];
		for my $i ( 0 .. $newend ) {
			push @$rp2, 0;
		}
		for my $i ( $newstart .. $newend ) {
			my $q = max( 0, $i - 1 - $end );
			for my $j ( $q .. min( $rhsm, $i - 2 ) ) {
				my $a = $rp->[$i-$j-1] * nchoose($lhsm + $rhsm - ($i-1),$rhsm-$j) * nchoose($i-2,$j);
				$rp2->[$i]+=$a;
			}
		}
		$rp = $rp2;
		$start = $newstart;
		$end = $newend;
		$lhsm = $lhsm+$rhsm+1;
		$step += 1;
	}
	my $tot = sum( @{ $rp } );
	for my $i ( 0..$#{ $rp } ) {
		$rp->[$i] = $rp->[$i] / $tot;
	}
	return $rp;
}

=item calc_expected_rank()

Calculates the expected rank and variance that the invocant node occupies among all 
possible labeled histories. Uses Stadler's RANKPROB algorithm as described in: 

B<Gernhard, T.> et al., 2006. Estimating the relative order of speciation 
or coalescence events on a given phylogeny. I<Evolutionary Bioinformatics Online>. 
B<2>:285. L<http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2674681/>.

 Type    : Calculation
 Title   : calc_expected_rank
 Usage   : my ( $rank, $variance ) = $node->calc_expected_rank();
 Function: Calculates expected rank and variance
 Returns : Two numbers: rank and variance
 Args    : NONE

=cut

sub calc_expected_rank {
	my ( $t, $u ) = @_;
	my $rp = calc_rankprob( $t, $u );
	my $mu = 0;
	my $sigma = 0;
	for my $i ( 0 .. $#{ $rp } ) {
		$mu += $i * $rp->[$i];
		$sigma += $i * $i * $rp->[$i];
	}
	return $mu, $sigma - $mu * $mu;
}

=item calc_rankprob_compare()

Calculates the probability that the argument node is below the invocant node over all 
possible labeled histories. Uses Stadler's COMPARE algorithm as described in: 

B<Gernhard, T.> et al., 2006. Estimating the relative order of speciation 
or coalescence events on a given phylogeny. I<Evolutionary Bioinformatics Online>. 
B<2>:285. L<http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2674681/>.

 Type    : Calculation
 Title   : calc_rankprob_compare
 Usage   : my $prob = $u->calc_rankprob_compare($v);
 Function: Compares rankings of nodes
 Returns : A number (probability)
 Args    : Bio::Phylo::Forest::Node

=cut

sub compare {
	my ($t,$u,$v) = @_;
	my ($found_u,$found_v,$subtree,$subtree_u,$subtree_v) = subtree($t,$u,$v);
	
	# both vertices need to occur in the same tree, of course
	if ( not ($found_u and $found_v) ) {
		print "This tree does not have those vertices!";
		return 0;
	}
	
	# $u is the root of the subtree, 
	# hence $v MUST be below $u
	if ( $subtree->[2]->{"label"} == $u ) {
		return 1.0;
	}
	
	# $v is the root of the subtree,
	# so it can't be below $u
	if ( $subtree->[2]->{"label"} == $v ) {
		return 0.0;
	}

	# calculate rank probabilities in
	# respective subtrees
	my $x = calc_rankprob($subtree_u,$u);
	my $y = calc_rankprob($subtree_v,$v);
	my $usize = $subtree_u->[2]->{"leaves_below"} - 1;
	my $vsize = $subtree_v->[2]->{"leaves_below"} - 1;	
	
	for my $i ( scalar(@$x) .. $usize + 1 ) {
		push @$x, 0;
	}
	my $xcumulative = [0];
	for my $i ( 1 .. $#{ $x } ) {
		push @$xcumulative, $xcumulative->[$i-1] + $x->[$i];
	}
	my $rp = [0];
	for my $i ( 1 .. $#{ $y } ) {
		push @$rp, 0;
		for my $j ( 1 .. $usize) {
			my $a = $y->[$i] * nchoose($i-1+$j,$j) * nchoose($vsize-$i+$usize-$j, $usize-$j) * $xcumulative->[$j];
			$rp->[$i] += $a;
		}
	}
	my $tot = nchoose($usize+$vsize,$vsize);
	return sum(@$rp)/$tot;	
}

sub calc_rankprob_compare {
	my ($t,$u,$v) = @_;
	my ($found_u,$found_v,$subtree,$subtree_u,$subtree_v) = get_subtree($t,$u,$v); # XXX
	
	# both vertices need to occur in the same tree, of course
	if ( not ($found_u and $found_v) ) {
		print "This tree does not have those vertices!";
		return 0;
	}
	
	# If either one is the root node of the
	# subtree that connects them then their
	# relative rankings are certain.
	return 1.0 if $subtree->is_equal($u);
	return 0.0 if $subtree->is_equal($v);

	# calculate rank probabilities in
	# respective subtrees
	my $x = calc_rankprob($subtree_u,$u);
	my $y = calc_rankprob($subtree_v,$v);
	my $usize = $subtree_u->calc_terminals - 1;
	my $vsize = $subtree_v->calc_terminals - 1;	
	
	for my $i ( scalar(@$x) .. $usize + 1 ) {
		push @$x, 0;
	}
	my $xcumulative = [0];
	for my $i ( 1 .. $#{ $x } ) {
		push @$xcumulative, $xcumulative->[$i-1] + $x->[$i];
	}
	my $rp = [0];
	for my $i ( 1 .. $#{ $y } ) {
		push @$rp, 0;
		for my $j ( 1 .. $usize) {
			my $a = $y->[$i] * nchoose($i-1+$j,$j) * nchoose($vsize-$i+$usize-$j, $usize-$j) * $xcumulative->[$j];
			$rp->[$i] += $a;
		}
	}
	my $tot = nchoose($usize+$vsize,$vsize);
	return sum(@$rp)/$tot;	
}

my $t1 = [
		[
			[],
			[],
			{ 'leaves_below' => 2, 'label' => 4 }
		],
		[],
		{ 'leaves_below' => 3, 'label'=> 3 }
];
my $t2 = [
		[
			[],
			[],
			{ 'leaves_below' => 2, 'label'=> 7 }
		],
		[
			[],
			[],
			{ 'leaves_below' => 2, 'label' => 8 }
		],
	{ 'leaves_below' => 4, 'label' => 6 }
];
my $t3 = [
	[],
	[],
	{'leaves_below' => 2, 'label' => 5 }
];
my $t4 = [ $t1, $t3, { 'leaves_below' => 5, 'label' => 2 } ];

# Newick: (((l6,l7)7,(l8,l9)8)6,(((l1,l2)4,l3)3,(l4,l5)5)2)1;
my $t  = [ $t2, $t4, { 'leaves_below' => 9, 'label' => 1 } ];

use Data::Dumper;
my $result = numDescendants($t,2);
print Dumper($result);