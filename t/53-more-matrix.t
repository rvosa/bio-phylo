#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Data::Dumper;
use Bio::Phylo::Matrices::Matrix;

my %data = (
	't1' => '---AGCTACGCATCGACTACGCAGTTT--',
	't2' => '--AAGCTACGCATCGACTTCGCAGATTA-',
	't3' => '-TTAG--ACGC---GTCTTcgcagattaa',
	't4' => '-TTAGCTTCGTATCGTCTAGgcagattaa',
); #         giuiiiiuiiuiiiisiisuiiiiuiiii g=gap, i=invariant, u=uninformative, s=segragating
#            01234567890123456789012345678
#                      1         2

my $matrix = Bio::Phylo::Matrices::Matrix->new(
	'-type' => 'dna',
	'-raw'  => [ map { [ $_, split //, $data{$_} ] } keys %data ],
);

# should be all columns with zero '-' symbols
{
	my @obs = @{ $matrix->get_ungapped_columns };
	my @exp = ( 3, 4, 7, 8, 9, 10, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 );
	is_deeply( \@obs, \@exp );
}

# should be all columns with the same state
{
	my @obs = @{ $matrix->get_invariant_columns };
	my @exp = ( 1, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 16, 17, 20, 21, 22, 23, 25, 26, 27, 28 );
	is_deeply( \@obs, \@exp );
}

# now also count gaps
{
	my @obs = @{ $matrix->get_invariant_columns( '-gap' => 1 ) };
	my @exp = ( 0, 3, 4, 8, 9, 14, 16, 17, 20, 21, 22, 23, 25, 26 );
	is_deeply( \@obs, \@exp );
}