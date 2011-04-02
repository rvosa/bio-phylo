# $Id$
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More 'no_plan';
use Bio::Phylo::IO qw(parse unparse);
use Bio::Phylo::Forest::Node;
use Bio::Phylo::Taxa::Taxon;
my $data;

while (<DATA>) {
    $data .= $_;
}
Bio::Phylo->VERBOSE( -level => 0 );
ok( 1, '1 init' );
ok( my $trees = parse( -string => $data, -format => 'newick' ),
    '2 parse' );
ok( my @trees      = @{ $trees->get_entities },    '3 get trees' );
ok( my $tree       = $trees[0],                    '4 pick first tree' );
ok( my $root       = $tree->get_root,              '5 get root' );
ok( my $node       = $root->get_first_daughter,    '6 get first daughter' );
ok( my $other_node = $root->get_last_daughter,     '7 get last daughter' );
ok( my $left_tip   = $root->get_leftmost_terminal, '8 get leftmost terminal' );
ok( my $right_tip = $root->get_rightmost_terminal, '9 get rightmost terminal' );
ok( my @sisters   = @{ $root->get_children },      '10 get children' );
ok( my @tips      = @{ $right_tip->get_sisters },  '11 get sisters' );
ok( !$left_tip->is_sister_of($right_tip),          '12 ! is sister of' );

eval { $node->get('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::UnknownMethod' ),'13 ! get ' );

eval { $node->set_name(':();,') };
ok( $node->get_name eq ':();,',    '14 ! name ' );

eval { $node->set_branch_length('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::BadNumber' ),    '15 ! branch_length ' );

ok( !$node->is_internal,                         '16 ! is internal' );
ok( !$node->is_sister_of($root),                 '17 ! is sister of' );
ok( !$node->is_outgroup_of( \@sisters ),         '18 ! is outgroup of' );
ok( $node->is_outgroup_of( \@tips ),             '19 ! is outgroup of' );
ok( $node->get_ancestors,                        '20 get ancestors' );
ok( $node->get_sisters,                          '21 get sisters' );
ok( $node->is_sister_of($other_node),            '22 is sister of' );
ok( $node->get_mrca($node),                      '23 get mrca' );
ok( $node->get_leftmost_terminal,                '24 get leftmost terminal' );
ok( $node->get_rightmost_terminal,               '25 get rightmost terminal' );
ok( $node->calc_nodes_to_root,                   '26 calc nodes to root' );
ok( $node->calc_patristic_distance($other_node), '27 calc patristic distance' );
ok( $node->get('get_branch_length'),             '28 get branch length' );
ok( !$root->get_ancestors,                       '29 ! get ancestors' );
ok( !$root->is_sister_of($node),                 '30 ! is sister of' );

eval { $root->set_parent('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '31 ! parent' );

eval { $root->set_first_daughter('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '32 ! first daughter' );

eval { $root->set_last_daughter('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '33 ! last daughter' );

eval { $root->set_next_sister('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '34 ! next sister' );

eval { $root->set_previous_sister('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '35 ! previous sister' );

ok( $root->set_parent(undef),                    '36 ! parent' );
ok( $root->get_children,                         '37 get children' );
ok( $root->get_descendants,                      '38 get descendants' );
ok( $root->get_terminals,                        '39 get terminals' );
ok( $root->get_internals,                        '40 get internals' );
ok( $tree->get_root->calc_max_nodes_to_tips,     '41 calc max nodes to tips' );
ok( $tree->get_root->calc_min_nodes_to_tips,     '42 calc min nodes to tips' );
ok( $tree->get_root->calc_max_path_to_tips,      '43 calc max path to tips' );
ok( $tree->get_root->calc_min_path_to_tips,      '44 calc min path to tips' );
ok( my $nobltree = $trees[2],                    '45 get tree without branch lengths' );
ok( $root = $nobltree->get_root,                 '46 get new root' );
ok( !$root->calc_max_path_to_tips,               '47 calc max path to tips' );
ok( my $lmt = $root->get_leftmost_terminal,      '48 get leftmost terminal' );
ok( my $rmt = $root->get_rightmost_terminal,     '49 get rightmost terminal' );
ok( !$lmt->calc_patristic_distance($rmt),        '50 calc patristic distance' );
ok( $tree = $trees[2],                           '51 pick tree without branch lengths' );
ok( $root = $tree->get_root,                     '52 get new root' );
ok( !$root->calc_min_path_to_tips,               '53 calc min path to tips' );
ok( my $bigtree = $trees[4],                     '54 pick big tree' );
ok( my $bigroot = $bigtree->get_root,            '55 get root' );
ok( $bigroot->calc_min_nodes_to_tips,            '56 calc min nodes to tips' );
ok( $lmt = $bigroot->get_leftmost_terminal,      '57 get leftmost terminal' );
ok( $rmt = $bigroot->get_rightmost_terminal,     '58 get rightmost terminal' );
ok( !$lmt->is_descendant_of($rmt),               '59 is descendant of' );

my $node1 = new Bio::Phylo::Forest::Node;
my $node2 = new Bio::Phylo::Forest::Node;
my $node3 = new Bio::Phylo::Forest::Node;
$node1->set_parent($node2);
ok( $node1->get_mrca($node3)->get_id == $node2->get_id, '60 is descendant of' );
ok( !$node1->get_taxon,                           '61 get no taxon' );

eval { $node1->set_taxon('BAD!') };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '62 set bad taxon' );
undef($@);

ok( $node1->set_taxon( Bio::Phylo::Taxa::Taxon->new ),  '63 set good taxon' );

eval { $node1->set_taxon( Bio::Phylo::Forest::Node->new ) };
ok( looks_like_instance( $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' ), '64 set bad taxon' );
undef($@);

ok( $node->_container,                            '65 get container' );
ok( $node->_type,                                 '66 get container type' );
ok( $root->set_parent(),                          '67 remove parent' );
ok( $root->set_next_sister(),                     '68 remove next sister' );
ok( $root->set_previous_sister(),                 '69 remove previous sister' );
ok( $root->set_first_daughter(),                  '70 remove first daughter' );
ok( $root->set_last_daughter(),                   '71 remove last daughter' );
ok( $bigroot->to_newick,                          '72 write subtree to newick');
my $H = shift @{ $trees[3]->get_by_regular_expression( 
	'-value' => 'get_name', 
	'-match' => qr/^H$/
) };
$H->set_root_below;
ok( $trees[3]->get_root->get_name eq 'root', '73 reroot tree');

{
    my $newick = '((a,b)n1,c)n2;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    for my $name ( qw(a b c n2) ) {
	my $node = $tree->get_by_name($name);
	ok( ! $node->is_preterminal, '74 is preterminal' );
    }
    my $preterminal = $tree->get_by_name('n1');
    ok( $preterminal->is_preterminal, '75 is preterminal' );
}

{
    my $newick = '(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B:1):1):1):1)sub:1):1):1):0;';
    my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
    my $node = $tree->get_by_name('sub');
    my $subtree1 = $node->get_subtree;
    my $subnewick = $node->to_newick;
    my $subtree2 = parse( '-format' => 'newick', '-string' => $subnewick )->first;
    ok( $subtree1->calc_symdiff($subtree2) == 0, '76 clone subtree' );
}
__DATA__
(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B:1):1):1):1):1):1):1):0;
(H:1,(G:1,(F:1,((C:1,(A:1,B:1):1):1,(D:1,E:1):1):1):1):1):0;
(H,(G,(F,((C,(A,B)),(D,E)))));
((((H,G),(C,(A,B))),(F,D)),E);
((((C,(A,B)),(J,(D,E))),(((F,I),(G,H)),(N,(L,M)))),((K,(Z,(X,Y))),((R,((Q,(O,P)),(U,(S,T)))),(V,W))));
