# $Id: 10-matrices.t 1247 2010-03-04 15:47:17Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 10;
use Bio::Phylo;
use Bio::Phylo::Matrices;
use Bio::Phylo::Matrices::Matrix;
use Bio::Phylo::Matrices::Datum;
use Bio::Phylo::Taxa;
use Bio::Phylo::Taxa::Taxon;
ok( my $matrices = new Bio::Phylo::Matrices, '1 initialize obj' );
$matrices->VERBOSE( -level => 0 );
eval { $matrices->insert };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '2 insert empty' );
eval { $matrices->insert('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '3 insert bad' );
ok( $matrices->insert( new Bio::Phylo::Matrices::Matrix ), '4 insert good' );
ok( $matrices->get_entities,                               '5 get matrices' );
ok( $matrices->_container,                                 '6 container' );
ok( $matrices->_type,                                      '7 container_type' );
my $taxon1 = Bio::Phylo::Taxa::Taxon->new( '-name' => 'taxon1' );
my $taxon2 = Bio::Phylo::Taxa::Taxon->new( '-name' => 'taxon2' );
my $taxa   = Bio::Phylo::Taxa->new;
$taxa->insert($taxon1)->insert($taxon2);
my $datum1 = Bio::Phylo::Matrices::Datum->new( '-taxon' => $taxon1 );
my $datum3 = Bio::Phylo::Matrices::Datum->new( '-taxon' => $taxon2 );
$datum1->set_type('DNA');
$datum3->set_type('DNA');
my $matrix = Bio::Phylo::Matrices::Matrix->new( '-type' => 'DNA' );
eval { $matrix->insert($datum1)->insert($datum3); };

if ($@) {
    print $@->trace->as_string;
}
ok( $matrix->cross_reference($taxa), '8 cross ref m -> t' );
eval { $matrix->cross_reference('BAD') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::ObjectMismatch'),
    '9 cross ref m -> t' );
ok(
    $matrix->get_by_regular_expression(
        -value => 'get_name',
        -match => qr/^taxon1$/
    ),
    '10 get by regular expression'
);
