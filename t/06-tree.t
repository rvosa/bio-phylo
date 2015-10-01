# $Id: 06-tree.t 1621 2011-03-19 15:25:38Z rvos $
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More 'no_plan';
use Bio::Phylo::IO qw(parse unparse);
use Bio::Phylo::Forest::Node;
use Bio::Phylo::Forest::Tree;
my $data;

while (<DATA>) {
    $data .= $_;
}
Bio::Phylo->VERBOSE( -level => 0 );
ok( 1, '1 init' );
ok(
    my $trees = parse(
        -string => $data,
        -format => 'newick'
    ),
    '2 parse'
);
ok( my $treeset = $trees->get_entities, '3 trees' );
my $tree       = $treeset->[0];
my $unresolved = $treeset->[2];
ok( my $root       = $tree->get_root,           '4 get root' );
ok( my $node       = $root->get_first_daughter, '5 get first daughter' );
ok( my $other_node = $root->get_last_daughter,  '6 get last daughter' );
ok( my $children   = $root->get_children,       '7 get children' );

# get
ok( $tree->get('calc_tree_length'), '8 get ctl' );
ok( $tree->get_entities,            '9 get n' );
ok( $tree->get_internals,           '10 get int' );
ok( $tree->get_terminals,           '11 get term' );

#ok($tree->get_by_name('cherry'),                                   '12 gbn');
ok(
    $tree->get_by_value(
        -value => 'get_branch_length',
        -lt    => 0.5
    ),
    '12 get lt'
);
ok(
    $tree->get_by_value(
        -value => 'get_branch_length',
        -eq    => 2
    ),
    '13 get eq'
);
ok(
    $tree->get_by_value(
        -value => 'get_branch_length',
        -le    => 0.4
    ),
    '14 get le'
);
ok(
    $tree->get_by_value(
        -value => 'get_branch_length',
        -ge    => 0.1
    ),
    '15 get ge'
);
ok(
    $tree->get_by_value(
        -value => 'get_branch_length',
        -gt    => 0.2
    ),
    '16 get gt'
);
ok( $tree->is_binary, '17 is binary' );

# methods on unresolved tree
ok( !$unresolved->is_binary,      '18 is binary' );
ok( !$unresolved->is_ultrametric, '19 is ultrametric' );
eval { $unresolved->calc_rohlf_stemminess };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '20 calc rohlf stemminess: ' . ref($@) );
eval { $unresolved->calc_imbalance };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '21 calc imbalance' );
eval { $unresolved->calc_branching_times };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '22 calc branching times' );
eval { $unresolved->calc_ltt };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '23 calc ltt' );
eval { $tree->insert('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '24 insert bad obj' );

# tests
ok( !$tree->is_ultrametric(0.01), '25 is ultrametric' );
ok( !$tree->is_monophyletic( $children, $node ), '26 not monophyletic' );

# test for monophyly
my $poly = $unresolved->get_by_regular_expression(
    -value => 'get_name',
    -match => qr/^poly$/
);
my $e = $unresolved->get_by_regular_expression(
    -value => 'get_name',
    -match => qr/^E$/
);
my $desc = $poly->[0]->get_descendants;
ok( $tree->is_monophyletic( $desc, $e->[0] ), '27 is monophyletic' );

# calculations
ok( $tree->calc_tree_length,         '28 calc tree length' );
ok( $tree->calc_tree_height,         '29 calc tree height' );
ok( $tree->calc_number_of_nodes,     '30 calc num nodes' );
ok( $tree->calc_number_of_terminals, '31 calc num terminals' );
ok( $tree->calc_number_of_internals, '32 calc num internals' );
ok( $tree->calc_total_paths,         '33 calc total paths' );
ok( $tree->calc_redundancy,          '34 calc redundancy' );
ok( $tree->calc_imbalance,           '35 calc imbalance' );

# balance calculation
my $balanced = $treeset->[3];
ok( $tree->calc_imbalance, '36 calc imbalance' );

# ultrametric calculations
ok( $tree = $tree->ultrametricize, '37 ultrametricize' );
ok( $tree->calc_fiala_stemminess, '38 calc fiala stemminess' );
ok( $tree->calc_rohlf_stemminess, '39 calc rohlf stemminess' );
ok( $tree->calc_resolution,       '40 calc resolution' );
ok( $tree->calc_branching_times,  '41 calc branching times' );
ok( $tree->calc_ltt,              '42 calc ltt' );
ok( $tree->scale(10),             '43 scale' );

# testing on undef branch lengths
my $undef = $treeset->[3];
$root = $undef->get_root;
eval { $undef->calc_rohlf_stemminess };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ),
    '44 calc rohlf stemminess: ' . ref($@) );
eval { $undef->get('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),
    '45 bad arg get' );
ok( $undef->calc_imbalance, '46 calc imbalance' );

# trying to create a cyclical tree, no mas!
my $node1    = new Bio::Phylo::Forest::Node;
my $node2    = new Bio::Phylo::Forest::Node;
my $cyclical = new Bio::Phylo::Forest::Tree;
$node1->set_parent($node2);
$node2->set_parent($node1);
$cyclical->insert($node1);
$cyclical->insert($node2);
ok( $cyclical->get_root, '47 no root in cycle' );
ok( $tree->DESTROY,      '48 destroy' );
my $left   = '((((A,B),C),D),E);';
my $right  = '(E,(D,(C,(A,B))));';
my $ladder = parse( '-format' => 'newick', '-string' => $left )->first;
ok( $ladder->ladderize->to_newick eq $right, '49 ladderize '. $ladder->ladderize->to_newick  );
{
    my $n1 = '((C:0,(B:0,A:0):7):3,D:0):0;';
    my $n2 = '(((A:0,B:0):4,C:0):6,D:0):0;';
    my $n3 = '((A,B,C),D);';
    my $t1 = parse( '-format' => 'newick', '-string' => $n1 )->first;
    my $t2 = parse( '-format' => 'newick', '-string' => $n2 )->first;
    my $t3 = parse( '-format' => 'newick', '-string' => $n3 )->first;
    ok( $t1->calc_branch_length_score($t2) == 18, "50 branch length score" );
    ok( $t1->calc_symdiff($t2) == 0,              "51 calc symdiff" );
    ok( $t1->calc_symdiff($t3) == 1,              "52 calc symdiff" );
}
{
    my $newick =
'(((a:100,b:1)n1:1,c:1)n2:1,((((d:1,e:1)n3:1,f:1)n4:1,g:1)n5:1,h:1)n6:1)n7:0;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    my $focal = $tree->get_by_name('b');
    my $farthest_nodal = $focal->get_farthest_node;
    my $fn_name        = $farthest_nodal->get_name;
    ok( ( $fn_name eq 'd' or $fn_name eq 'e' ), "53 farthest by nodal" );
    my $farthest_patristic = $focal->get_farthest_node(1);
    my $fp_name            = $farthest_patristic->get_name;
    ok( $fp_name                      eq 'a',  "54 farthest by patristic" );
    ok( $tree->get_midpoint->get_name eq 'n1', "55 gets midpoint node" );
}
{
    my $newick = '((a:1,b:1)n1:1,c:2)n2:0;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->calc_node_ages;
    is( $tree->get_by_name('n1')->get_generic('age'), 1, "56 calc node age" );
    is( $tree->get_by_name('n2')->get_generic('age'), 2, "57 calc node age" );
}
{
    my $newick = '((a:1,b:1)n1:1,(c:2,d:2))n2:0;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    is( $tree->calc_number_of_cherries, 2, "58 calc number of cherries" );
}
{
    my $newick = '((a:1,b:1)n1:1,(c:2,d:2)n2:1)n3:0;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->chronompl;
    is( $tree->get_by_name('n1')->get_branch_length, 1.5, '59 chronompl' );
    is( $tree->get_by_name('n2')->get_branch_length, 0.5, '60 chronompl' );
}
{
    my $newick = '((((A,B),C),(D,F)),E);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    ok( $tree->is_ultrametric, '61 grafen branch lengths' );
}
{
    my $newick = '((((((A:6,B:6):5,C:11):4,D:15):3,E:18):2,F:20):1,G:21):0;';
    my $tree   = parse( '-format' => 'newick', '-string' => $newick )->first;
    my $bt     = $tree->calc_waiting_times;
    for my $i ( 0 .. $#{$bt} ) {
        is( $bt->[$i]->[1], $i, '62 waiting times' );
    }
}
{
    my $newick = '(a,b,c,d,e,f);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->sort_tips( [qw(a c b f d e)] );
    ok( $tree->to_newick eq '(a,c,b,f,d,e);', '63 star sort' );
}
{
    my $newick = '(a,b,(c,d),e,f);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->sort_tips( [qw(a b d c e f)] );
    ok( $tree->to_newick eq '(a,b,(d,c),e,f);', '64 tip sort' );
}
{
    my $newick = '(a,b,((c,d),e),f);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->sort_tips( [qw(a b e d c f)] );
    ok( $tree->to_newick eq '(a,b,(e,(d,c)),f);', '65 simple ladder sort' );
}
{
    my $newick = '((a,b),((c,d),e),f);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    $tree->sort_tips( [qw(a e d c b f)] );
    ok( $tree->to_newick eq '((e,(d,c)),(a,b),f);', '66 conflict sort' );
}
{
    my $newick = '((a,b),((c,d),e),f);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    my @cherries = @{ $tree->get_cherries };
    ok( scalar(@cherries) == 2, '67 get cherries' );
}

# Try pruning
{
    my $newick = '((A,(C,X)Int1)LUCA);';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    my $root = $tree->get_root->set_name('root');
    my @names = sort map {$_->get_name} @{$tree->get_entities};
    ok( $tree->keep_tips(\@names), 'pruning' );
    my @pruned_names = sort map {$_->get_name} @{$tree->get_entities};
    is_deeply(\@pruned_names, \@names);
    @names = ('A', 'C');
    ok( $tree->keep_tips(\@names) );
    @pruned_names = sort map {$_->get_name} @{$tree->get_entities};
    is_deeply( \@pruned_names, [@names, 'LUCA', 'root']);
}

__DATA__
((H:1,I:1):1,(G:1,(F:0.01,(E:0.3,(D:2,(C:0.1,(A:1,B:1)cherry:1):1):1):1):1):1):0;
(H:1,(G:1,(F:1,((C:1,(A:1,B:1):1):1,(D:1,E:1):1):1):1):1):0;
(H:1,(G:1,(F:1,((C:1,(A:1,I:1,B:1)poly:1):1,(D:1,E:1):1):1):1):1):0;
((((A,B),(C,D)),(E,F)),((G,H),(I,J)));

