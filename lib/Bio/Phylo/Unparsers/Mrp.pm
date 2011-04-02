# $Id: Mrp.pm 1660 2011-04-02 18:29:40Z rvos $
package Bio::Phylo::Unparsers::Mrp;
use strict;
use base 'Bio::Phylo::Unparsers::Abstract';

=head1 NAME

Bio::Phylo::Unparsers::Mrp - Serializer used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module turns a L<Bio::Phylo::Forest> object into an MRP nexus
formatted matrix. It is called by the L<Bio::Phylo::IO> facade, don't call it
directly.

=begin comment

 Type    : Wrapper
 Title   : _to_string
 Usage   : my $mrp_string = $mrp->_to_string;
 Function: Stringifies a matrix object into
           an MRP nexus formatted table.
 Alias   :
 Returns : SCALAR
 Args    : Bio::Phylo::Matrices::Matrix;

=end comment

=cut

sub _to_string {
    my $self   = shift;
    my $forest = $self->{'PHYLO'};
    my $string = "BEGIN DATA;\n[! Data block written by " . ref $self;
    $string .= " " . $self->VERSION . " on " . localtime() . " ]\n";
    my $taxa = $forest->make_taxa;
    my $ntax = scalar @{ $taxa->get_entities } + 1;    # + 1 for mrp_outgroup
    $string .= "    DIMENSIONS NTAX=$ntax ";
    my $nchar = 0;

    foreach my $tree ( @{ $forest->get_entities } ) {
        foreach my $node ( @{ $tree->get_internals } ) {
            $nchar++;
        }
    }
    $string .= "NCHAR=$nchar;\n";
    $string .= "    FORMAT DATATYPE=STANDARD MISSING=?;\n    MATRIX\n";
    my $length = length('mrp_outgroup');
    foreach my $taxon ( @{ $taxa->get_entities } ) {
        $length = length( $taxon->get_name )
          if length( $taxon->get_name ) > $length;
    }
    $length += 4;
    my $sp = ' ';
    my %mrp;
    foreach my $tree ( @{ $forest->get_entities } ) {
        my %in_tree = map { $_->get_taxon => 1 } @{ $tree->get_terminals };
        my $n = scalar @{ $tree->get_internals };
        foreach my $t ( @{ $taxa->get_entities } ) {
            $mrp{$t} = ( $sp x ( $length - length( $t->get_name ) ) )
              if !defined $mrp{$t};
            if ( exists $in_tree{$t} ) {
                foreach my $node ( @{ $tree->get_internals } ) {
                    my %in_clade =
                      map { $_->get_taxon => 1 } @{ $node->get_terminals };
                    if ( exists $in_clade{$t} ) {
                        $mrp{$t} .= '1';
                    }
                    else {
                        $mrp{$t} .= '0';
                    }
                }
            }
            else {
                $mrp{$t} .= '?' x $n;
            }
        }
    }
    $string .=
      '        mrp_outgroup' . ( $sp x ( $length - length('mrp_outgroup') ) );
    $string .= ( '0' x $nchar ) . "\n";
    foreach my $taxon ( @{ $taxa->get_entities } ) {
        $string .= '        ' . $taxon->get_name;
        $string .= $mrp{$taxon} . "\n";
    }
    $string .= "    ;\nEND;\n";
    return $string;
}

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The newick unparser is called by the L<Bio::Phylo::IO> object.
Look there to learn how to create mrp matrices.

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

 $Id: Mrp.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
1;
