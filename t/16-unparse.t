# $Id: 16-unparse.t 1247 2010-03-04 15:47:17Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 5;
use Bio::Phylo::Factory;
use Bio::Phylo::IO qw(parse unparse);
Bio::Phylo->VERBOSE( -level => 0 );
eval { unparse() };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::OddHash' ) );
eval { unparse( 'A', 'B', 'C' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::OddHash' ) );
eval { unparse( -format => 'bogus', -phylo => 'bogus' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ExtensionError' ) );
eval { unparse( -tokkie => 'bogus', -phylo => 'bogus' ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::BadFormat' ) );

# unparse to a handle, to test @fangly's request
my $fac = Bio::Phylo::Factory->new;
my $p = $fac->create_project;
my $t = $fac->create_taxa;
$t->insert( $fac->create_taxon( -name => $_ ) ) for 'A'..'D';
$p->insert( $t );
ok(
    unparse(
        '-format' => 'nexus',
        '-phylo'  => $p,
        '-handle' => \*STDOUT,
    )
);

