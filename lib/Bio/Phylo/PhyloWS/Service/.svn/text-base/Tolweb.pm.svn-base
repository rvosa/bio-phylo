package Bio::Phylo::PhyloWS::Service::Tolweb;
use strict;
use base 'Bio::Phylo::PhyloWS::Service';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Util::CONSTANT 'looks_like_hash';
use constant URL => 'http://150.135.239.5/onlinecontributors/app?service=external&page=xml/TreeStructureService&page_depth=1&node_id=';

# http://localhost/nexml/service/tolweb/phylows/tree/Tolweb:3?format=nexml

{

    my $fac = Bio::Phylo::Factory->new;
    my $logger = Bio::Phylo::Util::Logger->new;
    $logger->VERBOSE(
        '-level' => 4,
        '-class' => 'Bio::Phylo::Parsers::Tolweb',
    );

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
            if ( my $guid = $args{'-guid'} ) {
                if ( $guid =~ m|^tree/Tolweb:(\d+)$| ) {
                    my $tolweb_id = $1;
                    return parse(
                        '-format'     => 'tolweb',
                        '-url'        => URL . $tolweb_id,
                        '-as_project' => 1,
                    );        
                }
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
            if ( $path_info =~ m/:(\d+)$/ ) {
                my $tolweb_id = $1;
                return "http://tolweb.org/$tolweb_id";
            }
        }
        return;
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

    sub get_supported_formats { [ qw(nexml nexus newick html) ] }

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

 $Id$

=cut

}

1;