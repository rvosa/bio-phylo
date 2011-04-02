package Bio::Phylo::Models::Substitution::Dna::K80;
use strict;
use base 'Bio::Phylo::Models::Substitution::Dna::JC69';
my %purines = ( 'A' => 1, 'G' => 1 );

# subst rate
sub get_rate {
    my $self = shift;
    if ( scalar @_ == 2 ) {
        my ( $src, $trgt ) = ( uc $_[0], uc $_[1] );

        # transversion
        if ( $purines{$src} xor $purines{$trgt} ) {
            return $self->get_kappa;
        }

        # transition
        else {
            return 1;
        }
    }
}
sub get_nst { 2 }
1;
