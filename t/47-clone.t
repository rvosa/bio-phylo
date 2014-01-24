#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::Factory;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::Forest::Node;
use Bio::Phylo::Forest::Tree;
use Bio::Phylo::Matrices::Matrix;

my $fac = Bio::Phylo::Factory->new;

# clone a node
{    
    my $node = $fac->create_node( '-branch_length' => 1 );
    my $clone = $node->clone;
    ok( $clone->get_branch_length == $node->get_branch_length, "copied node property" );
}

# clone a tree  
{
    my $tree = $fac->create_tree;
    $tree->set_as_unrooted;
    $tree->set_as_default;
    my $clone = $tree->clone;
    ok( $clone->is_default == $tree->is_default, "copied default flag" );
    ok( $clone->is_rooted  == $tree->is_rooted, "copied rootedness" );
}

# clone a taxon    
{
    my $taxon = $fac->create_taxon(
	'-name'     => 'foo',
	'-xml_id'   => 'bar',
	'-tag'      => 'baz',
	'-base_uri' => 'urn:example.org:taxon',
	'-link'     => 'http://example.org/taxon',
	'-identifiable' => 1,
	'-suppress_ns'  => 1,
    );
    my $clone = $taxon->clone;
    ok( $clone->get_name eq $taxon->get_name, "copied XML label" );
    ok( $clone->get_xml_id ne $taxon->get_xml_id, "NOT copied XML ID" );
    ok( $clone->get_tag eq $taxon->get_tag, "copied XML tag" );
    ok( $clone->get_base_uri eq $taxon->get_base_uri, "copied base URI" );
    ok( $clone->get_link eq $taxon->get_link, "copied link" );
    ok( $clone->is_identifiable == $taxon->is_identifiable, "copied identifiability" );
    ok( $clone->is_ns_suppressed == $taxon->is_ns_suppressed, "copied NS suppression" );
}

# test recursive deep cloning
{    
    my $matrix = $fac->create_matrix( 
	    '-type' => 'dna',
	    '-raw'  => [ [ 'taxon1' => 'acgtcg' ], [ 'taxon2' => 'acgtcg' ] ],
    );
    my $taxa = $matrix->make_taxa;
    $matrix->get_characters->set_name("MyChars");
    my $shallow = $matrix->clone(0);
    my $deep = $matrix->clone(1);
    
    # still the same reference
    ok( $matrix->get_characters->get_id == $shallow->get_characters->get_id,
       "shallow clone delegates to same reference" );
    ok( $taxa->get_id == $shallow->get_taxa->get_id,
       "shallow clone delegates to same reference");
    
    # characters and taxa were also cloned
    ok( $matrix->get_characters->get_id != $deep->get_characters->get_id,
       "deep clone delegates to different reference" );
    
    # this previously didn't work because the implicitly created taxa block
    # was immediately unreachable so it was cleaned up. we now keep the
    # pointer from matrix to taxa unweakened so this doesn't happen and the
    # test passes.
    ok( $taxa->get_id != $deep->get_taxa->get_id,
       "deep clone delegates to different reference" );	
    ok( $deep->get_taxa->get_ntax == 2, "same number of taxa" );
    ok( $deep->get_taxa->first->get_id != $taxa->first->get_id, "different object IDs" );
    ok( $shallow->get_taxa->first->get_id == $taxa->first->get_id, "same object IDs" );
    
    # test if properties were cloned
    ok( $matrix->get_characters->get_name eq $shallow->get_characters->get_name,
       "shallow clone has same delegated object properties");
    ok( $matrix->get_characters->get_name eq $deep->get_characters->get_name,
       "deep clone has copied object properties");
}

# test tree cloning
{
    my $tree = $fac->create_tree;
    my $root = $fac->create_node( '-name' => 'root' );
    $tree->insert($root);
    my $clone = $tree->clone;
    ok( $tree->get_id != $clone->get_id, "trivial tree cloning 1" );
    ok( $tree->get_root->get_id != $clone->get_root->get_id, "trivial tree cloning 2");
    ok( $tree->get_root->get_name eq $clone->get_root->get_name, "trivial tree cloning 3");
    
}