package Bio::Phylo::Matrices;
use strict;
use base 'Bio::Phylo::Listable';
use Bio::Phylo::Util::CONSTANT qw'_NONE_ _MATRICES_';

=begin comment

This class has no internal state, no cleanup is necessary.

=end comment

=cut

{
    my $TYPE      = _MATRICES_;
    my $CONTAINER = _NONE_;
    my $logger    = __PACKAGE__->get_logger;

=head1 NAME

Bio::Phylo::Matrices - Container of matrix objects

=head1 SYNOPSIS

 use Bio::Phylo::Matrices;
 use Bio::Phylo::Matrices::Matrix;

 my $matrices = Bio::Phylo::Matrices->new;
 my $matrix   = Bio::Phylo::Matrices::Matrix->new;

 $matrices->insert($matrix);

=head1 DESCRIPTION

The L<Bio::Phylo::Matrices> object models a set of matrices. It inherits from
the L<Bio::Phylo::Listable> object, and so the filtering methods of that object
are available to apply to a set of matrices.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

Matrices constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $matrices = Bio::Phylo::Matrices->new;
 Function: Initializes a Bio::Phylo::Matrices object.
 Returns : A Bio::Phylo::Matrices object.
 Args    : None required.

=cut

    #    sub new {
    #        # could be child class
    #        my $class = shift;
    #
    #        # notify user
    #        $logger->info("constructor called for '$class'");
    #
    #        # recurse up inheritance tree, get ID
    #        my $self = $class->SUPER::new( @_ );
    #
    #        # local fields would be set here
    #
    #        return $self;
    #    }

=begin comment

 Type    : Internal method
 Title   : _container
 Usage   : $matrices->_container;
 Function:
 Returns : CONSTANT
 Args    :

=end comment

=cut

    sub _container { $CONTAINER }

=begin comment

 Type    : Internal method
 Title   : _type
 Usage   : $matrices->_type;
 Function:
 Returns : CONSTANT
 Args    :

=end comment

=cut

    sub _type { $TYPE }

=back

=cut

    # podinherit_insert_token

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::Listable>

The L<Bio::Phylo::Matrices> object inherits from the L<Bio::Phylo::Listable>
object. Look there for more methods applicable to the matrices object.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=cut

}
1;
