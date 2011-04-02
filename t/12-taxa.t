# $Id: 12-taxa.t 1247 2010-03-04 15:47:17Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 4;
use Bio::Phylo::Taxa;
ok( my $taxa = new Bio::Phylo::Taxa, '1 initialize object' );
$taxa->VERBOSE( -level => 0 );
eval { $taxa->insert('Bad!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '2 insert bad object' );
ok( $taxa->_container, '3 container' );
ok( $taxa->_type,      '4 container_type' );
