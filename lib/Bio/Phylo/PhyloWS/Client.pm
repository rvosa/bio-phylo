package Bio::Phylo::PhyloWS::Client;
use strict;
use base 'Bio::Phylo::PhyloWS';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT 'looks_like_hash';
use Bio::Phylo::Util::Dependency qw'LWP::UserAgent XML::Twig';
{
    my @fields = \( my (%ua) );
    my $logger = Bio::Phylo::Util::Logger->new;
    my $fac    = Bio::Phylo::Factory->new;

=head1 NAME

Bio::Phylo::PhyloWS::Client - Base class for phylogenetic web service clients

=head1 SYNOPSIS

 #!/usr/bin/perl
 use strict;
 use warnings;
 use Bio::Phylo::Factory;
 
 my $fac = Bio::Phylo::Factory->new;
 my $client = $fac->create_client( '-url' => 'http://nexml-dev.nescent.org/nexml/phylows/tolweb/phylows/' );
 my $desc = $client->get_query_result( 
	'-query'        => 'Homo sapiens', 
	'-section'      => 'taxon',
 );
 for my $res ( @{ $desc->get_entities } ) {
	my $proj = $client->get_record( '-guid' => $res->get_guid );
	print $proj->to_nexus, "\n";
 }

=head1 DESCRIPTION

This is the base class for clients connecting to services that implement 
the PhyloWS (L<http://evoinfo.nescent.org/PhyloWS>) recommendations.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

 Type    : Constructor
 Title   : new
 Usage   : my $phylows = Bio::Phylo::PhyloWS::Client->new( -url => $url );
 Function: Instantiates Bio::Phylo::PhyloWS::Client object
 Returns : a Bio::Phylo::PhyloWS::Client object 
 Args    : Required: -url => $url
           Optional: any number of setters. For example,
 		   Bio::Phylo::PhyloWS->new( -name => $name )
 		   will call set_name( $name ) internally

=cut

    sub new {

        # could be child class
        my $class = shift;

        # go up inheritance tree, eventually get an ID
        my $self = $class->SUPER::new(@_);

        # store a user agent object to delegate http stuff to
        my $ua = LWP::UserAgent->new;
        $ua->timeout(300);
        $ua->env_proxy;
        $ua{ $self->get_id } = $ua;
        return $self;
    }
    my $ua = sub {
        return $ua{ shift->get_id };
    };
    my $itemhandler = sub {
        my ( $self, $elt, $twig ) = @_;
        my $raw = $twig->att('rdf:about');
        if ( $raw =~ m|(.*phylows/)(.+)| ) {
            my ( $url, $guid ) = ( $1, $2 );
            my $res = $fac->create_resource(
                '-guid' => $guid,
                '-url'  => $url,
            );
            for my $title ( $twig->children('title') ) {
                $res->set_name( $title->text() );
            }
            for my $desc ( $twig->children('description') ) {
                $res->set_desc( $desc->text() );
            }
            $self->insert($res);
        }
        else {
            die "no match: $raw";
        }
    };

=back

=head2 ACCESSORS

=over

=item get_query_result()

Gets search query result

 Type    : Accessor
 Title   : get_query_result
 Usage   : my $res = $obj->get_query_result( -query => $query );
 Function: Returns Bio::Phylo::PhyloWS::Description object
 Returns : A string
 Args    : Required: -query => $cql_query
           Optional: -format, -section, -recordSchema

=cut

    sub get_query_result {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
            my $query = $args{'-query'}
              || throw 'BadArgs' => "Need query argument";
            my $format  = $args{'-format'}       || 'rss1';
            my $section = $args{'-section'}      || 'taxon';
            my $schema  = $args{'-recordSchema'} || $section;
            my $url     = $self->get_url(
                '-query'        => $query,
                '-format'       => $format,
                '-section'      => $section,
                '-recordSchema' => $schema,
            );
            my $response = $ua->($self)->get($url);
            if ( $response->is_success ) {
                my $desc =
                  $fac->create_description( '-url' => $url, '-guid' => 'find' );
                my $t = XML::Twig->new(
                    'TwigHandlers' => {
                        'item' => sub { $itemhandler->( $desc, @_ ) }
                    }
                );
                my $content = $response->content;
                $t->parse($content);
                return $desc;
            }
            else {
                throw 'NetworkError' => $response->status_line;
            }
        }
    }

=item get_record()

Gets a PhyloWS database record

 Type    : Accessor
 Title   : get_record
 Usage   : my $rec = $obj->get_record( -guid => $guid );
 Function: Gets a PhyloWS database record
 Returns : Bio::Phylo::Project object
 Args    : Required: -guid => $guid
           Optional: -format (default: nexml)

=cut

    sub get_record {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
            my $guid = $args{'-guid'}
              || throw 'BadArgs' => "Need -guid argument";
            my $format = $args{'-format'} || 'nexml';
            $logger->debug("format => $format, guid => $guid");
            my $url = $self->get_url(
                '-guid'   => $guid,
                '-format' => $format,
            );
            $logger->debug($url);
            my $response = $ua->($self)->get($url);
            if ( $response->is_success ) {
                $logger->debug("HTTP response is success");
                my $content = $response->content;
                $logger->debug($content);
                if ( my $project = $args{'-project'} ) {
                    $logger->debug("have defined project to populate");
                    return parse(
                        '-format'  => $format,
                        '-string'  => $content,
                        '-project' => $project,
                    );
                }
                else {
                    $logger->debug("will create new project");
                    return parse(
                        '-format'     => $format,
                        '-string'     => $content,
                        '-as_project' => 1,
                    );
                }
            }
            else {
                throw 'NetworkError' => $response->status_line;
            }
        }
    }

    sub _cleanup {
        my $self = shift;
        my $id   = $self->get_id;
        for my $field (@fields) {
            delete $field->{$id};
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

 $Id: Client.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
}
1;
