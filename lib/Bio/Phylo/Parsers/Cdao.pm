package Bio::Phylo::Parsers::Cdao;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT qw'looks_like_instance :namespaces :objecttypes';
use Bio::Phylo::Util::Dependency qw'RDF::Trine::Node::Resource RDF::Query';

my $ns_cdao = _NS_CDAO_;
my $ns_rdf  = _NS_RDF_;
my $ns_rdfs = _NS_RDFS_;

my %prefix_for_ns = (
    $ns_cdao => 'cdao',
    $ns_rdf  => 'rdf',
    $ns_rdfs => 'rdfs',
);

my %objects;

my $prefixes = <<"PREFIXES";
PREFIX rdf: <${ns_rdf}>
PREFIX cdao: <${ns_cdao}>
PREFIXES

my $query = <<"QUERY";
${prefixes}
SELECT
	?subject
WHERE {
	?subject rdf:type cdao:%s
}
QUERY

sub _parse {
    my $self = shift;
    %objects = ();
    $self->_args->{'-opts'} = {
        'lang'      => 'sparql',
        'base'      => $self->_args->{'-base'},
        'update'    => 0,
        'load_data' => 0,
    };
    $self->_project->set_base_uri($self->_args->{'-base'});
    $self->_process_tus;
    $self->_process_trees;
    $self->_process_nodes;
    $self->_process_edges;
    
    my $proj = $self->_project;
    my @objects = ( @{ $proj->get_taxa }, @{ $proj->get_forests }, @{ $proj->get_matrices } );
    $proj->clear;
    return @objects;
}

sub _object_from_resource {
    my ( $self, $resource, $creator ) = @_;
    my $fac = $self->_factory;
    my $base = $self->_args->{'-base'};
    my $uri = $resource->value;
    my $id = $uri;
    $id  =~ s/^\Q$base\E#?//;
    my $object = $fac->$creator( '-guid' => $id, '-xml_id' => $id );
    my $iterator = $self->_args->{'-model'}->get_statements($resource,undef,undef);
    while ( my $inner = $iterator->next ) {
        my ( $predicate, $value ) = ( $inner->predicate, $inner->object );
        $self->_process_annotation( $predicate->value, $value->value, $object );

    }    
    $self->_logger->info($object->to_xml);
    $objects{$uri} = $object;    
}

sub _parse_predicate {
    my ( $self, $predicate ) = @_;
    # attempt to split URI in namespace and term
    my ( $ns, $term );
    
    # this is for cases where the term is referenced as somewhere inside
    # an ontology using an anchor '#', e.g. in CDAO
    if ( $predicate =~ m/^(.+#)(.+?)$/ ) {
        ( $ns, $term ) = ( $1, $2 );
    }
    
    # this is for cases where the term is a path fragment inside a namespace,
    # i.e. preceded by a '/', as in dublin core
    elsif ( $predicate =~ m/^(.+\/)([^\/]+?)$/ ) {
        ( $ns, $term ) = ( $1, $2 );
    }
    
    # this is for cases where the term is relative to a urn:, i.e. preceded
    # by a ':', as in the uBio predicates
    elsif ( $predicate =~ m/^(.+:)([^:]+?)$/ ) {
        ( $ns, $term ) = ( $1, $2 );
    }
    
    else {
        $self->_logger->warn("Can't parse URI $predicate");
    }
    return $ns, $term;
}

sub _process_annotation {
    my ( $self, $predicate, $value, $object ) = @_;
    my $fac = $self->_factory;
    $predicate =~ s/^<(.+)>$/$1/;
    return if $predicate eq _NS_RDF_ . 'type';
    
    # attempt to split URI in namespace and term
    my ( $ns, $term ) = $self->_parse_predicate( $predicate );
    
    # check to see if we have a prefix for that namespace, or make one
    my $prefix = $prefix_for_ns{$ns} || 'ns' . scalar(keys %prefix_for_ns);
    $prefix_for_ns{$prefix} = $ns;
    
    # maybe we know how to deal with this in the API
    if ( "${prefix}:${term}" eq 'rdfs:label' ) {
        $object->set_name( $value );
        return;
    }
    if ( "${prefix}:${term}" eq 'cdao:represents_TU' ) {
        $object->set_taxon( $objects{$value} );
        return;
    }
    if ( "${prefix}:${term}" eq 'cdao:has_Ancestor' ) {
        return; # don't need this, will reconstruct from edge links
    }
    if ( "${prefix}:${term}" eq 'cdao:has_Root' ) {
        return; # don't need this, will be obvious from whether tree is rooted
    }
    
    # attach annotation
    $object->set_namespaces( $prefix => $ns );
    $object->add_meta(
        $fac->create_meta(
            '-triple' => { "${prefix}:${term}" => $value }
        )
    );    
}

sub _do_query {
    my ( $self, $type ) = @_;
    my $sth = RDF::Query->new( sprintf($query, $type), $self->_args->{'-opts'} );
    return $sth->execute( $self->_args->{'-model'} );
}

sub _process_tus {
    my $self  = shift;
    my $fac   = $self->_factory;
    my $taxa  = $fac->create_taxa;
    my $model = $self->_args->{'-model'};
    my $iter  = $self->_do_query('TU');
    while ( my $row = $iter->next ) {
        my $subject = $row->{'subject'};
        my $taxon = $self->_object_from_resource( $subject, 'create_taxon' );
        $taxa->insert($taxon);
    }
    $self->_project->insert($taxa);
}

sub _process_trees {
    my $self   = shift;
    my $fac    = $self->_factory;
    my ($taxa) = @{ $self->_project->get_items(_TAXA_) };
    my $forest = $fac->create_forest( '-taxa' => $taxa );
    my $model  = $self->_args->{'-model'};
    
    # process rooted trees
    my $rooted_iter = $self->_do_query('RootedTree');
    while( my $row = $rooted_iter->next ) {
        my $subject = $row->{'subject'};
        my $tree = $self->_object_from_resource( $subject, 'create_tree' );
        $forest->insert($tree);
    }
    
    # process unrooted trees
    my $unrooted_iter = $self->_do_query('UnrootedTree');
    while( my $row = $unrooted_iter->next ) {
        my $subject = $row->{'subject'};
        my $tree = $self->_object_from_resource( $subject, 'create_tree' );
        $tree->set_as_unrooted;
        $forest->insert($tree);
    }
    
    $self->_project->insert($forest);
}

sub _process_nodes {
    my $self   = shift;
    my $model  = $self->_args->{'-model'};
    my $logger = $self->_logger;
    
    # this only assigns nodes to a tree object but doesn't resolve
    # topology, that's done in _process_edges
    my $node_iter = $self->_do_query('Node');
    while( my $row = $node_iter->next ) {
        my $subject = $row->{'subject'};
        my $node = $self->_object_from_resource( $subject, 'create_node' );
        my ($value) = @{ $node->get_meta('cdao:belongs_to_Tree') };
        $objects{$value->get_object}->insert($node) if $objects{$value->get_object};
        $node->remove_meta($value);
    }
}

sub _process_edges {
    my $self   = shift;
    my $model  = $self->_args->{'-model'};
    my $logger = $self->_logger;
    
    my $edge_iter = $self->_do_query('DirectedEdge');
    while( my $row = $edge_iter->next ) {
        my $subject = $row->{'subject'};
        my $edge_statements = $model->get_statements($subject);
        my ( $parent_uri, $child_uri, $branch_length );
        LINK: while( my $st = $edge_statements->next ) {
            my $predicate = $st->predicate->value;
            $logger->debug($predicate);
            if ( $predicate eq "${ns_cdao}has_Parent_Node" ) {
                $parent_uri = $st->object->value;
            }
            elsif ( $predicate eq "${ns_cdao}has_Child_Node" ) {
                $child_uri = $st->object->value;
            }
            elsif ( $predicate eq "${ns_cdao}has_Annotation" ) {
                my $annotation_statements = $model->get_statements($st->object);
                ANNO: while(my $anno = $annotation_statements->next) {
                    my $anno_pre = $anno->predicate->value;
                    if ( $anno_pre =~ /^\Q${ns_cdao}\Ehas_(?:Int|Float)_Value/ ) {
                        $branch_length = $anno->object->value;
                        last ANNO;
                    }
                }
            }
            last LINK if $parent_uri && $child_uri;           
        }
        $logger->debug("Parent: $parent_uri Child: $child_uri");
        $objects{$parent_uri}->set_child($objects{$child_uri});
        $objects{$child_uri}->set_branch_length($branch_length) if defined $branch_length;
    }
}

1;