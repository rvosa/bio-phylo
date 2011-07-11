use Test::More;

BEGIN {

    # PHYLOWS_ENDPOINT is probably http://nexml-dev.nescent.org/nexml/phylows/tolweb/phylows/
    if ( not $ENV{'PHYLOWS_ENDPOINT'} ) {
        plan 'skip_all' => 'env var PHYLOWS_ENDPOINT not set';
    }
    else {
        Test::More->import('no_plan');
    }
}

use strict;
use warnings;
use Bio::Phylo::PhyloWS::Client;
use Bio::Phylo::Util::CONSTANT ':objecttypes';

my $url = $ENV{'PHYLOWS_ENDPOINT'};

# this creates a PhyloWS client that talks to the Tree of Life web service
my $client = Bio::Phylo::PhyloWS::Client->new(
    '-base_uri'  => $url,
    '-authority' => 'ToL',
);

# here we run a search query to get the root of the Primate tree
my $query = $client->get_query_result(
    '-query'   => 'Primates',
    '-section' => 'taxon',
);

# there is only one hit, so we can fetch the first (and only) result
my ($hit) = @{ $query->get_entities };

# for that hit, we download the full record, a Bio::Phylo::Project object
my $base_record = $client->get_record( '-guid' => $hit->get_guid );

# the project contains only one tree, which we fetch here
my ($base_tree) = @{ $base_record->get_items(_TREE_) };

# now process all the tips (terminal nodes) in the tree
for my $tip ( @{ $base_tree->get_terminals }) {
    recurse_graft( $tip );
}

# write out the result
print $base_record->to_xml;

# recursively grafts slices of the tree of life onto the argument $root
sub recurse_graft {
    my $root = shift;
    warn $root->get_name, "\n";
    
    # tol:leaf returns true if we've reached a tip
    if ( not $root->get_meta_object('tol:leaf') ) {
        
        # this returns the ToL node ID
        my $root_id = $root->get_meta_object('dc:identifier');
        my $record = $client->get_record( '-guid' => $root_id );
        my ($tree) = @{ $record->get_items(_TREE_) };
        
        # now process the nodes in the newly fetched tree
        for my $node ( @{ $tree->get_entities } ) {
            
            # we don't care about this root as it is the same as $root
            if ( not $node->is_root ) {
                
                # graft the children of the newly fetched root to $root
                my $parent = $node->get_parent;
                if ( $parent->get_meta_object('dc:identifier') == $root_id ) {
                    $root->set_child($node);
                }
                
                # all new nodes need to end up in our tree
                $base_tree->insert($node);
                
                # new proceed with the tips in the new tree
                recurse_graft($node) if $node->is_terminal;
            }            
        }        
    }
}
