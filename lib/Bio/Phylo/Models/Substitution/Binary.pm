package Bio::Phylo::Models::Substitution::Binary;
use strict;
use Data::Dumper;
use Bio::Phylo::Util::Logger;
use Bio::Phylo::Util::CONSTANT qw'/looks_like/ :objecttypes';
use Bio::Phylo::Util::Exceptions qw'throw';

my $logger = Bio::Phylo::Util::Logger->new;

sub new {
    my $class = shift;
    my %args  = looks_like_hash @_;
    my $self  = { '_fw' => undef, '_rev' => undef };
    bless $self, $class;
    while ( my ( $key, $value ) = each %args ) {
        $key =~ s/^-/set_/;
        $self->$key($value);
    }
    return $self;
}

sub set_forward {
	my ( $self, $fw ) = @_;
	$self->{'_fw'} = $fw;
	return $self;
}

sub set_reverse {
	my ( $self, $rev ) = @_;
	$self->{'_rev'} = $rev;
	return $self;
}

sub get_forward { shift->{'_fw'} }

sub get_reverse { shift->{'_rev'} }

sub modeltest {

	# process arguments
	my ( $class, %args ) = @_;
	my $tree   = $args{'-tree'}   or throw 'BadArgs' => "Need -tree argument";
	my $char   = $args{'-char'}   or throw 'BadArgs' => "Need -char argument";
	my $matrix = $args{'-matrix'} or throw 'BadArgs' => "Need -matrix argument";
	my $model  = $args{'-model'}  || 'ARD';
	
	# we don't actually check if the character is binary here. perhaps we should,
	# and verify that the tips in the tree match the rows in the matrix, and 
	# prune tips with missing data, and, and, and...
	if ( $matrix->get_type !~ /standard/i ) {
		throw 'BadArgs' => "Need standard categorical data";
	}
	if ( looks_like_class 'Statistics::R' ) {
	
		# start R, load library
		$logger->info("going to run 'ace'");
		my $R = Statistics::R->new;
		$R->run(q[library("ape")]);
		
		# insert data
		my $newick = $tree->to_newick;
		my %hash = $class->_data_hash($char,$matrix);
		$R->run(qq[phylo <- read.tree(text="$newick")]);
		$R->set('chars', [values %hash]);
		$R->set('labels', [keys %hash]);
		$R->run(q[names(chars) <- labels]);
		
		# do calculation
		$R->run(qq[ans <- ace(chars,phylo,type="d",model="$model")]);
		$R->run(q[rates <- ans$rates]);
		my $rates = $R->get(q[rates]);
		$logger->info("Rates: ".Dumper($rates));
		
		# return instance
		return $class->new(
			'-forward' => $rates->[1],
			'-reverse' => $rates->[0],
		);	
	}
}

sub _data_hash {
	my ( $self, $char, $matrix ) = @_;
	my $cid = $char->get_id;
	my $chars = $matrix->get_characters;
	my $nchar = $matrix->get_nchar;
	my $name  = $char->get_name || $cid;
	
	# find index of character
	my $index;
	CHAR: for my $i ( 0 .. $nchar - 1 ) {
		my $c = $chars->get_by_index($i);
		if ( $c->get_id == $cid ) {
			$index = $i;
			$logger->info("index of character ${name}: ${index}");
			last CHAR;
		}
	}
	
	# get character states
	my %result;
	for my $row ( @{ $matrix->get_entities } ) {
		my @char = $row->get_char;
		my $name = $row->get_name;
		$result{$name} = $char[$index];
	}	
	$logger->debug(Dumper(\%result));
	return %result;
}
