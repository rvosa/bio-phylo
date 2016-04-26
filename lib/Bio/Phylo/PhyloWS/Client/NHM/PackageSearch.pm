package Bio::Phylo::PhyloWS::Client::NHM::PackageSearch;
use strict;
use base 'Bio::Phylo::PhyloWS::Client::NHM';

my $base = 'http://data.nhm.ac.uk/api/action/datastore_search?resource_id=%s&amp;q=%s';
my $fac  = Bio::Phylo::Factory->new;

sub get_section { 'package_search' }

sub _recurse {
	my ( $obj, $wanted, $bag, $q ) = @_;
	if ( ref($obj) eq 'HASH' and ref($obj->{$wanted}) eq 'ARRAY' ) {
	
		# iterate over resources
		for my $r ( @{ $obj->{$wanted} } ) {
		
			# instantiate resource object
			my $res = $fac->create_resource( 
				'-link' => sprintf($base,$r->{'id'},$q),
				'-name' => $r->{'name'},
				'-desc' => $r->{'description'},
			);
			$bag->insert($res);
		}
	}
	elsif ( ref($obj) eq 'HASH' ) {
		_recurse($_,$wanted,$bag,$q) for values %$obj;		
	}
	elsif ( ref($obj) eq 'ARRAY' ) {
		_recurse($_,$wanted,$bag,$q) for @$obj;
	}
}

sub parse_query_result {
	my ( $self, $content ) = @_;
    my $obj = JSON::decode_json($content);
    my $bag = $fac->create_description( 
     	#-query   => $self->get_query,
    	#-section => $self->get_section,
    	'-link' => $self->get_url,
    	'-name' => $self->get_query,
    );
    _recurse($obj,'resources',$bag,$self->get_query);
    return $bag;
}

1;