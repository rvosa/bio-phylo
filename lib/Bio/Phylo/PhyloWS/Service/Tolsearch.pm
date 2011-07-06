package Bio::Phylo::PhyloWS::Service::Tolsearch;
use strict;
use base 'Bio::Phylo::PhyloWS::Service';
use constant WEBURL => 'http://tolweb.org/tree/home.pages/searchTOL?taxon=';
use constant XMLURL => 'http://tolweb.org/onlinecontributors/app?service=external&page=xml/GroupSearchService&group=';
use Bio::Phylo::Util::Dependency qw'XML::Twig LWP::UserAgent';
use Bio::Phylo::Util::CONSTANT qw':namespaces';
use Bio::Phylo::Factory;

my $fac = Bio::Phylo::Factory->new;

sub get_supported_formats { [ 'nexml', 'html' ] }

sub get_redirect {
    my ( $self, $cgi ) = @_;
    if ( $cgi->param('format') eq 'html' ) {
        return WEBURL . $cgi->param('query');
    }
    return;
}

sub get_query_result {
    my ( $self, $query ) = @_;
    my $proj = $fac->create_project;
    my $taxa = $fac->create_taxa;
    $taxa->set_namespaces( 'tba' => _NS_TWA_ );
    $proj->insert( $taxa );
    XML::Twig->new(
        'twig_handlers' => {
            'NODE' => sub {
                my ( $twig, $node_elt ) = @_;
                my $id = $node_elt->att('ID');
                my ($name_elt) = $node_elt->children('name');
                $taxa->insert(
                    $fac->create_taxon( '-name' => $name_elt->text )->add_meta(
                        $fac->create_meta( '-triple' => { 'tba:id' => $id } )
                    )
                );
            }
        }
    )->parseurl( XMLURL . $query );
    return $proj;
}

1;