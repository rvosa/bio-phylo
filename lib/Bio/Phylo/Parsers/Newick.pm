# $Id: Newick.pm 1660 2011-04-02 18:29:40Z rvos $
package Bio::Phylo::Parsers::Newick;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';
no warnings 'recursion';

=head1 NAME

Bio::Phylo::Parsers::Newick - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module parses tree descriptions in parenthetical
format. It is called by the L<Bio::Phylo::IO> facade,
don't call it directly.

=cut
sub _return_is_scalar { 1 }

sub _parse {
    my $self   = shift;
    my $fh     = $self->_handle;
    my $forest = $self->_factory->create_forest;
    my $string;
    while (<$fh>) {
        chomp;
        $string .= $_;
    }

    # remove comments, split on tree descriptions
    for my $newick ( $self->_split($string) ) {

        # parse trees
        my $tree = $self->_parse_string($newick);

        # adding labels to untagged nodes
        if ( $self->_args->{'-label'} ) {
            my $i = 1;
            $tree->visit(
                sub {
                    my $n = shift;
                    $n->set_name( 'n' . $i++ ) unless $n->get_name;
                }
            );
        }
        $forest->insert($tree);
    }
    return $forest;
}

=begin comment

 Type    : Parser
 Title   : _split($string)
 Usage   : my @strings = $newick->_split($string);
 Function: Creates an array of (decommented) tree descriptions
 Returns : A Bio::Phylo::Forest::Tree object.
 Args    : $string = concatenated tree descriptions

=end comment

=cut

sub _split {
    my ( $self, $string ) = @_;
    my ( $QUOTED, $COMMENTED ) = ( 0, 0 );
    my $decommented = '';
    my @trees;
  TOKEN: for my $i ( 0 .. length($string) ) {
        if ( !$QUOTED && !$COMMENTED && substr( $string, $i, 1 ) eq "'" ) {
            $QUOTED++;
        }
        elsif ( !$QUOTED && !$COMMENTED && substr( $string, $i, 1 ) eq "[" ) {
            $COMMENTED++;
            next TOKEN;
        }
        elsif ( !$QUOTED && $COMMENTED && substr( $string, $i, 1 ) eq "]" ) {
            $COMMENTED--;
            next TOKEN;
        }
        elsif ($QUOTED
            && !$COMMENTED
            && substr( $string, $i, 1 ) eq "'"
            && substr( $string, $i, 2 ) ne "''" )
        {
            $QUOTED--;
        }
        $decommented .= substr( $string, $i, 1 ) unless $COMMENTED;
        if ( !$QUOTED && !$COMMENTED && substr( $string, $i, 1 ) eq ';' ) {
            push @trees, $decommented;
            $decommented = '';
        }
    }
    $self->_logger->debug("removed comments, split on tree descriptions");
    return @trees;
}

=begin comment

 Type    : Parser
 Title   : _parse_string($string)
 Usage   : my $tree = $newick->_parse_string($string);
 Function: Creates a populated Bio::Phylo::Forest::Tree object from a newick
           string.
 Returns : A Bio::Phylo::Forest::Tree object.
 Args    : $string = a newick tree description

=end comment

=cut

sub _parse_string {
    my ( $self, $string ) = @_;
    my $fac = $self->_factory;
    $self->_logger->debug("going to parse tree string '$string'");
    my $tree      = $fac->create_tree;
    my $remainder = $string;
    my $token;
    my @tokens;
    while ( ( $token, $remainder ) = $self->_next_token($remainder) ) {
        last if ( !defined $token || !defined $remainder );
        $self->_logger->debug("fetched token '$token'");
        push @tokens, $token;
    }
    my $i;
    for ( $i = $#tokens ; $i >= 0 ; $i-- ) {
        last if $tokens[$i] eq ';';
    }
    my $root = $fac->create_node;
    $tree->insert($root);
    $self->_parse_node_data( $root, @tokens[ 0 .. ( $i - 1 ) ] );
    $self->_parse_clade( $tree, $root, @tokens[ 0 .. ( $i - 1 ) ] );
    return $tree;
}

sub _parse_clade {
    my ( $self, $tree, $root, @tokens ) = @_;
    my $fac = $self->_factory;
    $self->_logger->debug("recursively parsing clade '@tokens'");
    my ( @clade, $depth, @remainder );
  TOKEN: for my $i ( 0 .. $#tokens ) {
        if ( $tokens[$i] eq '(' ) {
            if ( not defined $depth ) {
                $depth = 1;
                next TOKEN;
            }
            else {
                $depth++;
            }
        }
        elsif ( $tokens[$i] eq ',' && $depth == 1 ) {
            my $node = $fac->create_node;
            $root->set_child($node);
            $tree->insert($node);
            $self->_parse_node_data( $node, @clade );
            $self->_parse_clade( $tree, $node, @clade );
            @clade = ();
            next TOKEN;
        }
        elsif ( $tokens[$i] eq ')' ) {
            $depth--;
            if ( $depth == 0 ) {
                @remainder = @tokens[ ( $i + 1 ) .. $#tokens ];
                my $node = $fac->create_node;
                $root->set_child($node);
                $tree->insert($node);
                $self->_parse_node_data( $node, @clade );
                $self->_parse_clade( $tree, $node, @clade );
                last TOKEN;
            }
        }
        push @clade, $tokens[$i];
    }
}

sub _parse_node_data {
    my ( $self, $node, @clade ) = @_;
    $self->_logger->debug("parsing name and branch length for node");
    my @tail;
  PARSE_TAIL: for ( my $i = $#clade ; $i >= 0 ; $i-- ) {
        if ( $clade[$i] eq ')' ) {
            @tail = @clade[ ( $i + 1 ) .. $#clade ];
            last PARSE_TAIL;
        }
        elsif ( $i == 0 ) {
            @tail = @clade;
        }
    }

    # name only
    if ( scalar @tail == 1 ) {
        $node->set_name( $tail[0] );
    }
    elsif ( scalar @tail == 2 ) {
        $node->set_branch_length( $tail[-1] );
    }
    elsif ( scalar @tail == 3 ) {
        $node->set_name( $tail[0] );
        $node->set_branch_length( $tail[-1] );
    }
}

sub _next_token {
    my ( $self, $string ) = @_;
    $self->_logger->debug("tokenizing string '$string'");
    my $QUOTED          = 0;
    my $token           = '';
    my $TOKEN_DELIMITER = qr/[():,;]/;
  TOKEN: for my $i ( 0 .. length($string) ) {
        $token .= substr( $string, $i, 1 );
        $self->_logger->debug("growing token: '$token'");
        if ( !$QUOTED && $token =~ $TOKEN_DELIMITER ) {
            my $length = length($token);
            if ( $length == 1 ) {
                $self->_logger->debug("single char token: '$token'");
                return $token, substr( $string, ( $i + 1 ) );
            }
            else {
                $self->_logger->debug(
                    sprintf( "range token: %s",
                        substr( $token, 0, $length - 1 ) )
                );
                return substr( $token, 0, $length - 1 ),
                  substr( $token, $length - 1, 1 )
                  . substr( $string, ( $i + 1 ) );
            }
        }
        if ( !$QUOTED && substr( $string, $i, 1 ) eq "'" ) {
            $QUOTED++;
        }
        elsif ($QUOTED
            && substr( $string, $i, 1 ) eq "'"
            && substr( $string, $i, 2 ) ne "''" )
        {
            $QUOTED--;
        }
    }
}

# podinherit_insert_token

=head1 SEE ALSO

=over

=item L<Bio::Phylo::IO>

The newick parser is called by the L<Bio::Phylo::IO> object.
Look there to learn how to parse newick strings.

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

 $Id: Newick.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
1;
