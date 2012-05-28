use strict;

use warnings;
use Test::More tests => 47;
use Bio::Phylo;
use Bio::Phylo::IO qw(parse);
use Bio::Phylo::Parsers::Newick;




# Newick tree taken from http://en.wikipedia.org/wiki/Newick_format
my @trees = (
    '(,(,));',                         # no nodes are named
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

my @id_sets = (
    ['C'],
    ['A', 'C'],
    ['C', 'D'],
    ['A', 'C', 'D'],
);

# Test parsing with filtering hooked up to it
my $string = '(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B):1):1):1):1):1):1):0;';
ok( my $phylo = Bio::Phylo->new, 'Init' );
ok( !Bio::Phylo->VERBOSE( -level => 0 ), 'Set terse' );
ok( my $tree = Bio::Phylo::IO->parse(
    -string   => $string,
    -format   => 'newick',
    -simplify => $id_sets[0]
)->first, 'Parse' );
is $tree->calc_number_of_terminals, 1;

# Test many tree combinations and IDs
is Bio::Phylo::Parsers::Newick::_simplify( $trees[0], $id_sets[0] ), ';', 'Simplify';
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

is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[0] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[1] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[2] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[4], $id_sets[3] ), ';';

is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[0] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[1] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[2] ), ';';
is Bio::Phylo::Parsers::Newick::_simplify( $trees[5], $id_sets[3] ), ';';

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
