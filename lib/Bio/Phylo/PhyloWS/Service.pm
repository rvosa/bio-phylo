package Bio::Phylo::PhyloWS::Service;
use strict;
use base 'Bio::Phylo::PhyloWS';
use Bio::Phylo::Factory;
use Bio::Phylo::IO 'unparse';
use Bio::Phylo::Util::CONSTANT qw'looks_like_hash _HTTP_SC_SEE_ALSO_';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::Dependency 'URI::Escape';
use Bio::Phylo::Util::Logger;
{
    my $fac = Bio::Phylo::Factory->new;
    my $logger = Bio::Phylo::Util::Logger->new;

=head1 NAME

Bio::Phylo::PhyloWS::Service - Base class for phylogenetic web services

=head1 SYNOPSIS

 # inside a CGI script:
 use CGI;
 use Bio::Phylo::PhyloWS::Service::${child};

 my $cgi = CGI->new;
 my $service = Bio::Phylo::PhyloWS::Service::${child}->new( '-url' => $url );
 $service->handle_request($cgi);

=head1 DESCRIPTION

This is the base class for services that implement 
the PhyloWS (L<http://evoinfo.nescent.org/PhyloWS>) recommendations.
Such services should subclass this class and implement any relevant
abstract methods.

=head1 METHODS

=head2 REQUEST HANDLER

=over

=item handle_request()

 Type    : Request handler
 Title   : handle_request
 Usage   : $service->handle_request($cgi);
 Function: Handles a service request
 Returns : prints out response and exits
 Args    : Required: a CGI.pm object

=cut

    sub handle_request {
        my ( $self, $cgi ) = @_;    # CGI.pm
        my $path_info = $cgi->path_info;
        if ( $path_info =~ m|.*/phylows/(.+?)$| ) {
            my $guid = $1;
            if ( my $redirect = $self->get_redirect($cgi) ) {
                print $cgi->redirect(
                    '-uri'    => $redirect,
                    '-status' => _HTTP_SC_SEE_ALSO_,
                );
            }
            elsif ( $guid !~ m|/find/?| ) {
                if ( my $format = $cgi->param('format') ) {
                    print $cgi->header(
                        $Bio::Phylo::PhyloWS::MIMETYPE{$format} );
                    print $self->get_serialization(
                        '-guid'   => $guid,
                        '-format' => $format,
                    );
                }
                else {
                    print $cgi->header( $Bio::Phylo::PhyloWS::MIMETYPE{'rdf'} );
                    print $self->get_description( '-guid' => $guid )->to_xml;
                }
            }
            else {
                my $query = $cgi->param('query');
                if ( my $format = $cgi->param('format') ) {
                    my $project = $self->get_query_result($query);
                    print $cgi->header(
                        $Bio::Phylo::PhyloWS::MIMETYPE{$format} );
                    print unparse( '-phylo' => $project, '-format' => $format,
                    );
                }
                else {
                    print $cgi->header( $Bio::Phylo::PhyloWS::MIMETYPE{'rdf'} );
                    print $self->get_description( '-guid' => 'tree/find?query='
                          . URI::Escape::uri_escape($query) )->to_xml;
                }
            }
            exit(0);
        }
        else {
            $logger->warn("'$path_info' is not a PhyloWS URL");
        }
    }

=back

=head2 ACCESSORS

=over

=item get_serialization()

Gets serialization of the provided record

 Type    : Accessor
 Title   : get_serialization
 Usage   : my $serialization = $obj->get_serialization( 
               -guid   => $guid, 
               -format => $format 
           );
 Function: Returns a serialization of a PhyloWS database record
 Returns : A string
 Args    : Required: -guid => $guid, -format => $format

=cut

    sub get_serialization {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
            if ( my $guid = $args{'-guid'} and my $format = $args{'-format'} ) {
                my $project = $self->get_record( '-guid' => $guid );
                return unparse( '-format' => $format, '-phylo' => $project );
            }
        }
    }

=item get_record()

Gets a phylows record by its id

 Type    : Abstract Accessor
 Title   : get_record
 Usage   : my $record = $obj->get_record( -guid => $guid );
 Function: Gets a phylows record by its id
 Returns : Bio::Phylo::Project
 Args    : Required: -guid => $guid, 
           Optional: -format => $format
 Comments: This is an ABSTRACT method that needs to be implemented
           by a child class

=cut

    sub get_record {
        my $self = shift;
        throw 'NotImplemented' => 'Method get_record should be in '
          . ref($self)
          . ", but isn't";
    }

=item get_query_result()

Gets a phylows cql query result

 Type    : Abstract Accessor
 Title   : get_query_result
 Usage   : my $result = $obj->get_query_result( $query );
 Function: Gets a query result 
 Returns : Bio::Phylo::Project
 Args    : Required: $query
 Comments: This is an ABSTRACT method that needs to be implemented
           by a child class

=cut

    sub get_query_result {
        my $self = shift;
        throw 'NotImplemented' => 'Method get_query_result should be in '
          . ref($self)
          . ", but isn't";
    }

=item get_supported_formats()

Gets an array ref of supported formats

 Type    : Abstract Accessor
 Title   : get_supported_formats
 Usage   : my @formats = @{ $obj->get_supported_formats };
 Function: Gets an array ref of supported formats
 Returns : ARRAY
 Args    : NONE
 Comments: This is an ABSTRACT method that needs to be implemented
           by a child class

=cut

    sub get_supported_formats {
        my $self = shift;
        throw 'NotImplemented' => 'Method get_supported_formats should be in '
          . ref($self)
          . ", but isn't";
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
           undef (i.e. no redirect)

=cut

    sub get_redirect {
        my ( $self, $cgi ) = @_;
        return;
    }

=item get_description()

Gets an RSS1.0/XML representation of a phylows record

 Type    : Accessor
 Title   : get_description
 Usage   : my $desc = $obj->get_description;
 Function: Gets an RSS1.0/XML representation of a phylows record
 Returns : String
 Args    : Required: -guid => $guid
 Comments: This method creates a representation of a single record
           (i.e. the service's base url + the record's guid)
           that can be serialized in whichever formats are 
           supported

=cut

    sub get_description {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
            if ( my $id = $args{'-guid'} ) {
                my $desc = $fac->create_description(
                    '-url'  => $self->get_url,
                    '-guid' => $id,
                    @_,
                );
                for my $format ( @{ $self->get_supported_formats } ) {
                    $desc->insert(
                        $fac->create_resource(
                            '-format' => $format,
                            '-url'    => $self->get_url,
                            '-guid'   => $id,
                            '-name'   => $format,
                            '-desc' =>
                              "A $format serialization of the resource",
                            @_,
                        )
                    );
                }
                return $desc;
            }
        }
    }

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

 $Id: Service.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
}
1;
