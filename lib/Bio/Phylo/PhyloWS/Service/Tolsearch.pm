package Bio::Phylo::PhyloWS::Service::Tolsearch;
use base 'Bio::Phylo::PhyloWS::Service';
use strict;
use constant URL => 'http://tolweb.org/tree/home.pages/searchTOL?taxon=';

sub get_supported_formats { [ 'nexml', 'html' ] }

sub get_redirect {
    my ( $self, $cgi ) = @_;
    if ( $cgi->param('format') eq 'html' ) {
        return URL . $cgi->param('query');
    }
    return;
}

1;