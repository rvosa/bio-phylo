package Bio::Phylo::Taxa::TaxonLinker;
use Bio::Phylo::Mediators::TaxaMediator;
use Bio::Phylo::Util::Exceptions;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Util::CONSTANT qw'_TAXON_ looks_like_object';
use strict;
{
    my $TAXON_CONSTANT = _TAXON_;
    my $logger         = Bio::Phylo::Util::Logger->new;

=head1 NAME

Bio::Phylo::Taxa::TaxonLinker - Superclass for objects that link to taxon objects

=head1 SYNOPSIS

 use Bio::Phylo::Factory;
 my $fac = Bio::Phylo::Factory->new;

 my $node  = $fac->create_node;
 my $taxon = $fac->create_taxon;

 # just to show who's what
 if ( $node->isa('Bio::Phylo::Taxa::TaxonLinker') ) { 
    $node->set_taxon( $taxon );
 }
 
 # prints 'Bio::Phylo::Taxa::Taxon'
 print ref $node->get_taxon 

=head1 DESCRIPTION

This module is a superclass for objects that link to L<Bio::Phylo::Taxa::Taxon>
objects.

=head1 METHODS

=head2 MUTATORS

=over

=item set_taxon()

Links the invocant object to a taxon object.

 Type    : Mutator
 Title   : set_taxon
 Usage   : $obj->set_taxon( $taxon );
 Function: Links the invocant object
           to a taxon object.
 Returns : Modified $obj
 Args    : A Bio::Phylo::Taxa::Taxon object.

=cut

    sub set_taxon {
        my ( $self, $taxon ) = @_;
        if ( $taxon and looks_like_object $taxon, $TAXON_CONSTANT ) {
            $logger->info("setting taxon '$taxon'");
            Bio::Phylo::Mediators::TaxaMediator->set_link(
                '-one'  => $taxon,
                '-many' => $self,
            );
        }
        else {
            $logger->info("re-setting taxon link");
            Bio::Phylo::Mediators::TaxaMediator->remove_link(
                '-many' => $self );
        }
        return $self;
    }

=item unset_taxon()

Unlinks the invocant object from any taxon object.

 Type    : Mutator
 Title   : unset_taxon
 Usage   : $obj->unset_taxon();
 Function: Unlinks the invocant object
           from any taxon object.
 Returns : Modified $obj
 Args    : NONE

=cut

    sub unset_taxon {
        my $self = shift;
        $logger->debug("unsetting taxon");
        $self->set_taxon();
        return $self;
    }

=back

=head2 ACCESSORS

=over

=item get_taxon()

Retrieves the Bio::Phylo::Taxa::Taxon object linked to the invocant.

 Type    : Accessor
 Title   : get_taxon
 Usage   : my $taxon = $obj->get_taxon;
 Function: Retrieves the Bio::Phylo::Taxa::Taxon
           object linked to the invocant.
 Returns : Bio::Phylo::Taxa::Taxon
 Args    : NONE
 Comments:

=cut

    sub get_taxon {
        return Bio::Phylo::Mediators::TaxaMediator->get_link( '-source' => shift );
    }

    sub _cleanup {
        my $self = shift;
    }

=back

=cut

    # podinherit_insert_token

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::Matrices::Datum>

The datum object subclasses L<Bio::Phylo::Taxa::TaxonLinker>.

=item L<Bio::Phylo::Forest::Node>

The node object subclasses L<Bio::Phylo::Taxa::TaxonLinker>.

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
