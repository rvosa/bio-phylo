#!/usr/bin/perl
use strict;
use Test::More 'no_plan';
use Bio::Phylo::Models::Substitution::Dna;

require_ok('Bio::Phylo::Models::Substitution::Dna');
my $model = Bio::Phylo::Models::Substitution::Dna->new(
    '-type'   => 'GTR',
    '-pi'     => [ 0.23, 0.27, 0.24, 0.26 ],
    '-kappa'  => 2,
    '-alpha'  => 0.9,
    '-pinvar' => 0.5,
    '-ncat'   => 6,
    '-median' => 1,
    '-rate'   => [
        [ 0.23, 0.23, 0.23, 0.23 ],
        [ 0.23, 0.26, 0.26, 0.26 ],
        [ 0.27, 0.26, 0.26, 0.26 ],
        [ 0.24, 0.26, 0.26, 0.26 ]
    ]
);
is( $model->get_alpha, 0.9 );
is( $model->get_kappa, 2 );
ok( $model->get_median );
is( $model->get_ncat,   6 );
is( $model->get_pinvar, 0.5 );
ok( $model->to_string( '-format' => 'garli' ) );
