#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw[sum min max];
use constant True  => !undef;
use constant False => undef;

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
# does this by first taking out the gcd
sub gcd_divide {
	my ( $n, $m ) = @_;
	my $x = gcd($n,$m);
	$n /= $x;
	$m /= $x;
	return $n/$m;
}

# get the number of descendants of u and of all vertices on the
# path to the root (subroutine for rankprob(t,u))
sub numDescendants {
	my ($tree,$u) = @_;
	
	# focal node (subtree) is empty, i.e. a leaf 
	return [False,False] unless @{ $tree };
	
	# focal node is u
	return [True,[$tree->[2]->{"leaves_below"}-1]] if $tree->[2]->{"label"}==$u;
	
	# recurse left
	my $x = numDescendants( $tree->[0], $u );
	if ( $x->[0] ) {
		my $n;
		
		# focal node has no sibling
		if ( not @{ $tree->[1] } ) {
			$n = 0;
		}
		else {
			$n = $tree->[1]->[2]->{"leaves_below"} - 1;
		}
		return [ True, [ @{ $x->[1] }, $n ] ];
	}
	
	# recurse right
	my $y = numDescendants( $tree->[1], $u );
	if ( $y->[0] ) {
		my $n;
		
		# focal node has no sibling
		if ( not @{ $tree->[0] } ) {
			$n = 0;
		}
		else {
			$n = $tree->[0]->[2]->{"leaves_below"} - 1;			
		}
		return [ True, [ @{ $y->[1] }, $n ] ];
	}
	else {
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
	my ($tree,$u,$v) = @_;
	
	# tree is empty
	if ( not @{ $tree } ) {
		return False, False, False, False, False;
	}
	
	# recurse left and right
	my ( $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl ) = subtree( $tree->[0], $u, $v );
	my ( $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr ) = subtree( $tree->[1], $u, $v );
	
	# both were left descendants of focal node, return result
	if ( $found_ul and $found_vl ) {
		return $found_ul, $found_vl, $subtree_l, $subtree_ul, $subtree_vl;
	}
	
	# both were right descendants of focal node, return result
	if ( $found_ur and $found_vr ) {
		return $found_ur, $found_vr, $subtree_r, $subtree_ur, $subtree_vr;
	}
	
	# have we found either?
	my $found_u = ( $found_ul or $found_ur or $tree->[2]->{"label"} == $u );
	my $found_v = ( $found_vl or $found_vr or $tree->[2]->{"label"} == $v );
	
	# initialize and assign subtrees
	my ( $subtree_u, $subtree_v );		
	$subtree_u = $subtree_ul if $found_ul;
	$subtree_v = $subtree_vl if $found_vl;
	$subtree_u = $subtree_ur if $found_ur;
	$subtree_v = $subtree_vr if $found_vr;
	if ( $found_u and (not $found_v) ) {
		$subtree_u = $tree;
	}
	elsif ( $found_v and (not $found_u) ) {
		$subtree_v = $tree;
	}
	$subtree_u = $tree if $tree->[2]->{"label"} == $u;
	$subtree_v = $tree if $tree->[2]->{"label"} == $v;
	
	# return results
	return $found_u, $found_v, $tree, $subtree_u, $subtree_v;
}

# A version of rankprob which uses the function numDescendants
sub rankprob {
	my ($t,$u) = @_;
	my $x = numDescendants($t,$u);
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

# For tree "t" and vertex "u" calculate the
# expected rank and variance
sub expectedrank {
	my ( $t, $u ) = @_;
	my $rp = rankprob( $t, $u );
	my $mu = 0;
	my $sigma = 0;
	for my $i ( 0 .. $#{ $rp } ) {
		$mu += $i * $rp->[$i];
		$sigma += $i * $i * $rp->[$i];
	}
	return $mu, $sigma - $mu * $mu;
}

# Gives the probability that vertex labeled v is
# below vertex labeled u
# XXX test me
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
	my $x = rankprob($subtree_u,$u);
	my $y = rankprob($subtree_v,$v);
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
my $result = compare($t4,5,4);
print $result;