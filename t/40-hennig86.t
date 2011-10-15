use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO 'unparse';
use Bio::Phylo::Matrices::Matrix;

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type'   => 'standard',
        '-matrix' => [
            [qw'taxon_1 ? 1 1 1 1'],
            [qw'taxon_2 ? ? 2 1 1'],
            [qw'taxon_3 ? ? 2 2 2'],
            [qw'taxon_4 ? ? 2 2 2'],
            [qw'taxon_5 ? ? ? 2 ?'],
        ],
    );
    my $hennig86 = unparse(
        '-format' => 'hennig86',
        '-phylo'  => $matrix,
    );
    ok($hennig86);
}

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type'   => 'dna',
        '-matrix' => [
            [qw'taxon_1 a c g g t'],
            [qw'taxon_2 a c d b y'],
            [qw'taxon_3 n c a g t'],
            [qw'taxon_4 x g a t t'],
            [qw'taxon_5 y c a g y'],
        ],
    );
    my $hennig86 = unparse(
        '-format' => 'hennig86',
        '-phylo'  => $matrix,
    );
    ok($hennig86);
}

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type'   => 'continuous',
        '-matrix' => [
            [qw'taxon_1 0.234 0.456 0.567'],
            [qw'taxon_2 0.987 0.876 0.654'],
            [qw'taxon_3 0.123 0.345 0.458'],
            [qw'taxon_4 0.923 0.983 0.873'],
            [qw'taxon_5 0.734 0.235 0.456'],
        ],
    );
    my $hennig86 = unparse(
        '-format' => 'hennig86',
        '-phylo'  => $matrix,
    );
    ok($hennig86);
}
