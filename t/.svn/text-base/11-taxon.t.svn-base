# $Id$
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 14;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::Forest;
use Bio::Phylo::Forest::Node;
use Bio::Phylo::Matrices::Datum;
ok( my $taxon = new Bio::Phylo::Taxa::Taxon, '1 initialize object' );
$taxon->VERBOSE( -level => 0 );
ok( $taxon->set_desc('This is a taxon description'), '2 enter description' );
ok( $taxon->get_desc,                                '3 fetch description' );

eval { $taxon->set_name(':') };
ok( $taxon->get_name eq ':', '4 enter bad name' );

ok( $taxon->_container,                              '5 container' );
ok( $taxon->_type,                                   '6 container type' );
ok( $taxon->set_data( new Bio::Phylo::Matrices::Datum ),  '7 insert good data' );

eval { $taxon->set_data('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '8 insert bad data' );

ok( $taxon->get_data,                                '9 get data' );
ok( $taxon->set_nodes( new Bio::Phylo::Forest::Node ),'10 insert good node' );

eval { $taxon->set_nodes('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '11 insert bad node' );

ok( $taxon->get_nodes,                               '12 get nodes' );

eval { $taxon->set_data( new Bio::Phylo::Forest ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '13 insert bad data' );

eval { $taxon->set_nodes( new Bio::Phylo::Forest ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '14 insert bad nodes' );
