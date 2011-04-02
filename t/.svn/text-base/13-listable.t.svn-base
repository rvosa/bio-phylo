# $Id$
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More tests => 7;
use Bio::Phylo;
use Bio::Phylo::Taxa;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::Forest;
use Bio::Phylo::Forest::Tree;
use Bio::Phylo::Forest::Node;
ok( my $listable = Bio::Phylo::Listable->new, '1 initialize object' );

my $trees = Bio::Phylo::Forest->new;
my $tree = Bio::Phylo::Forest::Tree->new;
$trees->insert($tree);

my $taxa  = Bio::Phylo::Taxa->new;
my $taxon = Bio::Phylo::Taxa::Taxon->new;
$taxa->insert($taxon);

eval { $trees->cross_reference($taxa) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '2 bad crossref' );

eval { $taxa->cross_reference($taxa) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),  '3 bad crossref' );

eval { $taxa->insert($tree) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),'4 insert obj bad' );

ok( $trees->first,                   '5 get first tree' );
ok( $trees->last,                    '6 get last tree' );
ok( $tree->cross_reference($taxa),   '7 good crossref' );
