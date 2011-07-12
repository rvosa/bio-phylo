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
           Optional: -section, -recordSchema

=cut

    my $rss_handler = sub {
		my ($create_method,$self,$twig,$elt) = @_;
		my %known = (
			'title'       => '-name',
			'description' => '-desc',
			'link'        => '-link',
		);
		my  ( %args, @meta );
		for my $child ( $elt->children ) {
			my $tag = $child->tag;
			if ( my $key = $known{$tag} ) {
				$args{$key} = $child->text;
			}
			elsif ( $tag ne 'items' ) {
				my $predicate = $tag;
				my ( $prefix, $namespace, $object );
				if ( $tag =~ /(.+?):/ ) {
					$prefix = $1;
					$namespace = $child->namespace;
				}
				if ( ! ( $object = $child->att('rdf:about') ) ) {
					$object = $child->text;
				}
				push @meta, $fac->create_meta(
					'-namespaces' => { $prefix => $namespace },
					'-triple'     => { $predicate => $object },
				);
			}
		}
		my $obj = $fac->$create_method(%args);
		$obj->add_meta($_) for @meta;
		my $pre  = $self->get_url_prefix;
		my $link = $obj->get_link;
		$link =~ s/^\Q$pre\E(.+?)?/$1/i;
		$obj->set_guid($link);
		return $obj;
    };

    sub get_query_result {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
			
			# these fields need to be set first before get_url returns
			# a sane response
			$self->set_query( $args{'-query'} || throw 'BadArgs' => "Need query argument" );
			$self->set_section( $args{'-section'} || 'taxon' );
			$self->set_format( 'rss1' );
			my $rs  = $args{'-recordSchema'}  || $args{'-section'} || 'taxon';
			my $url = $self->get_url( '-recordSchema' => $rs );
			$url =~ s/&amp;/&/g;
			
			# do the request
			my $response = $ua->($self)->get($url);
			if ( $response->is_success ) {
				my $content = $response->content;
				$self->set_section($rs);
				my $desc;
				eval {
					XML::Twig->new(
						'TwigHandlers' => {
							'channel' => sub {
								$desc = $rss_handler->('create_description',$self,@_);
							},
							'item' => sub {
								my $res = $rss_handler->('create_resource',$self,@_);
								$desc->insert($res);
							},
						}
					)->parse($content);
				};
				if ( $@ ) {
					$logger->fatal("Error fetching from $url");
					$logger->fatal($content);
					throw 'NetworkError' => $@;		    
				}
				else {
					$self->set_section( $args{'-section'} || 'taxon' );
					return $desc;   
				}		
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

=cut

    sub get_record {
        my $self = shift;
        if ( my %args = looks_like_hash @_ ) {
		    $self->set_guid( $args{'-guid'} || throw 'BadArgs' => "Need -guid argument" );
			$self->set_query();
            my $url = $self->get_url( '-format' => 'nexml' );
            $logger->debug($url);
            return parse(
                '-format'     => 'nexml',
                '-url'        => $url,
                '-as_project' => 1,
            );
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
