package Bio::Phylo::Models::Substitution::Dna::JC69;
use strict;
use base 'Bio::Phylo::Models::Substitution::Dna';

# base freq
sub get_pi { 0.25 }

# substitution rate
sub get_rate { shift->get_mu / 4 }
sub get_nst  { 1 }
sub get_catweights { [1.0] }
sub get_catrates { [1.0] }
1;
