package Bio::Phylo::Util::Math;
use strict;
use base 'Exporter';

BEGIN {
    our ( @EXPORT_OK, %EXPORT_TAGS );
    @EXPORT_OK = qw(nchoose gcd gcd_divide);
    %EXPORT_TAGS = (
        'all' => [@EXPORT_OK],
    );
}

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


1;