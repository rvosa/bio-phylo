use strict;

use warnings;
use Test::More tests => 59;
use Bio::Phylo;
use Bio::Phylo::IO qw(parse);
use Bio::Phylo::Parsers::Newick;

my ($string, @trees, @id_sets);


# Newick tree taken from http://en.wikipedia.org/wiki/Newick_format
@trees = (
    '(,(,));',                          # no nodes are named
    '(A,(C,D));',                       # leaf nodes are named
    '((C,D),A);',
    '(A,(C,D)E)F;',                     # all nodes are named
    '(:0.1,(:0.3,:0.4):0.5);',          # all but root node have a distance to parent
    '(:0.1,(:0.3,:0.4):0.5):0.0;',      # all have a distance to parent
    '(A:0.1,(C:0.3,D:0.4):0.5);',       # distances and leaf names (popular)
    '((C:0.3,D:0.4):0.5,A:0.1);',
    "(A :0.1,  (C:0.3,\nD:0.4): 0.5);", # extra one with spaces and newline
    '(A:0.1,(C:0.3,D:0.4)E:0.5)F;',     # distances and all names
);

@id_sets = (
    ['C'],
    ['A', 'C'],
    ['C', 'D'],
    ['A', 'C', 'D'],
);


# Test parsing with filtering hooked up to it
$string = '(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B):1):1):1):1):1):1):0;';
ok( my $phylo = Bio::Phylo->new, 'Init' );
ok( !Bio::Phylo->VERBOSE( -level => 0 ), 'Set terse' );
ok( my $tree = Bio::Phylo::IO->parse(
    -string => $string,
    -format => 'newick',
    -keep   => $id_sets[0]
)->first, 'Parse' );
is $tree->calc_number_of_terminals, 1;


# Test many tree combinations and IDs
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), ';', 'Prune cherries';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[1] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[2] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[3] ), ';';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[1], $id_sets[0] ), 'C;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[1], $id_sets[1] ), '(A,C);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[1], $id_sets[2] ), '(A,(C,D));';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[1], $id_sets[3] ), '(A,(C,D));';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[2], $id_sets[0] ), 'C;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[2], $id_sets[1] ), '(C,A);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[2], $id_sets[2] ), '((C,D),A);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[2], $id_sets[3] ), '((C,D),A);';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[3], $id_sets[0] ), 'C;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[3], $id_sets[1] ), '(A,C)F;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[3], $id_sets[2] ), '(A,(C,D)E)F;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[3], $id_sets[3] ), '(A,(C,D)E)F;';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[0] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[1] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[2] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[3] ), ':0.9;';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[0] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[1] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[2] ), ':0.9;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[3] ), ':0.9;';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[6], $id_sets[0] ), 'C:0.8;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[6], $id_sets[1] ), '(A:0.1,C:0.8);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[6], $id_sets[2] ), '(A:0.1,(C:0.3,D:0.4):0.5);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[6], $id_sets[3] ), '(A:0.1,(C:0.3,D:0.4):0.5);';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[7], $id_sets[0] ), 'C:0.8;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[7], $id_sets[1] ), '(C:0.8,A:0.1);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[7], $id_sets[2] ), '((C:0.3,D:0.4):0.5,A:0.1);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[7], $id_sets[3] ), '((C:0.3,D:0.4):0.5,A:0.1);';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[8], $id_sets[0] ), 'C:0.8;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[8], $id_sets[1] ), '(A:0.1,C:0.8);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[8], $id_sets[2] ), '(A:0.1,(C:0.3,D:0.4):0.5);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[8], $id_sets[3] ), '(A:0.1,(C:0.3,D:0.4):0.5);';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[9], $id_sets[0] ), 'C:0.8;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[9], $id_sets[1] ), '(A:0.1,C:0.8)F;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[9], $id_sets[2] ), '(A:0.1,(C:0.3,D:0.4)E:0.5)F;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[9], $id_sets[3] ), '(A:0.1,(C:0.3,D:0.4)E:0.5)F;';


# More tests
@trees = (
    '((306079:0.00097,325180:0.00014)100:0.00014,333214:0.00014);',
);
@id_sets = (
    ['306079'],
    ['333214'],
    ['306079', '325180'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), '306079:0.00111;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[1] ), '333214:0.00014;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[2] ), '((306079:0.00097,325180:0.00014)100:0.00014,333214:0.00014);';


@trees = (
  '(
     (
       (
         (
           105195:0.00236,
           160607:0.00087
         )100:0.00014,
         160883:0.00014
       )87:0.00014,
       159733:0.00014
     )88:0.00014,
     (
       159778:0.00000,
       161492:0.00000
     )100:0.00014
   )100:0.00014;'
);
@id_sets = (
    ['159778'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), '159778:0.00028;';


# With explicit distance of 0.000
@trees = (
    '(((246444:0.00000,246445:0.00000)0:0.00000,246443:0.00000)0:0.00000,246442:0.00000);',
);
@id_sets = (
    ['246444', '246445'],
    ['246442', '246443'],
    ['246442'],
    ['246442', '246445'],
    ['246444'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), '(((246444:0.00000,246445:0.00000)0:0.00000,246443:0.00000)0:0.00000,246442:0.00000);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[1] ), '(246443:0,246442:0.00000);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[2] ), '246442:0;';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[3] ), '(246445:0,246442:0.00000);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[4] ), '246444:0;';


@trees = (
    '((307310:0.00337,354287:0.00938)100:0.00097,330146:0.00337)100:0.00150;'
);
@id_sets = (
    ['330146'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), '330146:0.00487;';


# Make sure that ternary branches are not altered
@trees = (
    '(A,B,C);',
);
@id_sets = (
  ['B'],
  ['B','C'],
  ['B','C','A'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), '(A,B,C);', 'Leave ternaries alone';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[1] ), '(A,B,C);';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[2] ), '(A,B,C);';


# Make sure that quoted nodes are not altered

@trees = (
  "(A,(B,C)'100:s__Shigella dysenteriae':0.00155);",
);
@id_sets = (
  ['A', 'B'],
);
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ),  "(A,B:0.00155);", 'Handle quoted names';


@trees = (
  "((((((((((((((((((168839:0,146647:0.00000)0:0.00000,140635:0.00000)0:0.00000,140612:0.00000)0:0.00000,140570:0.00000)0:0.00000,140563:0.00000)0:0.00000,129310:0.00000)0:0.00000,129308:0.00000)0:0.00000,129306:0.00000)0:0.00000,129304:0.00000)0:0.00000,128448:0.00000)0:0.00000,128445:0.00000)0:0.00000,128443:0.00000)0:0.00000,128441:0.00000)100:0.00014,168834:0.00077)100:0.00014,168833:0.00078)'100:s__Shigellaflexneri':0.00077,169667:0.00247)0:0.00014,9702:0.00091)0:0.00014,((141642:0,141640:0.00000)'100:s__Shigelladysenteriae':0.00155,9664:0.00077)23:0.00014)0:0.00014;",
);

@id_sets = (
  ['168839', '128448', '129310'],
);

is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ),  "(((((((((((((168839:0,129310:0.00000)0:0.00000,129308:0.00000)0:0.00000,129306:0.00000)0:0.00000,129304:0.00000)0:0.00000,128448:0.00000)0:0.00000,128445:0.00000)0:0.00000,128443:0.00000)0:0.00000,128441:0.00000)100:0.00014,168834:0.00077)100:0.00014,168833:0.00078)'100:s__Shigellaflexneri':0.00077,169667:0.00247)0:0.00014,9702:0.00091)0:0.00014,9664:0.00091)0:0.00014;";

