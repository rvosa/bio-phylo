package Bio::Phylo::Models::Substitution::Dna::F81;
use strict;
use base 'Bio::Phylo::Models::Substitution::Dna';

# subst rate
sub get_rate {
    my $self = shift;
    return $self->get_pi(shift);
}
sub get_nst { 1 }
1;
