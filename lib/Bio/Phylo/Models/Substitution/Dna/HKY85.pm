package Bio::Phylo::Models::Substitution::Dna::HKY85;
use strict;
use base
  qw'Bio::Phylo::Models::Substitution::Dna::K80 Bio::Phylo::Models::Substitution::Dna::F81';
my %purines = ( 'A' => 1, 'G' => 1 );

# subst rate
sub get_rate {
    my $self = shift;
    if ( scalar @_ == 2 ) {
        my ( $src, $trgt ) = ( uc $_[0], uc $_[1] );

        # transversion
        if ( $purines{$src} xor $purines{$trgt} ) {
            return $self->get_kappa * $self->get_rate($src);
        }

        # transition
        else {
            return $self->get_rate($src);
        }
    }
}
sub get_nst { 2 }
1;
