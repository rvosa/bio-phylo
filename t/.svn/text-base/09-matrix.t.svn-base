# $Id$
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More 'no_plan';
use Bio::Phylo::Matrices::Datum;
use Bio::Phylo::Matrices::Matrix;
use Bio::Phylo;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::Taxa;

ok( my $matrix = Bio::Phylo::Matrices::Matrix->new( -type => 'STANDARD' ), '1 initialize' );

$matrix->VERBOSE( -level => 0 );

eval { $matrix->insert('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '2 insert bad data' );

my $datum = Bio::Phylo::Matrices::Datum->new;
my $taxon = Bio::Phylo::Taxa::Taxon->new;
my $taxa  = Bio::Phylo::Taxa->new;
$datum->set_name('datum');
$datum->set_type('STANDARD');
$datum->set_char('5');
$datum->set_taxon( $taxon );
$taxa->insert( $taxon );
$matrix->set_taxa( $taxa );

ok( $matrix->insert($datum), '3 insert good data' );

# the get method
eval { $matrix->get('frobnicate') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ), '4 get bad method' );
ok( $matrix->get('get_entities'), '5 get good method' );

# the get_data method
ok( $matrix->get_entities, '6 get data' );

# the get_by_value method
ok( $matrix->get_by_value( -value => 'get_char', -lt => 6 ),
    '7 get by value lt' );
ok( $matrix->get_by_value( -value => 'get_char', -le => 5 ),
    '8 get by value le' );
ok( $matrix->get_by_value( -value => 'get_char', -gt => 4 ),
    '9 get by value gt' );
ok( $matrix->get_by_value( -value => 'get_char', -ge => 5 ),
    '10 get by value ge' );
ok( $matrix->get_by_value( -value => 'get_char', -eq => 5 ),
    '11 get by value eq' );
ok( ! scalar @{$matrix->get_by_value( -value => 'get_char', -lt => 4 )},
    '12 get by value lt' );
ok( ! scalar @{$matrix->get_by_value( -value => 'get_char', -le => 4 )},
    '13 get by value le' );
ok( ! scalar @{$matrix->get_by_value( -value => 'get_char', -gt => 6 )},
    '14 get by value gt' );
ok( ! scalar @{$matrix->get_by_value( -value => 'get_char', -ge => 6 )},
    '15 get by value ge' );
ok( ! scalar @{$matrix->get_by_value( -value => 'get_char', -eq => 6 )},
    '16 get by value eq' );

eval { $matrix->get_by_value( -value => 'frobnicate', -lt => 4 ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '17 get by value lt' );

eval { $matrix->get_by_value( -value => 'frobnicate', -le => 4 ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '18 get by value le' );

eval { $matrix->get_by_value( -value => 'frobnicate', -gt => 6 ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '19 get by value gt' );

eval { $matrix->get_by_value( -value => 'frobnicate', -ge => 6 ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '20 get by value ge' );

eval { $matrix->get_by_value( -value => 'frobnicate', -eq => 6 ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '21 get by value eq' );
ok(
    $matrix->get_by_regular_expression(
        -value => 'get_type',
        -match => qr/^STANDARD$/
    ),
    '22 get by re'
);


eval { $matrix->get_by_regular_expression(
    -value => 'frobnicate',
    -match => qr/^STANDARD$/
    )
};

ok(
    looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '23 get by re'
);
ok(
    ! scalar @{$matrix->get_by_regular_expression(
        -value => 'get_type',
        -match => qr/^DNA$/
    )},
    '24 get by re'
);
eval { $matrix->get_by_regular_expression(
    -value      => 'get_type',
    -frobnicate => qr/^DNA$/)
};
ok(
    looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::BadArgs' ),
    '25 get by re'
);
ok( $matrix->DESTROY, '26 destroy' );
ok( 
    Bio::Phylo::Matrices::Matrix->new(
        -type   => 'standard',
        -lookup => {
            '-' => [],
            '1' => [ '1' ],
            '2' => [ '2' ],
            '3' => [ '3' ],
            '?' => [ '1', '2', '3' ],            
        },
        -matrix => [
            [ 'a' => 1, 1, 1 ],
            [ 'b' => 2, 2, 2 ],
            [ 'c' => 3, 3, 3 ],
        ],
    )->to_nexus,
    '27 expanded constructor'
);

my $prune_candidate = Bio::Phylo::Matrices::Matrix->new(
	-type   => 'standard',
	-lookup => {
		'-' => [],
		'1' => [ '1' ],
		'2' => [ '2' ],
		'3' => [ '3' ],
		'?' => [ '1', '2', '3' ],            
	},
	-matrix => [
		[ 'a' => 1, 1, 1 ],
		[ 'b' => 2, 2, 2 ],
		[ 'c' => 3, 3, 3 ],
	],
);

my $pruned = $prune_candidate->prune_chars([0,1]);
ok($pruned->get_nchar == 1,'28 pruning keeps one char');

my $kept = $prune_candidate->keep_chars([2]);
ok($pruned->get_nchar == 1,'29 keeping on char');

{
    my $dna = Bio::Phylo::Matrices::Matrix->new(
        -type   => 'dna',
        -matrix => [
            [ 'a' => qw(A C G T) ],
            [ 'b' => qw(A G C T) ],
            [ 'c' => qw(A C G T) ],
        ],
    );
    like( $dna->get_type, qr/dna/i, '30 created dna matrix' );
    is( $dna->get_nchar, 4, '31 dna matrix has 4 columns');
    is( $dna->get_ntax, 3, '32 dna matrix has 3 rows');
    my $freq = $dna->calc_state_frequencies;
    is( $freq->{$_}, 0.25, "33 state frequency for $_" ) for qw(A C G T);
    my $abs = $dna->calc_state_counts;
    is( $abs->{$_}, 3, "34 state count for $_" ) for qw(A C G T);
    is( $dna->calc_prop_invar, 0.5, "35 half of the sites invariant");
}

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type' => 'dna',
        '-matrix' => [
            [ qw'taxon1 G T G T G T G T G T G T G T G T G T G T G T G' ],
            [ qw'taxon2 A G A G A G A G A G A G A G A G A G A G A G A' ],
            [ qw'taxon3 T C T C T C T C T C T C T C T C T C T C T C T' ],
            [ qw'taxon4 T C T C T C T C T C T C T C T C T C T C T C T' ],
            [ qw'taxon5 A A A A A A A A A A A A A A A A A A A A A A A' ],
            [ qw'taxon6 C G C G C G C G C G C G C G C G C G C G C G C' ],
            [ qw'taxon7 A A A A A A A A A A A A A A A A A A A A A A A' ],
        ]
    );
    my $expected = [
	[ 12, [ 'G', 'A', 'T', 'T', 'A', 'C', 'A' ] ],
	[ 11, [ 'T', 'G', 'C', 'C', 'A', 'G', 'A' ] ],
    ];
    is_deeply( $matrix->calc_distinct_site_patterns, $expected, "36 site patterns" );
}

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type' => 'dna',
        '-matrix' => [
            [ qw'taxon1 A C G T C G' ],
            [ qw'taxon2 A C G T C G' ],
        ]
    );
    is( $matrix->calc_gc_content, 2/3, '37 calc G+C content');
}

{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type' => 'dna',
        '-matrix' => [
            [ qw'taxon1 A C G T C G' ],
            [ qw'taxon2 A C G T C G' ],
        ],
        '-charlabels' => [ qw'c1 c2 c3 c4 c5 c6' ]
    );
    my $char  = $matrix->get_characters;
    my @chars = @{ $char->get_entities };
    is( scalar @chars, 6, '38 characters created' );
    for my $c ( @chars ) {
        isa_ok( $c, 'Bio::Phylo::Matrices::Character', '39 characters right type' );    
    }    
}