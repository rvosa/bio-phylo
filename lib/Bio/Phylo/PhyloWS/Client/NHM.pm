package Bio::Phylo::PhyloWS::Client::NHM;
use strict;
use warnings;
use Bio::Phylo::Util::Dependency qw'JSON';
use constant BASE => 'http://data.nhm.ac.uk/api/3/action';
use base 'Bio::Phylo::PhyloWS::Client';

sub get_base_uri { BASE }
sub get_action { '' }
sub get_query_keyword { 'query' }

1;