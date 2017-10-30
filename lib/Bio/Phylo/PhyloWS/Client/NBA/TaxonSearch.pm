package Bio::Phylo::PhyloWS::Client::NBA::TaxonSearch;
use strict;
use warnings;
use base 'Bio::Phylo::PhyloWS::Client::NBA';

=head1 NAME

Bio::Phylo::PhyloWS::Client::NBA::TaxonSearch - Search NBA for taxa

=head1 SYNOPSIS

 use Bio::Phylo::PhyloWS::Client::NBA::TaxonSearch;
 
 # instantiate an NBA taxon search client object
 my $ts = Bio::Phylo::PhyloWS::Client::NBA::TaxonSearch->new;
 
 # run a query. This example shows a free text search, for 
 # indexed field searches see: 
 # http://docs.biodiversitydata.nl/en/latest/api_taxonomic_data_services.html#indexed-field-name-s-in-an-url
 my $qr = $ts->get_query_result( -query => '_search=Abies' );
 
 # the query result is a Bio::Phylo::PhyloWS::Resource::Description,
 # over which we can iterate using Listable methods
 $qr->visit(sub{
 
 	# each item is reference to a record that we can fetch, 
 	# which then becomes a Bio::Phylo::Project object
 	my $proj = $ts->get_record( -guid => shift->get_guid );
 	print $proj->to_xml;
 });

=cut

my $fac = Bio::Phylo::Factory->new;

sub get_section { 'taxon/search' }

sub _recurse {
	my ( $obj, $wanted, $bag ) = @_;
	if ( ref($obj) eq 'HASH' and $obj->{$wanted} ) {
		my $res = $fac->create_resource( 
			#-guid      => $obj->{$wanted},
			#-authority => 'CoL',
			#-section   => __PACKAGE__->get_section,
			-link => $obj->{$wanted},
		);
		$bag->insert($res);
	}
	elsif ( ref($obj) eq 'HASH' ) {
		_recurse($_,$wanted,$bag) for values %$obj;		
	}
	elsif ( ref($obj) eq 'ARRAY' ) {
		_recurse($_,$wanted,$bag) for @$obj;
	}
}

sub parse_query_result {
	my ( $self, $content ) = @_;
    my $obj = JSON::decode_json($content);
    my $bag = $fac->create_description( 
     	#-query   => $self->get_query,
    	#-section => $self->get_section,
    	-link => $self->get_url,
    	-name => $self->get_query,
    );
    _recurse($obj,'recordURI',$bag);
    return $bag;
}

1;