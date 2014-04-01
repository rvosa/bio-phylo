#!/usr/bin/perl
use Test::More 'no_plan';
use strict;
use Bio::Phylo;
use Bio::Phylo::Factory;
use Bio::Phylo::IO 'parse';

my $fac = Bio::Phylo::Factory->new;

# test taxon destruction
{
    my $id;
    {
        my $taxon = $fac->create_taxon;
        $id = $taxon->get_id;
    }
    my $obj = Bio::Phylo->get_obj_by_id($id);
    ok(! $obj, 'test taxon destruction');
}

# test taxa destruction
{
    my $id;
    {
        my $taxa = $fac->create_taxa;
        $id = $taxa->get_id;
    }
    my $obj = Bio::Phylo->get_obj_by_id($id);
    ok(! $obj, 'test taxa destruction' );
}

# test taxon in taxa destruction
{
    my ( $taxon_id, $taxa_id );
    {
        my $taxa = $fac->create_taxa;
        my $taxon = $fac->create_taxon;
        $taxa->insert($taxon);
        ( $taxon_id, $taxa_id ) = ( $taxon->get_id, $taxa->get_id );
    }
#SKIP: {
#	skip "please fix cyclical references in objects contained by Listables", 1, 1;
	ok( ! Bio::Phylo->get_obj_by_id($taxon_id), 'test contained taxon in taxa destruction' );
#}
    ok( ! Bio::Phylo->get_obj_by_id($taxa_id), 'test container taxa destruction' );
}

# test node destruction
{
    my $id;
    {
        my $node = $fac->create_node;
        $id = $node->get_id;
    }
    ok( ! Bio::Phylo->get_obj_by_id($id), 'test node destruction' );
}

# test tree destruction
{
    my $id;
    {
        my $tree = $fac->create_tree;
        $id = $tree->get_id;
    }
    ok( ! Bio::Phylo->get_obj_by_id($id), 'test tree destruction' );
}

# test node in tree destruction
{
    my ( $node_id, $tree_id );
    {
        my $tree = $fac->create_tree;
        my $node = $fac->create_node;
        $tree->insert($node);
        ( $node_id, $tree_id ) = ( $node->get_id, $tree->get_id );
    }
#SKIP: {
#	skip "please fix cyclical references in objects contained by Listables", 1, 1;    
    ok( ! Bio::Phylo->get_obj_by_id($node_id), 'test contained node in tree destruction' );
#}
    ok( ! Bio::Phylo->get_obj_by_id($tree_id), 'test container tree destruction' );
}

# test nodes in tree destruction
{
    my ( $n1, $n2, $t );
    {
        my $tree   = $fac->create_tree;
        my $child  = $fac->create_node;
        my $parent = $fac->create_node;
        $child->set_parent($parent);
        $tree->insert($child,$parent);
        ( $n1, $n2, $t ) = ( $child->get_id, $parent->get_id, $tree->get_id );
    }
#SKIP: {
#	skip "please fix cyclical references in objects contained by Listables", 2, 1;    
    ok( ! Bio::Phylo->get_obj_by_id($n1), 'test nodes in tree destruction' );
    ok( ! Bio::Phylo->get_obj_by_id($n2), 'test nodes in tree destruction' );
#}
    ok( ! Bio::Phylo->get_obj_by_id($t), 'test nodes in tree destruction' );
}

# test datum destruction
{
    my $id;
    {
        my $datum = $fac->create_datum;
        $id = $datum->get_id;
    }
    ok( ! Bio::Phylo->get_obj_by_id($id), 'test datum destruction' );
}

# test matrix destruction
{
    my $id;
    {
        my $matrix = $fac->create_matrix;
        $id = $matrix->get_id;
    }
    ok( ! Bio::Phylo->get_obj_by_id($id), 'test matrix destruction' );
}

# test datum in matrix destruction
{
    my ( $m, $d );
    {
        my $matrix = $fac->create_matrix;
        my $datum = $fac->create_datum;
        $matrix->insert($datum);
        ( $m, $d ) = ( $matrix->get_id, $datum->get_id );
    }
    ok( ! Bio::Phylo->get_obj_by_id($m), 'test container matrix destruction' );
#SKIP: {
#	skip "please fix cyclical references in objects contained by Listables", 1, 1;    
    ok( ! Bio::Phylo->get_obj_by_id($d), 'test contained datum in matrix destruction' );
#}
}

# test entire project
{
    my %ids;
    {
        my $proj = parse(
            '-format' => 'nexus',
            '-handle' => \*DATA,
            '-as_project' => 1,
        );
        sub visitor {
            my $obj = shift;
            if ( UNIVERSAL::can( $obj, 'get_id' ) ) {
                $ids{ $obj->get_id } = ref $obj;
            }
            if ( UNIVERSAL::can( $obj, 'visit' ) ) {
                $obj->visit(\&visitor);       
            }
        }
        $proj->visit(\&visitor);
        $ids{$proj->get_id} = ref $proj;
        for my $id ( sort { $a <=> $b } keys %ids ) {
            ok( ref Bio::Phylo->get_obj_by_id($id) eq $ids{$id}, "Found $ids{$id} $id" );
        }      
    }
    for my $id ( sort { $a <=> $b } keys %ids ) {
SKIP: {
	skip "please fix cyclical references in objects contained by Listables", 1, 1;   
    ok( ! Bio::Phylo->get_obj_by_id($id), "$ids{$id} $id has been destroyed" );
}
    }
}



__DATA__
#NEXUS

BEGIN TAXA;
	TITLE Taxa;
	DIMENSIONS NTAX=3;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 
	;
END;

BEGIN CHARACTERS;
	TITLE  Character_Matrix;
	DIMENSIONS  NCHAR=2;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1";
	MATRIX
		taxon_1  ??
		taxon_2  ??
		taxon_3  ??
	;
END;

BEGIN TREES;
	Title Default_Trees;
	LINK Taxa = Taxa;
	TRANSLATE
		1 taxon_1,
		2 taxon_2,
		3 taxon_3;
	TREE Default_symmetrical = (1,(2,3));
	TREE Default_bush = (1,2,3);
	TREE Default_ladder = (1,(2,3));
END;