# $Id$
use strict;
#use warnings;
use Test::More tests => 6;
use Bio::Phylo::IO qw(parse unparse);

my $data;
while (<DATA>) {
    $data .= $_;
}

ok( my $trees = parse(
    -string => $data,
    -format => 'newick' ),
'1 parse newick string' );

ok( my $treeset = $trees->get_entities, '2 get trees' );

ok( unparse(
    -phylo => $treeset->[0],
    -format => 'newick' ) . "\n",
'3 unparse first tree as newick' );

ok( unparse(
    -phylo => $treeset->[1],
    -format => 'newick' ) . "\n",
'4 unparse second tree as newick' );

ok( unparse(
    -phylo => $treeset->[0],
    -format => 'pagel' ) . "\n",
'5 unparse first tree as pagel' );

ok( unparse(
    -phylo => $treeset->[1],
    -format => 'pagel' ) . "\n",
'6 unparse second tree as pagel' );

__DATA__
(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B:1):1):1):1):1):1):1):1;
(((A,B),(C,D,E,F))no_prev,((G,H),(I,J)));
