package Bio::Phylo::PhyloWS::Client::NBA;
use strict;
use warnings;
use Bio::Phylo::Util::Dependency qw'JSON';
use constant BASE => 'http://api.biodiversitydata.nl/v0/';
use base 'Bio::Phylo::PhyloWS::Client';

sub get_base_uri { BASE }
sub get_action { '' }
sub get_query_keyword { '_search' }

1;