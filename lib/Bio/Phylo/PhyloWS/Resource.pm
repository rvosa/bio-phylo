package Bio::Phylo::PhyloWS::Resource;
use strict;
use base qw'Bio::Phylo::PhyloWS Bio::Phylo::NeXML::Writable';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT qw'_DESCRIPTION_ _RESOURCE_';
use Bio::Phylo::Util::Logger;
{
    my @fields = \( my ( %guid, %format ) );
    my $logger = Bio::Phylo::Util::Logger->new;

=head1 NAME

Bio::Phylo::PhyloWS::Resource - Represents a PhyloWS web resource

=head1 SYNOPSIS

 # no direct usage

=head1 DESCRIPTION

This class represents a resource on the web that implements the PhyloWS
recommendations.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

 Type    : Constructor
 Title   : new
 Usage   : my $phylows = Bio::Phylo::PhyloWS::Resource->new( -guid => $guid );
 Function: Instantiates Bio::Phylo::PhyloWS::Resource object
 Returns : a Bio::Phylo::PhyloWS::Resource object 
 Args    : Required: -guid => $guid
           Optional: any number of setters. For example,
 		   Bio::Phylo::PhyloWS::Resource->new( -format => $format )
 		   will call set_format( $format ) internally

=cut

    sub new {
        my $self = shift->SUPER::new( '-tag' => 'item', @_ );
        if ( not $self->get_guid ) {
            throw 'BadArgs' => 'Need -guid argument';
        }
        return $self;
    }

=back

=head2 MUTATORS

=over

=item set_guid()

Sets invocant guid.

 Type    : Mutator
 Title   : set_guid
 Usage   : $obj->set_guid($guid);
 Function: Assigns an object's guid.
 Returns : Modified object.
 Args    : Argument must be a string.

=cut

    sub set_guid {
        my ( $self, $base ) = @_;
        $guid{ $self->get_id } = $base;
        return $self;
    }

=item set_format()

Sets invocant's preferred serialization format.

 Type    : Mutator
 Title   : set_format
 Usage   : $obj->set_format($format);
 Function: Assigns an object's serialization format.
 Returns : Modified object.
 Args    : Argument must be a string.

=cut

    sub set_format {
        my ( $self, $base ) = @_;
        $format{ $self->get_id } = $base;
        return $self;
    }

=back

=head2 ACCESSORS

=over

=item get_guid()

Gets invocant's guid.

 Type    : Accessor
 Title   : get_guid
 Usage   : my $guid = $obj->get_guid;
 Function: Returns the object's guid.
 Returns : A string
 Args    : None

=cut

    sub get_guid {
        return $guid{ shift->get_id };
    }

=item get_format()

Gets invocant's preferred serialization format

 Type    : Accessor
 Title   : get_format
 Usage   : my $format = $obj->get_format;
 Function: Returns the object's preferred serialization format
 Returns : A string
 Args    : None

=cut

    sub get_format {
        return $format{ shift->get_id };
    }

=item get_full_url()

Gets invocant's full url (i.e. including query string)

 Type    : Accessor
 Title   : get_full_url
 Usage   : my $url = $obj->get_full_url;
 Function: Returns the object's full url
 Returns : A string
 Args    : None

=cut

    sub get_full_url {
        my $self = shift;
	my ( $url, $guid ) = ( $self->get_url, $self->get_guid );
	my $full = $url . $guid;
	$logger->debug("URL=$url, GUID=$guid");
	$logger->debug("FULL=$full");
        if ( my $format = $self->get_format ) {
	    $logger->debug("Will add format paramer for $format serialization");	    
            if ( $full !~ m/\?/ ) {
                return $full . '?format=' . $format;
            }
            else {
                return $full . '&amp;format=' . $format;
            }
        }
        else {
            return $full;
        }
    }

=back

=head2 TESTS

=over

=item is_identifiable()

Tests if invocant has an xml id attribute

 Type    : Test
 Title   : is_identifiable
 Usage   : if ( $obj->is_identifiable ) {
              # do something
           }
 Function: Tests if invocant has an xml id attribute
 Returns : FALSE
 Args    : NONE

=cut
    sub is_identifiable { 0 }

=back

=head2 SERIALIZERS

=over

=item to_xml()

Serializes resource to RSS1.0 XML representation

 Type    : Serializer
 Title   : to_xml()
 Usage   : print $obj->to_xml();
 Function: Serializes object to RSS1.0 XML string
 Returns : String 
 Args    : None
 Comments:

=cut

    #   <item rdf:about="${baseURL}/${phyloWSPath}?format=nexus">
    #     <title>Nexus file</title>
    #     <link>${baseURL}/${phyloWSPath}?format=nexus</link>
    #     <description>A Nexus serialization of the resource</description>
    #     <dc:format>text/plain</dc:format>
    #   </item>
    sub to_xml {
        my $self = shift;
        my $tag  = $self->get_tag;

# <item rdf:about="http://localhost/nexml/service/tolweb/phylows/tree/Tolweb:15040?format=nexml">
        my $xml = '<' . $tag . ' rdf:about="' . $self->get_full_url . '">';
        $xml .= '<title>' . $self->get_name . '</title>';
        $xml .= '<link>' . $self->get_full_url . '</link>';
        $xml .= '<description>' . $self->get_desc . '</description>';
        if ( my $format = $self->get_format ) {
            $xml .=
                '<dc:format>'
              . $Bio::Phylo::PhyloWS::MIMETYPE{$format}
              . '</dc:format>';
        }
        $xml .= '</' . $tag . '>';
        return $xml;
    }
    sub _container { _DESCRIPTION_ }
    sub _type      { _RESOURCE_ }

    sub _cleanup {
        my $self = shift;
        my $id   = $self->get_id;
        delete $_->{$id} for @fields;
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

 $Id: Resource.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
}
1;
