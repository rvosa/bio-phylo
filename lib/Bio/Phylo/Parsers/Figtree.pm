package Bio::Phylo::Parsers::Figtree;
use strict;
use base 'Bio::Phylo::Parsers::Abstract';
use Bio::Phylo::Util::CONSTANT qw':namespaces :objecttypes';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger ':levels';

my $ns  = _NS_FIGTREE_;
my $pre = 'fig';

=head1 NAME

Bio::Phylo::Parsers::Figtree - Parser used by Bio::Phylo::IO, no serviceable parts inside

=head1 DESCRIPTION

This module parses annotated trees in NEXUS format as produced by FigTree
(L<http://tree.bio.ed.ac.uk/software/figtree/>), i.e. trees where nodes have
additional 'hot comments' attached to them in the tree description. The
implementation assumes that B<every> node has one such set of annotations,  with
syntax as follows:

 [&minmax={0.1231,0.3254},rate=0.0075583392800736]
 
I.e. the first token inside the comments is an ampersand, the annotations are
comma-separated key/value pairs, where ranges are between curly parentheses.
 
=cut

sub _parse {
    my $self = shift;    
	my $fh   = $self->_handle;
	
	# parse all trees
	my ($forest) = @{ parse( 
		'-format' => 'nexus', 
		'-handle' => $fh,
		'-as_project' => 1,
	)->get_items(_FOREST_) };
	
	# need to rewind the file handle to the beginning
	# after first pass of nexus reading
	seek($fh,0,0);
	
	# parse annotated tree description
	my @desc;	
	while(<$fh>) {
		chomp;
		if ( /\s*tree\s\S+?\s=\s\[&(?:U|R)\]\s(.+)/ ) {
			my $desc = $1;
			push @desc, $desc;
		}
	}
	
	$self->_process_annotations($forest, @desc);
	return $forest;
}

sub _process_annotations {
	my ( $self, $forest, @desc ) = @_;
	my $log = $self->_logger;
	
	# visit trees and nodes in reading order
	my $i = 0;
	for my $tree ( @{ $forest->get_entities } ) {
		my $desc = $desc[$i];
		$tree->visit_depth_first( 
			'-post' => sub { 
				my $node = shift;
				$node->set_namespaces( $pre => $ns );
				
				# prune anything preceding first comment token from $desc
				$desc =~ s/^[^[]+//;
				
				# comment is a figtree processing instruction, starts with [&
				if ( $desc =~ /^\[&([^[]+)\]/ ) {
					my $annotation = $1;
					$log->info("found annotation $annotation");
					
					# going to parse annotations
					my %anno = $self->_parse_annotation($annotation);
					
					# attach annotations to focal node
					$self->_attach_annotation( $node, %anno );
	
				}
				else {
					$log->info("comment is not a figtree annotation: $desc");
				}
			} 
		);
		$i++;
	}	
}

# attach key/value pairs to focal node
sub _attach_annotation {
	my ( $self, $node, %anno ) = @_;
	my $fac = $self->_factory;
	
	# iterate over key/value pairs of figtree annotation
	for my $key ( keys %anno ) {
		my $predicate = $key;
		$predicate =~ s/[^a-zA-Z0-9]//g; # for safe CURIEs
		
		# value is an array reference, i.e. it's a min/max range
		if ( ref $anno{$key} ) {
			$node->add_meta(
				$fac->create_meta(
					'-triple' => { "${pre}:${predicate}_min" => $anno{$key}->[0] }
				)
			);
			$node->add_meta(
				$fac->create_meta(
					'-triple' => { "${pre}:${predicate}_max" => $anno{$key}->[1] }
				)
			);					
		}
		
		# value is a scalar
		else {
			$node->add_meta(
				$fac->create_meta(
					'-triple' => {
						"${pre}:$predicate" => $anno{$key},
					}
				)
			);
		}
	}	
}


# parse fugtree annotation syntax
sub _parse_annotation {
	my ( $self, $string ) = @_;
	my $log = $self->_logger;
	$log->info("going to parse annotation $string");
	my %anno;
	while($string) {
	
		# there is an equals sign with something in front of it
		if ( $string =~ /^([^=]+)=(.+)$/ ) {
			my ( $key, $remainder ) = ( $1, $2 );
			$log->info("key is $key");
			
			# remainder is between {}, i.e. a range
			if ( $remainder =~ /^{([^}]+)}/ ) {
				my $seq = $1;
				$log->info("value is $seq");
				my @values = split /,/, $seq;
				$anno{$key} = \@values;
				$string = substr $string, length($key) + length($seq) + 3;
				$log->info("remainder is $string");
			}
			
			# remainder is a scalar
			elsif ( $remainder =~ /^([^,]+),?/ ) {
				my $value = $1;
				$log->info("value is $value");
				$anno{$key} = $value;
				$string = substr $string, length($key) + length($value) + 1;
				$log->info("remainder is $string");
			}
			$string =~ s/^,//;
		}
	}
	return %anno;
}

# podinherit_insert_token

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::IO>

The figtree parser is called by the L<Bio::Phylo::IO> object.
Look there to learn how to parse phylogenetic data files in general.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=cut

1;
