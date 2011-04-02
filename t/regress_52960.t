use strict;
use warnings;
use Bio::Phylo::IO 'parse';
use Test::More 'no_plan';
my $input_newick = '(((cat:5,dog:5):10,cow:15):3,(human:6,chimp:6):12):4;';
my $input_tree   = parse(
    '-format' => 'newick',
    '-string' => $input_newick,
)->first;
my $expected_newick =
  '((human:6.000000,chimp:6.000000):12.000000,cow:18.000000):4.000000;';
my $expected_tree = parse(
    '-format' => 'newick',
    '-string' => $expected_newick,
)->first;
my $observed_tree = $input_tree->prune_tips( [ 'cat', 'dog' ] );
my $observed_branch_length =
  $observed_tree->get_by_name('cow')->get_branch_length;
my $expected_branch_length = 18;
ok( $expected_tree->calc_symdiff($observed_tree) == 0,
    'topology as expected after pruning' );
ok( $observed_branch_length == $expected_branch_length,
    'branch length adjusted as expected' );
