package Bio::Phylo::Unparsers::Figtree;
use strict;
use base 'Bio::Phylo::Unparsers::Nexus';
use Bio::Phylo::Util::CONSTANT qw':objecttypes :namespaces';
use Bio::Phylo::Util::Exceptions 'throw';

my $ns  = _NS_FIGTREE_;
my $pre = 'fig';

=head1 NAME

Bio::Phylo::Unparsers::Figtree - Serializer used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module turns objects into a nexus-formatted string that uses additional
syntax for Figtree. It is called by the L<Bio::Phylo::IO> facade, don't call it
directly. You can pass the following additional arguments to the unparse call:
	
=begin comment

 Type    : Wrapper
 Title   : _to_string($obj)
 Usage   : $figtree->_to_string($obj);
 Function: Stringifies an object into
           a nexus/figtree formatted string.
 Alias   :
 Returns : SCALAR
 Args    : Bio::Phylo::*

=end comment

=cut

sub _to_string {
    my $self = shift;
	$self->{'FOREST_ARGS'} = {
		'-nodelabels' => \&_figtree_handler,
	};
	return $self->SUPER::_to_string(@_);
}

sub _figtree_handler {
	my ( $node, $id ) = @_;
	my %meta = map { $_->get_predicate_local => $_->get_object }
	          grep { $_->get_predicate_namespace eq $ns }
	              @{ $node->get_meta };
	my %merged;
	KEY: for my $key ( keys %meta ) {
		if ( $key =~ /^(.+?)_min$/ ) {
			my $stem = $1;
			$merged{$stem} = '{'.$meta{$key}.','.$meta{"${stem}_max"}.'}';
		}
		elsif ( $key =~ /^(.+?)_max$/ ) {
			next KEY;
		}
		else {
			$merged{$key} = $meta{$key};
		}
	}
	my $anno = '[&' . join( ',',map { $_.'='.$merged{$_} } keys %merged ) . ']';
	my $name = $id // $node->get_name // '';
	return $anno ne '[&]' ? $name . $anno : $name;
}

# podinherit_insert_token

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::IO>

The nexus serializer is called by the L<Bio::Phylo::IO> object.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=cut

1;
