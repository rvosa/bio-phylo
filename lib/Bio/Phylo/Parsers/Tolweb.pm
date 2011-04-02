package Bio::Phylo::Parsers::Tolweb;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT qw'looks_like_instance :namespaces';
use Bio::Phylo::Util::Dependency 'XML::Twig';

=head1 NAME

Bio::Phylo::Parsers::Tolweb - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module parses Tree of Life data. It is called by the L<Bio::Phylo::IO> facade,
don't call it directly. In addition to parsing from files, handles or strings (which
are specified by the -file, -handle and -string arguments) this parser can also parse
xml directly from a url (-url => $tolweb_output), provided you have L<LWP> installed.

=cut

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The ToL web parser is called by the L<Bio::Phylo::IO> object.
Look there to learn how to parse Tree of Life data (or any other data Bio::Phylo supports).

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=item L<http://tolweb.org>

For more information about the Tree of Life xml format, visit 
L<http://tolweb.org/tree/home.pages/downloadtree.html>

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Tolweb.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
# this is the constructor that gets called by Bio::Phylo::IO,
# here we create the object instance that will process the file/string
sub _init {
    my $self = shift;
    $self->_logger->debug("initializing $self");

    # this is the actual parser object, which needs to hold a reference
    # to the XML::Twig object and to the tree
    $self->{'_tree'}      = undef;
    $self->{'_node_of'}   = {};
    $self->{'_parent_of'} = {};

    # here we put the two together, i.e. create the actual XML::Twig object
    # with its handlers, and create a reference to it in the parser object
    $self->{'_twig'} = XML::Twig->new(
        'TwigHandlers' => { 'NODE' => sub { &_handle_node( $self, @_ ) }, } );
    return $self;
}

sub _parse {
    my $self = shift;
    $self->_init;
    $self->_logger->debug("going to parse xml");
    $self->{'_tree'} =
      $self->_factory->create_tree->insert( $self->_factory->create_node );
    $self->{'_twig'}->parse( $self->_string );
    $self->_logger->debug("done parsing xml");

    # now we build the tree structure
    my $root;
    for my $node_id ( keys %{ $self->{'_node_of'} } ) {
        if ( defined( my $parent_id = $self->{'_parent_of'}->{$node_id} ) ) {
            my $child  = $self->{'_node_of'}->{$node_id};
            my $parent = $self->{'_node_of'}->{$parent_id};
            $child->set_parent($parent);
        }
        else {
            $root = $self->{'_node_of'}->{$node_id};
        }
    }
    $root->set_parent( $self->{'_tree'}->get_root );
    $self->{'_tree'}->get_root->add_meta(
        $self->_factory->create_meta(
            '-triple' => { 'tba:id' => $root->get_generic('ANCESTORWITHPAGE') }
        )
    );
    $self->_logger->debug("done building tree");

    # we're done, now grab the tree from its field
    my $tree = $self->{'_tree'};
    return $self->_factory->create_forest->insert($tree);
}

sub _handle_node {
    my ( $self, $twig, $node_elt ) = @_;
    $self->_logger->debug("handling node $node_elt");
    my $node_obj = $self->_factory->create_node;
    my $id       = $node_elt->att('ID');
    $node_obj->set_generic( 'id' => $id );
    $self->{'_node_of'}->{$id} = $node_obj;
    if ( my $parent = $node_elt->parent->parent ) {
        $self->{'_parent_of'}->{$id} = $parent->att('ID');
        $self->_logger->debug("found parent node");
    }
    $self->{'_tree'}->insert($node_obj);
    for my $child_elt ( $node_elt->children ) {
        if ( $child_elt->tag eq 'NODES' or $child_elt->tag eq 'OTHERNAMES' ) {
            next;
        }
        elsif ( $child_elt->tag eq 'NAME' ) {
            if ( my $name = $child_elt->text ) {
                $name =~ m/[ ()]/
                  ? $node_obj->set_name( "'" . $name . "'" )
                  : $node_obj->set_name($name);
            }
        }
        elsif ( $child_elt->tag eq 'DESCRIPTION' ) {
            if ( my $desc = $child_elt->text ) {
                $node_obj->set_namespaces( 'dc' => _NS_DC_ );
                $node_obj->add_meta(
                    $self->_factory->create_meta(
                        '-triple' => { 'dc:description' => $desc }
                    )
                );
            }
        }
        elsif ( my $text = $child_elt->text ) {
            $node_obj->set_namespaces( 'tbe' => _NS_TWE_ );
            $node_obj->add_meta(
                $self->_factory->create_meta(
                    '-triple' => { 'tbe:' . lc( $child_elt->tag ) => $text }
                )
            );
        }
    }
    for my $att_name ( $node_elt->att_names ) {
        $node_obj->set_namespaces( 'tba' => _NS_TWA_ );
        if ( $att_name eq 'ANCESTORWITHPAGE' ) {
            $node_obj->set_generic(
                'ANCESTORWITHPAGE' => $node_elt->att($att_name) );
        }
        if ( defined $node_elt->att($att_name) ) {
            $node_obj->add_meta(
                $self->_factory->create_meta(
                    '-triple' =>
                      { 'tba:' . lc($att_name) => $node_elt->att($att_name) }
                )
            );
        }
    }
    $twig->purge;
}
1;
