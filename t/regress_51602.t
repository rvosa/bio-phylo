use Bio::Phylo::IO 'parse';
use Test::More 'no_plan';
use strict;
my $string =
"((A:0.33139,B:0.29208):0.04409,(C:0.28550,D:0.28440):0.03647,(E:0.35068,F:0.38974):0.03419);";
my $observed = parse(
    '-format' => 'newick',
    '-string' => $string
)->first;
$observed->keep_tips(
    $observed->get_by_regular_expression(
        '-value' => 'get_name',
        '-match' => qr/^(?:A|B)$/,
    )
);
my $expected = parse(
    '-format' => 'newick',
    '-string' => $string
)->first->keep_tips( [ 'A', 'B' ] );
ok(
    $observed->calc_symdiff($expected) == 0,
    'can use either names or objects as input'
);
