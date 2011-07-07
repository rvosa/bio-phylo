package Bio::Phylo::Parsers::Ubiometa;
use base 'Bio::Phylo::Parsers::Abstract';
use Bio::Phylo::Util::Dependency 'XML::Twig';
use strict;

=head1 NAME

Bio::Phylo::Parsers::Ubiometa - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module parses RDF metadata for uBio namebank records. An example of such a
record is here: L<http://www.ubio.org/authority/metadata.php?lsid=urn:lsid:ubio.org:namebank:2481730>

The parser creates a single L<Bio::Phylo::Taxa::Taxon> object to which all
metadata are attached as L<Bio::Phylo::NeXML::Meta> objects. This taxon is
embedded in a taxa block, or optionally in a L<Bio::Phylo::Project> object
if the C<-as_project> flag was provided to the call to C<parse()>.

=cut

my $SAFE_CHARACTERS_REGEX = qr/(?:[a-zA-Z0-9]|-|_|\.)/;
my $XMLEntityEncode       = sub {
    my $buf = '';
    for my $c ( split //, shift ) {
        if ( $c =~ $SAFE_CHARACTERS_REGEX ) {
            $buf .= $c;
        }
        else {
            $buf .= '&#' . ord($c) . ';';
        }
    }
    return $buf;
};

sub _parse {
    my $self = shift;
    my $fac  = $self->_factory;
    my $taxa = $fac->create_taxa;
    XML::Twig->new(
        'twig_handlers' => {
            'rdf:RDF' => sub {
                my ( $twig, $elt ) = @_;
                my $taxon = $fac->create_taxon;
                for my $att_name ( $elt->att_names ) {
                    if ( $att_name =~ /xmlns:(\S+)/ ) {
                        my $prefix = $1;
                        my $ns = $elt->att($att_name);
                        $taxon->set_namespaces( $prefix => $ns );
                    }
                }
                my ($child) = $elt->children('rdf:Description');
                for my $meta_elt ( $child->children ) {
                    my $val = $meta_elt->att('rdf:resource') || $meta_elt->text;
                    my $key = $meta_elt->tag;
                    if ( $val =~ /^http:/ || $val =~ /^urn:/ ) {
                        $val =~ s/&/&amp;/g;
                    }
                    else {
                        $val = $XMLEntityEncode->($val);
                    }
                    $taxon->add_meta( $fac->create_meta(
                        '-triple' => { $key => $val }                    
                    ) );
                }
                $taxa->insert($taxon);
            }
        }
    )->parse($self->_string);
    return $taxa;
}

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The uBio metadata parser is called by the L<Bio::Phylo::IO> object.
Look there to learn more about parsing.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Table.pm 1660 2011-04-02 18:29:40Z rvos $

=cut

1;
