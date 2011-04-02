use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO qw(parse);

my ( $matrix, $proj );
my $string = <<PHYLIP;
4 2
Species_1 AC
Species_2 AG
Species_3 GT
Species_4 GG
PHYLIP

my @names = (
	'Species_1 ',
	'Species_2 ',
	'Species_3 ',
	'Species_4 ',
);

$matrix = parse(
	'-handle' => \*DATA,
	'-format' => 'phylip',
	'-type'   => 'dna',
)->[0];

isa_ok( $matrix, 'Bio::Phylo::Matrices::Matrix' );
is( $matrix->get_ntax, 4 );
is( $matrix->get_nchar, 2 );
like( $matrix->get_type, qr/dna/i );
isa_ok( $matrix->get_by_name('Species_1 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_2 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_3 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_4 '), 'Bio::Phylo::Matrices::Datum' );

$proj = parse(
	'-string' => $string,
	'-format' => 'phylip',
	'-type'   => 'dna',
	'-as_project' => 1,
);

isa_ok( $proj, 'Bio::Phylo::Project' );
$matrix = $proj->get_matrices->[0];
isa_ok( $matrix, 'Bio::Phylo::Matrices::Matrix' );
is( $matrix->get_ntax, 4 );
is( $matrix->get_nchar, 2 );
isa_ok( $matrix->get_by_name('Species_1 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_2 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_3 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_4 '), 'Bio::Phylo::Matrices::Datum' );

$matrix = parse(
	'-string' => $string,
	'-format' => 'phylip',
	'-type'   => 'dna',
)->[0];

isa_ok( $matrix, 'Bio::Phylo::Matrices::Matrix' );
is( $matrix->get_ntax, 4 );
is( $matrix->get_nchar, 2 );
like( $matrix->get_type, qr/dna/i );
isa_ok( $matrix->get_by_name('Species_1 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_2 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_3 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_4 '), 'Bio::Phylo::Matrices::Datum' );

$proj = parse(
	'-string' => $string,
	'-format' => 'phylip',
	'-type'   => 'dna',
	'-as_project' => 1,
);

isa_ok( $proj, 'Bio::Phylo::Project' );
$matrix = $proj->get_matrices->[0];
isa_ok( $matrix, 'Bio::Phylo::Matrices::Matrix' );
is( $matrix->get_ntax, 4 );
is( $matrix->get_nchar, 2 );
like( $matrix->get_type, qr/dna/i );
isa_ok( $matrix->get_by_name('Species_1 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_2 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_3 '), 'Bio::Phylo::Matrices::Datum' );
isa_ok( $matrix->get_by_name('Species_4 '), 'Bio::Phylo::Matrices::Datum' );

__DATA__
4 2
Species_1 AC
Species_2 AG
Species_3 GT
Species_4 GG