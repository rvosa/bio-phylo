# $Id: 17-parse.t 1247 2010-03-04 15:47:17Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 7;
use Bio::Phylo::IO qw(parse unparse);
eval { parse() };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::OddHash' ),
    '1 parse no opts' );
eval { parse( 'A', 'B', 'C' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::OddHash' ),
    '2 parse wrong args' );
eval { parse( -format => 'none' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::BadArgs' ),
    '3 parse bad format' );
ok( parse( -format => 'nexus', -string => 'blah' ), '4 parse string' );
eval { parse( -string => 'blah' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::BadArgs' ),
    '5 parse no format' );
my $taxa = 'A|B|C|D|E';
ok( parse( -format => 'taxlist', -fieldsep => '|', -string => $taxa ),
    '6 parse taxon list' );
eval { parse( '-handle' => \*DATA, '-format' => 'newick' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::NoData' ),
    '7 parse no data' );
__DATA__