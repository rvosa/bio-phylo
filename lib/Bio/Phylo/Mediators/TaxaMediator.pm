# $Id: TaxaMediator.pm 1660 2011-04-02 18:29:40Z rvos $
package Bio::Phylo::Mediators::TaxaMediator;
use strict;
use Scalar::Util qw'weaken';
use Bio::Phylo;
use Bio::Phylo::Util::Exceptions;
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# XXX this class only has weak references
{
    my $logger = Bio::Phylo::get_logger();
    my $self;
    my ( @object, @relationship );

=head1 NAME

Bio::Phylo::Mediators::TaxaMediator - Mediator for links between taxa and other objects

=head1 SYNOPSIS

 # no direct usage

=head1 DESCRIPTION

This module manages links between taxon objects and other objects linked to 
them. It is an implementation of the Mediator design pattern (e.g. see 
L<http://www.atug.com/andypatterns/RM.htm>,
L<http://home.earthlink.net/~huston2/dp/mediator.html>).

Methods defined in this module are meant only for internal usage by Bio::Phylo.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

TaxaMediator constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $mediator = Bio::Phylo::Taxa::TaxaMediator->new;
 Function: Instantiates a Bio::Phylo::Taxa::TaxaMediator
           object.
 Returns : A Bio::Phylo::Taxa::TaxaMediator object (singleton).
 Args    : None.

=cut

    sub new {

        # could be child class
        my $class = shift;

        # notify user
        $logger->info("constructor called for '$class'");

        # singleton class
        if ( not $self ) {
            $logger->debug("first time instantiation of singleton");
            $self = \$class;
            bless $self, $class;
        }
        return $self;
    }

=back

=head2 METHODS

=over

=item register()

Stores argument in invocant's cache.

 Type    : Method
 Title   : register
 Usage   : $mediator->register( $obj );
 Function: Stores an object in mediator's cache, if relevant
 Returns : $self
 Args    : An object, $obj
 Comments: This method is called every time an object is instantiated.

=cut

    sub register {
        my ( $self, $obj ) = @_;
        my $id = $obj->get_id;
        
        if ( ref $obj && $obj->can('_type') ) {
            my $type = $obj->_type;
            
            # node, forest, matrix, datum, taxon, taxa
            if ( $type == _NODE_ || $type == _TAXON_ || $type == _DATUM_ || $type == _TAXA_ || $type == _FOREST_ || $type == _MATRIX_ ) {
    
                # notify user
                $logger->debug("registering object $obj ($id)");
                $object[$id] = $obj;
                weaken $object[$id];
                return $self;
            }
        }
    }

=item unregister()

Removes argument from invocant's cache.

 Type    : Method
 Title   : unregister
 Usage   : $mediator->unregister( $obj );
 Function: Cleans up mediator's cache of $obj and $obj's relations
 Returns : $self
 Args    : An object, $obj
 Comments: This method is called every time an object is destroyed.

=cut

    sub unregister {
        my ( $self, $obj ) = @_;

        # notify user
        #$logger->info("unregistering object '$obj'"); # XXX
        my $id = $obj->get_id;
        if ( defined $id ) {
            if ( exists $object[$id] ) {

                # one-to-many relationship
                if ( exists $relationship[$id] ) {
                    delete $relationship[$id];
                }
                else {

                    # one-to-one relationship
                  LINK_SEARCH: for my $relation (@relationship) {
                        if ( exists $relation->{$id} ) {
                            delete $relation->{$id};
                            last LINK_SEARCH;
                        }
                    }
                }
                delete $object[$id];
            }
        }
        return $self;
    }

=item set_link()

Creates link between objects.

 Type    : Method
 Title   : set_link
 Usage   : $mediator->set_link( -one => $obj1, -many => $obj2 );
 Function: Creates link between objects
 Returns : $self
 Args    : -one  => $obj1 (source of a one-to-many relationship)
           -many => $obj2 (target of a one-to-many relationship)
 Comments: This method is called from within, for example, set_taxa
           method calls. A call like $taxa->set_matrix( $matrix ),
           and likewise a call like $matrix->set_taxa( $taxa ), are 
           both internally rerouted to:

           $mediator->set_link( 
                -one  => $taxa, 
                -many => $matrix 
           );

=cut

    sub set_link {
        my $self = shift;
        my %opt  = @_;
        my ( $one, $many ) = ( $opt{'-one'}, $opt{'-many'} );
        my ( $one_id, $many_id ) = ( $one->get_id, $many->get_id );

        # notify user
        $logger->debug("setting link between '$one' and '$many'");

        # delete any previously existing link
      LINK_SEARCH: for my $relation (@relationship) {
            if ( exists $relation->{$many_id} ) {
                delete $relation->{$many_id};

                # notify user
                $logger->debug("deleting previous link");
                last LINK_SEARCH;
            }
        }

        # initialize new hash if not exist
        $relationship[$one_id] = {} if not $relationship[$one_id];
        my $relation = $relationship[$one_id];

        # value is type so that can retrieve in get_link
        $relation->{$many_id} = $many->_type;
        return $self;
    }

=item get_link()

Retrieves link between objects.

 Type    : Method
 Title   : get_link
 Usage   : $mediator->get_link( 
               -source => $obj, 
               -type   => _CONSTANT_,
           );
 Function: Retrieves link between objects
 Returns : Linked object
 Args    : -source => $obj (required, the source of the link)
           -type   => a constant from Bio::Phylo::Util::CONSTANT

           (-type is optional, used to filter returned results in 
           one-to-many query).

 Comments: This method is called from within, for example, get_taxa
           method calls. A call like $matrix->get_taxa()
           and likewise a call like $forest->get_taxa(), are 
           both internally rerouted to:

           $mediator->get_link( 
               -source => $self # e.g. $matrix or $forest           
           );

           A call like $taxa->get_matrices() is rerouted to:

           $mediator->get_link( -source => $taxa, -type => _MATRIX_ );

=cut

    sub get_link {
        my $self = shift;
        my %opt  = @_;
        my $id   = $opt{'-source'}->get_id;

        # have to get many objects
        if ( defined $opt{'-type'} ) {
            my $relation = $relationship[$id];
            return if not $relation;
            my @result = map { $object[$_] } grep { $relation->{$_} == $opt{'-type'} } keys %{ $relation };
            return \@result;
        }
        else {
            for ( 0 .. $#relationship ) {
                exists $relationship[$_]->{$id} && return $object[$_];
            }
        }
    }

=item remove_link()

Removes link between objects.

 Type    : Method
 Title   : remove_link
 Usage   : $mediator->remove_link( -one => $obj1, -many => $obj2 );
 Function: Removes link between objects
 Returns : $self
 Args    : -one  => $obj1 (source of a one-to-many relationship)
           -many => $obj2 (target of a one-to-many relationship)

           (-many argument is optional)

 Comments: This method is called from within, for example, 
           unset_taxa method calls. A call like $matrix->unset_taxa() 
           is rerouted to:

           $mediator->remove_link( -many => $matrix );

           A call like $taxa->unset_matrix( $matrix ); is rerouted to:

           $mediator->remove_link( -one => $taxa, -many => $matrix );


=cut

    sub remove_link {
        my $self = shift;
        my %opt  = @_;
        my ( $one, $many ) = ( $opt{'-one'}, $opt{'-many'} );
        if ($one) {
            my $id       = $one->get_id;
            my $relation = $relationship[$id];
            return if not $relation;
            delete $relation->{ $many->get_id };
        }
        else {
            my $id = $many->get_id;
          LINK_SEARCH: for my $relation (@relationship) {
                if ( exists $relation->{$id} ) {
                    delete $relation->{$id};
                    last LINK_SEARCH;
                }
            }
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

 $Id: TaxaMediator.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
}
1;
