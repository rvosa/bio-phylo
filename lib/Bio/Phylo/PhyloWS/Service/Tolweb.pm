package Bio::Phylo::PhyloWS::Service::Tolweb;
use strict;
use base 'Bio::Phylo::PhyloWS::Service';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT qw'looks_like_hash :namespaces';
use constant NODE_URL => 'http://tolweb.org/onlinecontributors/app?service=external&page=xml/TreeStructureService&page_depth=1&node_id=';
use constant SRCH_URL => 'http://tolweb.org/onlinecontributors/app?service=external&page=xml/GroupSearchService&group=';

{
    my $fac    = Bio::Phylo::Factory->new;
    my $logger = Bio::Phylo::Util::Logger->new;

=head1 NAME

Bio::Phylo::PhyloWS::Service::Tolweb - PhyloWS service wrapper for Tree of Life

=head1 SYNOPSIS

 # inside a CGI script:
 use CGI;
 use Bio::Phylo::PhyloWS::Service::Tolweb;

 my $cgi = CGI->new;
 my $service = Bio::Phylo::PhyloWS::Service::Tolweb->new( '-url' => $url );
 $service->handle_request($cgi);

=head1 DESCRIPTION

This is an example implementation of a PhyloWS service. The service
wraps around the tree of life XML service and returns project objects
that include the focal node (identified by its PhyloWS ID) and the 
nearest child and parent nodes that have web pages.

=head1 METHODS

=head2 ACCESSORS

=over

=item get_record()

Gets a tolweb record by its id

 Type    : Accessor
 Title   : get_record
 Usage   : my $record = $obj->get_record( -guid => $guid );
 Function: Gets a tolweb record by its id
 Returns : Bio::Phylo::Project
 Args    : Required: -guid => $guid
 Comments: The guid is of the form 'tree/Tolweb:\d+'

=cut

    sub get_record {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
            if ( $args{'-guid'} && $args{'-guid'} =~ m|(\d+)$| ) {
                my $tolweb_id = $1;
                $logger->info("Getting nexml record for id: $tolweb_id");
                return parse(
                    '-format'     => 'tolweb',
                    '-url'        => NODE_URL . $tolweb_id,
                    '-as_project' => 1,
                );
            }
            else {
                throw 'BadArgs' => "Not a parseable guid: '$args{-guid}'";
            }
        }
    }

=item get_redirect()

Gets a redirect URL if relevant

 Type    : Accessor
 Title   : get_redirect
 Usage   : my $url = $obj->get_redirect;
 Function: Gets a redirect URL if relevant
 Returns : String
 Args    : $cgi
 Comments: This method is called by handle_request so that
           services can 303 redirect a record lookup to 
           another URL. By default, this method returns 
           undef (i.e. no redirect), but if this implementation
           is called to handle a request that specifies 
           'format=html' the request is forwarded to the
           appropriate page on the http://tolweb.org website

=cut

    sub get_redirect {
        my ( $self, $cgi ) = @_;
        if ( $cgi->param('format') eq 'html' ) {
            my $path_info = $cgi->path_info;
            if ( $path_info =~ m/(\d+)$/ ) {
                my $tolweb_id = $1;
                $logger->info("Getting html redirect for id: $tolweb_id");
                return "http://tolweb.org/$tolweb_id";
            }
            else {
                throw 'BadArgs' => "Not a parseable guid: '$path_info'";
            }
        }
        return;
    }

=item get_query_result()

Gets a query result and returns it as a project object

 Type    : Accessor
 Title   : get_query_result
 Usage   : my $proj = $obj->get_query_result($query);
 Function: Gets a query result
 Returns : Bio::Phylo::Project
 Args    : A simple query string for a group lookup

=cut

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
                    my ($name_elt) = $node_elt->children('NAME');
                    $taxa->insert(
                        $fac->create_taxon( '-name' => $name_elt->text )->add_meta(
                            $fac->create_meta( '-triple' => { 'tba:id' => $id } )
                        )
                    );
                }
            }
        )->parseurl( SRCH_URL . $query );
        return $proj;
    }

=item get_supported_formats()

Gets an array ref of supported formats

 Type    : Accessor
 Title   : get_supported_formats
 Usage   : my @formats = @{ $obj->get_supported_formats };
 Function: Gets an array ref of supported formats
 Returns : [ qw(nexml nexus newick html) ]
 Args    : NONE

=cut

    sub get_supported_formats { [qw(nexml nexus newick html)] }

=back

=cut

    # podinherit_insert_token

=head1 SEE ALSO

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Tolweb.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
}
1;
