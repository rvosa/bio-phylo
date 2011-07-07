package Bio::Phylo::PhyloWS::Service::Ubio;
use strict;
use base 'Bio::Phylo::PhyloWS::Service';
use constant RDFURL => 'http://www.ubio.org/authority/metadata.php?lsid=urn:lsid:ubio.org:namebank:';
use constant UBIOWS => 'http://www.ubio.org/webservices/service.php?function=namebank_search&searchName=%s&sci=1&vern=1&keyCode=%s';
use Bio::Phylo::Util::Dependency qw'XML::Twig LWP::UserAgent';
use Bio::Phylo::Util::CONSTANT qw'looks_like_hash';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::Logger;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Factory;

my $fac = Bio::Phylo::Factory->new;
my $logger = Bio::Phylo::Util::Logger->new;

sub get_supported_formats { [ 'nexml' ] }

sub get_redirect {
    my ( $self, $cgi ) = @_;
    if ( $cgi->param('format') eq 'rdf' ) {
        my $path_info = $cgi->path_info;
        if ( $path_info =~ m/:(\d+)$/ ) {
            my $namebank_id = $1;
            return RDFURL . $namebank_id;
        }
    }
    return;
}

sub get_record {
    my $self = shift;
    my $proj;
    if ( my %args = looks_like_hash @_ ) {
        if ( my $guid = $args{'-guid'} && $args{'-guid'} =~ m|(\d+)$| ) {
            my $namebank_id = $1;
            $logger->info("Going to fetch metadata for record $namebank_id");
            $proj = parse(
                '-url'        => RDFURL . $namebank_id,
                '-format'     => 'ubiometa',
                '-as_project' => 1,
            );
        }
        else {
            throw 'BadArgs' => "No parseable GUID: '$args{-guid}'";
        }
    }
    return $proj;
}

sub get_query_result {
    my ( $self, $query ) = @_;
    throw 'System' => "No UBIO_KEYCODE env var specified" unless $ENV{'UBIO_KEYCODE'};
    my $proj = parse(
        '-url'        => sprintf( UBIOWS, $query, $ENV{'UBIO_KEYCODE'} ),
        '-format'     => 'ubiosearch',
        '-as_project' => 1,
    );
    my ($taxa) = @{ $proj->get_taxa };
    $taxa->visit( sub {
        my $taxon = shift;
        my $lsid  = $taxon->get_meta_object('dc:identifier');
        $logger->info("Going to fold metadata into search result $lsid");
        my $meta_proj = $self->get_record( '-guid' => $lsid );        
        my $meta_taxon = $meta_proj->get_taxa->[0]->first;
        $proj->set_namespaces( $meta_proj->get_namespaces );
        $taxon->add_meta($_) for @{ $meta_taxon->get_meta };
        if ( my $name = $meta_taxon->get_meta_object('dc:subject') ) {
            $taxon->set_name($name);
        }
    } );
    return $proj;    
}

1;