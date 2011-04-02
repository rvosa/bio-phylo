use Test::More;
use Bio::Phylo::Forest::Node;
use strict;
BEGIN {
    eval { require Bio::Tree::Node };
    if ( $@ ) {
        plan 'skip_all' => 'Bio::Tree::Node not found';
    }
    if ( not $ENV{'BIOPERL_LIVE_ROOT'} ) {
        plan 'skip_all' => 'env var BIOPERL_LIVE_ROOT not set';
    }
}
BEGIN { 
    use lib $ENV{'BIOPERL_LIVE_ROOT'} . '/t/lib';
    use Bio::Root::Test;    
    test_begin( '-tests' => 15 );	
    use_ok('Bio::Tree::Node');
}

my $node1 = Bio::Phylo::Forest::Node->new_from_bioperl(Bio::Tree::Node->new());
my $node2 = Bio::Phylo::Forest::Node->new_from_bioperl(Bio::Tree::Node->new());
ok($node1->is_Leaf() );
is($node1->ancestor, undef);

my $pnode = Bio::Phylo::Forest::Node->new_from_bioperl(Bio::Tree::Node->new());
$pnode->add_Descendent($node1);
is($node1->ancestor, $pnode);
$pnode->add_Descendent($node2);
is($node2->ancestor, $pnode);

ok(! $pnode->is_Leaf);

my $phylo_node = Bio::Phylo::Forest::Node->new_from_bioperl(
    Bio::Tree::Node->new(
        '-bootstrap' => 0.25,
		'-id'        => 'ADH_BOV',
		'-desc'      => 'Taxon 1'
	)
);
$node1->add_Descendent($phylo_node);
ok(! $node1->is_Leaf);
is($phylo_node->ancestor, $node1);
is($phylo_node->id, 'ADH_BOV');
is($phylo_node->bootstrap, 0.25);
is($phylo_node->description, 'Taxon 1');

is $phylo_node->ancestor($node2), $node2;
ok $node1->is_Leaf;
is my @descs = $node2->each_Descendent, 1;
is $descs[0], $phylo_node;
