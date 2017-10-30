package Bio::Phylo::PhyloWS::Client::BGBM::NameSearch;
use strict;
use warnings;
use base 'Bio::Phylo::PhyloWS::Client::BGBM';

my $fac = Bio::Phylo::Factory->new;

sub get_section { 'name' }

sub _parse {
	my ( $obj, $bag ) = @_;
	my %col;
	for my $i ( 0 .. $#{ $obj->{'COLUMNS'} } ) {
		$col{ $obj->{'COLUMNS'}->[$i] } = $i;
	}
	for my $r ( @{ $obj->{'DATA'} } ) {
		my $res = $fac->create_resource(
			'-link' => $obj->{'DATA'}->[ $col{'OBJECTURI'} ],
			'-name' => $obj->{'DATA'}->[ $col{'TITLE'} ],
			'-desc' => $obj->{'DATA'}->[ $col{'TITLEDESCRIPTION'} ],		
		);	
		$bag->insert($res);
	}
}

sub parse_query_result {
	my ( $self, $content ) = @_;
    my $obj = JSON::decode_json($content);
    my $bag = $fac->create_description( 
    	'-link' => $self->get_url,
    	'-name' => $self->get_query,
    );
    _parse($obj,$bag);
    return $bag;
}


1;