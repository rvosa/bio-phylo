package Bio::Phylo::Mediators::NodeMediator;
use strict;
use Scalar::Util qw(weaken);
use Bio::Phylo::Util::Exceptions;
use Bio::Phylo ();

# XXX this class only has weak references
{
    my $self;
    my ( %tree_id_for_node, %ancestor_function, %node_object_for_id );
    my $logger = Bio::Phylo->get_logger;

=head1 NAME

Bio::Phylo::Mediators::NodeMediator - Mediator for links between tree nodes

=head1 SYNOPSIS

 # no direct usage

=head1 DESCRIPTION

This module manages links between node objects. It is an implementation of the 
Mediator design pattern (e.g. see 
L<http://www.atug.com/andypatterns/RM.htm>,
L<http://home.earthlink.net/~huston2/dp/mediator.html>,
L<http://sern.ucalgary.ca/courses/SENG/443/W02/assignments/Mediator/>).

Methods defined in this module are meant only for internal usage by Bio::Phylo.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

NodeMediator constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $mediator = Bio::Phylo::Taxa::NodeMediator->new;
 Function: Instantiates a Bio::Phylo::Taxa::NodeMediator
           object.
 Returns : A Bio::Phylo::Taxa::NodeMediator object (singleton).
 Args    : None.

=cut

    sub new {

        # could be child class
        my $class = shift;

        # notify user
        $logger->info("constructor called for '$class'");

        # singleton class
        if ( not $self ) {
            $logger->info("first time instantiation of singleton");
            $self = \$class;
            bless $self, $class;
        }
        return $self;
    }

=back

=head2 METHODS

=over

=item register()

Stores an object in mediator's cache.

 Type    : Method
 Title   : register
 Usage   : $mediator->register( $obj );
 Function: Stores an object in mediator's cache
 Returns : $self
 Args    : An object, $obj
 Comments: This method is called every time a node is instantiated.

=cut	

    sub register {
        my ( $self, $node ) = @_;
        my $id = $node->get_id;
        $logger->info("registering node $node ($id)");

        # to retrieve nodes by id
        $node_object_for_id{$id} = $node;

        # XXX the following weaken/not weaken is crucial:
        # bioperl and bionexus assume nodes can all reach
        # each other outside of a tree container, bio::phylo
        # cleans up when nodes not in a tree container go
        # out of scope
        #weaken $node_object_for_id{$id};
        # generate scratch tree id
        my $temporary_tree_id = -1;
        $tree_id_for_node{$id} = $temporary_tree_id;

        # create new if deleted earlier
        if ( not $ancestor_function{$temporary_tree_id} ) {
            $ancestor_function{$temporary_tree_id} = [];
        }

        # insert in scratch tree
        push @{ $ancestor_function{$temporary_tree_id} }, [ $id => -1 ];
        return $self;
    }

=item unregister()

Removes argument from mediator's cache.

 Type    : Method
 Title   : unregister
 Usage   : $mediator->unregister( $obj );
 Function: Cleans up mediator's cache of $obj and $obj's relations
 Returns : $self
 Args    : An object, $obj
 Comments: This method is called every time a node ($obj) is destroyed.

=cut	

    # ( clean %tree_id_for_node, %ancestor_function, %node_object_for_id );
    sub unregister {
        my ( $self, $node ) = @_;
        if ( $node and defined( my $id = $node->get_id ) ) {
            $logger->debug("unregistering node $id");

            # no need to retrieve from here after this
            delete $node_object_for_id{$id};

            # clean up tree references
            my $tree = $tree_id_for_node{$id};    # XXX undef here?
            delete $tree_id_for_node{$id};

            # let's see if there is still a tree structure around
            if ( defined $tree and exists $ancestor_function{$tree} ) {

                # get parent, splice out node
                my $parent_id;
                my $function = $ancestor_function{$tree};
              NODE: for my $i ( 0 .. $#{$function} ) {
                    if ( $function->[$i]->[0] == $id ) {
                        $parent_id = $function->[$i]->[1];
                        splice @{$function}, $i, 1;
                        last NODE;
                    }
                }

                # connect children to parent
                for my $i ( 0 .. $#{$function} ) {
                    if ( $function->[$i]->[1] == $id ) {
                        $function->[$i]->[1] = $parent_id;
                    }
                }

                # is tree empty?
                if ( not @{$function} ) {
                    delete $ancestor_function{$tree};
                }
            }
        }
    }

=item set_link()

Creates link between arguments.

 Type    : Method
 Title   : set_link
 Usage   : $mediator->set_link( node => $obj1, $connection => $obj2 );
 Function: Creates link between objects
 Returns : $self
 Args    : node => a $node object
 		   $connection => another $node object, where $connection is
 		   *	parent
 		   *	first_daughter
 		   *	last_daughter
 		   *	next_sister
 		   *	previous_sister
 Comments: This method is called from within, for example, set_parent
           method calls. A call like $node1->set_parent( $node2 ),
           is internally rerouted to:

           $mediator->set_link( 
                node   => $node1,
                parent => $node2, 
           );

=cut

    sub set_link {
        my $self    = shift;
        my %args    = @_;
        my $node_id = $args{'node'}->get_id;
        my $tree_id = $tree_id_for_node{$node_id};
        my $function;
        my $index_of_updated;
        my $id_of_updated;
        $logger->debug("setting link between nodes");

        # set parent
        if ( exists $args{'parent'} ) {
            $self->update_tree(
                'keep'   => $args{'parent'},
                'update' => $args{'node'}
            );
            my $parent_id = $args{'parent'}->get_id;
            $function = $ancestor_function{ $tree_id_for_node{$parent_id} };
            $id_of_updated = $node_id;

            # scan tree for last daughter, shift right up until that, insert
          SET_PARENT: for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[1] != $parent_id && $i != 0 ) {
                    $function->[ $i + 1 ] =
                      [ @{ $function->[$i] } ];    # shift right
                }
                else {
                    $function->[ $i + 1 ] = [ $node_id => $parent_id ];
                    $index_of_updated = $i + 1;
                    last SET_PARENT;
                }
            }
        }

        # set first daughter
        elsif ( exists $args{'first_daughter'} ) {
            $self->update_tree(
                'keep'   => $args{'node'},
                'update' => $args{'first_daughter'}
            );
            my $first_daughter_id = $args{'first_daughter'}->get_id;
            my $seen_siblings     = 0;
            $function      = $ancestor_function{ $tree_id_for_node{$node_id} };
            $id_of_updated = $first_daughter_id;

            # scan for daughters, shift right beyond that, insert
          SET_FIRST_DAUGHTER: for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[1] != $node_id and not $seen_siblings ) {
                    $function->[ $i + 1 ] = $function->[$i];    # shift right
                }
                elsif ( $function->[$i]->[1] == $node_id ) {
                    $function->[ $i + 1 ] = $function->[$i];    # shift right
                    $seen_siblings = 1;
                }
                if ( ( $function->[$i]->[1] != $node_id and $seen_siblings )
                    or $i == 0 )
                {
                    $function->[ $i + 1 ] = [ $first_daughter_id => $node_id ];
                    $index_of_updated = $i + 1;
                    last SET_FIRST_DAUGHTER;
                }
            }
        }

        # set last daughter
        elsif ( exists $args{'last_daughter'} ) {
            $self->update_tree(
                'keep'   => $args{'node'},
                'update' => $args{'last_daughter'}
            );
            my $last_daughter_id = $args{'last_daughter'}->get_id;
            $function      = $ancestor_function{ $tree_id_for_node{$node_id} };
            $id_of_updated = $last_daughter_id;

            # scan for daughters, shift right up until that, insert
          SET_LAST_DAUGHTER: for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[1] != $node_id ) {
                    $function->[ $i + 1 ] = $function->[$i];    # shift right
                }
                else {
                    $function->[ $i + 1 ] = [ $last_daughter_id => $node_id ];
                    $index_of_updated = $i + 1;
                    last SET_LAST_DAUGHTER;
                }
            }
        }

        # set next sister
        elsif ( exists $args{'next_sister'} ) {
            $self->update_tree(
                'keep'   => $args{'node'},
                'update' => $args{'next_sister'}
            );
            my $next_sister_id = $args{'next_sister'}->get_id;
            $function      = $ancestor_function{ $tree_id_for_node{$node_id} };
            $id_of_updated = $next_sister_id;

            # scan for siblings, shift right up until that, insert
          SET_NEXT_SISTER: for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[0] != $node_id ) {
                    $function->[ $i + 1 ] = $function->[$i];    # shift right
                }
                else {
                    my $parent_id = $function->[$i]->[1];
                    $function->[ $i + 1 ] = [ $next_sister_id => $parent_id ];
                    $index_of_updated = $i + 1;
                    last SET_NEXT_SISTER;
                }
            }
        }

        # set previous sister
        elsif ( exists $args{'previous_sister'} ) {
            $self->update_tree(
                'keep'   => $args{'node'},
                'update' => $args{'previous_sister'}
            );
            my $previous_sister_id = $args{'previous_sister'}->get_id;
            my $seen_me            = 0;
            $function      = $ancestor_function{ $tree_id_for_node{$node_id} };
            $id_of_updated = $previous_sister_id;
            my $parent_id;

            # scan for siblings, shift right beyond that, insert
          SET_PREVIOUS_SISTER:
            for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[0] != $node_id and not $seen_me ) {
                    $function->[ $i + 1 ] = $function->[$i];    # shift right
                }
                elsif ( $function->[$i]->[0] == $node_id ) {
                    $function->[ $i + 1 ] = $function->[$i];       # shift right
                    $parent_id            = $function->[$i]->[1];
                    $seen_me              = 1;
                    next SET_PREVIOUS_SISTER;
                }
                if ($seen_me) {
                    $function->[ $i + 1 ] =
                      [ $previous_sister_id => $parent_id ];
                    $index_of_updated = $i + 1;
                    last SET_PREVIOUS_SISTER;
                }
            }
        }

        # clean up any duplicates
        for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
            next if $i == $index_of_updated;
            if ( $function->[$i]->[0] == $id_of_updated ) {
                splice @{$function}, $i, 1;
            }
        }
    }

=item update_tree()

Updates tree membership.

 Type    : Method
 Title   : update_tree
 Usage   : $mediator->update_tree( 
               keep   => $node1, 
               update => $node2,
           );
 Function: updates tree membership
 Returns : Linked object
 Args    : keep   => $node1 (node whose tree membership to retain)
           update => $node2 (node whose tree membership 
           is moved to that of $node1)

 Comments: This method is called so that $node2 and its descendants
 		   becomes member of the same tree as $node1

=cut

    sub update_tree {
        my $self      = shift;
        my %args      = @_;
        my $keep_id   = $args{'keep'}->get_id;
        my $update_id = $args{'update'}->get_id;
        $logger->debug("updating tree");

        # not in the same tree
        if ( $tree_id_for_node{$keep_id} != $tree_id_for_node{$update_id} ) {

            # first clean out "wrong" tree
            my $function = $ancestor_function{ $tree_id_for_node{$update_id} };
            my $descendants = [];
            for my $tuple ( @{$function} ) {
                if ( $tuple->[0] == $update_id ) {
                    push @$descendants, [ $tuple->[0], $tuple->[1] ];
                }
            }

            # recursively assemble all descendants of node to move to new tree
            $self->_descendants( $update_id, $function, $descendants );

            # prune from "wrong" tree
            my %prune = map { $_->[0] => 1 } @$descendants;
            for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( exists $prune{ $function->[$i]->[0] } ) {
                    splice @$function, $i, 1;
                }
            }
            if ( not @$function ) {
                delete $ancestor_function{ $tree_id_for_node{$update_id} };
            }

            # then populate "right" tree
            my $first = shift @$descendants;
            $tree_id_for_node{ $first->[0] } = $tree_id_for_node{$keep_id};
            my $newtree = $ancestor_function{ $tree_id_for_node{$keep_id} };

            # push all descendants onto tree (will fit in the focal node later)
            for my $desc (@$descendants) {
                $tree_id_for_node{ $desc->[0] } = $tree_id_for_node{$keep_id};
                push @$newtree, [ $desc->[0], $desc->[1] ];
            }
        }
    }

=begin comment

 Type    : Internal method
 Title   : _descendants
 Usage   : $mediator->_descendants( $parent_id, $ancestor_function, $descendants )
 Function: Recursively fetches all descendants of $parent_id 
 Returns : An array reference of descendants $descendants
 Args    : $parent_id, $ancestor_function, $descendants

=end comment

=cut

    # recursive fetch descendants
    sub _descendants {
        my ( $self, $parent_id, $function, $descendants ) = @_;
        for my $tuple ( @{$function} ) {
            if ( $tuple->[1] == $parent_id ) {
                push @$descendants, [ $tuple->[0], $tuple->[1] ];
                $self->_descendants( $tuple->[0], $function, $descendants );
            }
        }
    }

=item get_link()

Retrieves relative of argument.

 Type    : Method
 Title   : get_link
 Usage   : $mediator->get_link( $connection => $node );
 Function: Retrieves relative of $node
 Returns : Relative of $node
 Args    : $connection => $node, where $connection can be:
 		   *	parent_of
 		   *	next_sister_of
 		   *	previous_sister_of
 		   *	first_daughter_of
 		   *	last_daughter_of
=cut

    sub get_link {
        my $self = shift;
        my %args = @_;
        $logger->debug("getting link between nodes");
        my $node;

        # get_parent
        if ( $node = $args{'parent_of'} ) {
            my $id       = $node->get_id;
            my $tree_id  = $tree_id_for_node{$id};
            my $function = $ancestor_function{$tree_id};
            for my $tuple ( @{$function} ) {
                if ( $tuple->[0] == $id ) {
                    return $node_object_for_id{ $tuple->[1] };
                }
            }
            return;
        }

        # get_first_daughter
        elsif ( $node = $args{'first_daughter_of'} ) {
            my $id       = $node->get_id;
            my $tree_id  = $tree_id_for_node{$id};
            my $function = $ancestor_function{$tree_id};
            for ( my $i = 0 ; $i <= $#{$function} ; $i++ ) {
                if ( $function->[$i]->[1] == $id ) {
                    return $node_object_for_id{ $function->[$i]->[0] };
                }
            }
            return;
        }

        # get_last_daughter
        elsif ( $node = $args{'last_daughter_of'} ) {
            my $id       = $node->get_id;
            my $tree_id  = $tree_id_for_node{$id};
            my $function = $ancestor_function{$tree_id};
            for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[1] == $id ) {
                    return $node_object_for_id{ $function->[$i]->[0] };
                }
            }
            return;
        }

        # get_next_sister
        elsif ( $node = $args{'next_sister_of'} ) {
            my $id       = $node->get_id;
            my $tree_id  = $tree_id_for_node{$id};
            my $function = $ancestor_function{$tree_id};
            my $parent_id;
          GET_NEXT_SISTER: for ( my $i = 0 ; $i <= $#{$function} ; $i++ ) {
                if ( $function->[$i]->[0] == $id ) {
                    $parent_id = $function->[$i]->[1];
                    next GET_NEXT_SISTER;
                }
                if (   defined $parent_id
                    && $function->[$i]->[0] != $id
                    && $function->[$i]->[1] == $parent_id )
                {
                    return $node_object_for_id{ $function->[$i]->[0] };
                }
            }
            return;
        }

        # get_previous_sister
        elsif ( $node = $args{'previous_sister_of'} ) {
            my $id       = $node->get_id;
            my $tree_id  = $tree_id_for_node{$id};
            my $function = $ancestor_function{$tree_id};
            my $parent_id;
          GET_PREVIOUS_SISTER:
            for ( my $i = $#{$function} ; $i >= 0 ; $i-- ) {
                if ( $function->[$i]->[0] == $id ) {
                    $parent_id = $function->[$i]->[1];
                    next GET_PREVIOUS_SISTER;
                }
                if (   defined $parent_id
                    && $function->[$i]->[0] != $id
                    && $function->[$i]->[1] == $parent_id )
                {
                    return $node_object_for_id{ $function->[$i]->[0] };
                }
            }
            return;
        }
    }

# $logger is apparently already cleaned up when we reach the destructor, so call as static
    sub DESTROY {
        Bio::Phylo::Util::Logger->debug("calling empty destructor for '@_'");
    }
}

=back

=head1 SEE ALSO

=over

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: NodeMediator.pm 1593 2011-02-27 15:26:04Z rvos $

=cut
1;
