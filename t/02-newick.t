# $Id: 02-newick.t 838 2009-03-04 20:47:20Z rvos $
use strict;

#use warnings;
use Test::More 'no_plan';
use Bio::Phylo;
use Bio::Phylo::IO qw(parse);

my $string = '(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B):1):1):1):1):1):1):0;';
ok( my $phylo = Bio::Phylo->new, '1 init' );
ok( !Bio::Phylo->VERBOSE( -level => 0 ), '2 set terse' );
ok( Bio::Phylo::IO->parse( -string => $string, -format => 'newick' ),
    '3 parse' );

# we need to be able to parse single and double quoted strings correctly
my $quoted = q{(A,'B;',C[;]);};

my $tree = parse(
    '-string' => $quoted,
    '-format' => 'newick',
)->first;

my %expected = (
    q{A}    => 0,
    q{'B;'} => 0,
    q{C}    => 0, # input is C[;], comment is stripped
);
my $observed = 0;
my $expected_count = scalar keys %expected;
for my $tip ( @{ $tree->get_terminals } ) {
    my $name = $tip->get_name;
    ok( exists $expected{$name}, "$name is parsed correctly" );
    $observed++ if exists $expected{$name};
}
ok( $observed == $expected_count, "all names were recovered correctly" );