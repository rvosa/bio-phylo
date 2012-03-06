# $Id: 12-taxa.t 1247 2010-03-04 15:47:17Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More 'no_plan';
use Bio::Phylo::Taxa;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::CONSTANT ':namespaces';

ok( my $taxa = new Bio::Phylo::Taxa, '1 initialize object' );
$taxa->VERBOSE( -level => 0 );
eval { $taxa->insert('Bad!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '2 insert bad object' );
ok( $taxa->_container, '3 container' );
ok( $taxa->_type,      '4 container_type' );

my $fac = Bio::Phylo::Factory->new;
my $ts1 = $fac->create_taxa;
my $ts2 = $fac->create_taxa;

for my $i ( 1 .. 10 ) {
    my $t1 = $fac->create_taxon;
    $t1->add_meta(
        $fac->create_meta(
            '-namespaces' => { 'dc' => _NS_DC_ },
            '-triple' => { 'dc:identifier' => $i },
        ),
    ),
    $ts1->insert($t1);

    my $t2 = $fac->create_taxon;
    $t2->add_meta(
        $fac->create_meta(
            '-namespaces' => { 'dc' => _NS_DC_ },
            '-triple' => { 'dc:identifier' => $i },
        ),
    ),
    $ts2->insert($t2);    
}

my $merged = $ts1->merge_by_meta('dc:identifier', $ts2);
ok( $merged->get_ntax == 10, "5 merge by predicate value" );

warn $merged->to_xml;