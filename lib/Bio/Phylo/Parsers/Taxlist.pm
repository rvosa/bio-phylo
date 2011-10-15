package Bio::Phylo::Parsers::Taxlist;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';

=head1 NAME

Bio::Phylo::Parsers::Taxlist - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module is used for importing sets of taxa from plain text files, one taxon
on each line. It is called by the L<Bio::Phylo::IO|Bio::Phylo::IO> object, so
look there for usage examples. If you want to parse from a string, you
may need to indicate the field separator (default is '\n') to the
Bio::Phylo::IO->parse call:

 -fieldsep => '\n',

=cut

sub _parse {
    my $self = shift;
    my $fh   = $self->_handle;
    my $fac  = $self->_factory;
    my $taxa = $fac->create_taxa;
    local $/ = $self->_args->{'-fieldsep'} || "\n";
    while (<$fh>) {
        chomp;
        $taxa->insert( $fac->create_taxon( '-name' => $_ ) );
    }
    return $taxa;
}

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The taxon list parser is called by the L<Bio::Phylo::IO> object.
Look there for examples.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Taxlist.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
1;
