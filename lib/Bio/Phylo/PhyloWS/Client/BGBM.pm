package Bio::Phylo::PhyloWS::Client::BGBM;
use strict;
use warnings;
use Bio::Phylo::Util::Dependency qw'JSON';
use constant BASE => 'http://ww2.bgbm.org/rest/herb/';
use base 'Bio::Phylo::PhyloWS::Client';

sub get_base_uri { BASE }

sub get_url {
	my $self = shift;
	my $section = $self->get_section;
	my $base    = $self->get_base_uri;
	my $query   = $self->get_query;
	my $url = $base . $section . '/' . $query;
	return $url;
}

1;