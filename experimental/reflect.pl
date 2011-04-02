package Reflect;
sub get_isa {
	my $obj = shift;
	my $package = ref($obj) || $obj;
	my ( $isa, $seen ) = ( [], {} );
    _recurse_isa( $package, $isa, $seen );
    return $isa;
}

sub get_methods {
	my $obj = shift;
	my $isa = get_isa( $obj );
	my @methods;
	for my $package ( @{ $isa } ) {

		my %symtable;
		eval "\%symtable = \%${package}::";
		
		# at this point we have lots of things, we just want methods
		for my $entry ( keys %symtable ) {
			
			# check if entry is a CODE reference
			my $can = $package->can( $entry );
			if ( ref $can eq 'CODE' ) {
				push @methods, {
					'package'    => $package,
					'name'       => $entry,
					'glob'       => $symtable{$entry},
					'code'       => $can,
				};
			}
		}
	}
	return \@methods;
}

# starting from $class, push all superclasses (+$class) into @$isa, 
# %$seen is just a helper to avoid getting stuck in cycles
sub _recurse_isa {
	my ( $class, $isa, $seen ) = @_;
	if ( not $seen->{$class} ) {
		$seen->{$class} = 1;
		push @{$isa}, $class;
		my @isa;
		{
			no strict 'refs'; 
			@isa = @{"${class}::ISA"};
			use strict;
		}
		_recurse_isa( $_, $isa, $seen ) for @isa;
	}
}

package MyAttributes;
use Attribute::Handlers;
use Data::Dumper;
use strict;

our %clonables;

sub UNIVERSAL::accessor : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
}

sub UNIVERSAL::meta : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
}

sub UNIVERSAL::constructor : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
}

sub UNIVERSAL::mutator : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
}

sub UNIVERSAL::abstract : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
	*$symbol = sub { die "Abstract method, can't call" };
}

sub UNIVERSAL::clonable : ATTR(CODE) {
	my ($package, $symbol, $referent, $attr, $data) = @_;
	if ( not $clonables{$package} ) {
		$clonables{$package} = {};
	}
	$clonables{$package}->{$data->[0]} = $referent;
	my $template = 'sub %s::clone {
		my $self = shift;
		my $package = ref $self;
		my $clone = $package->new;
		for my $setter ( keys %{ $MyAttributes::clonables{$package} } ) {
			$clone->$setter( $MyAttributes::clonables{$package}->{$setter}->($self) );
		}
		return $clone;	
	}';
	eval sprintf( $template, $package );
}

sub cloner {
	my $self = shift;
	my $package = ref $self;
	my $clone = $package->new;
	for my $setter ( keys %{ $MyAttributes::clonables{$package} } ) {
		$clone->$setter( $MyAttributes::clonables{$package}->{$setter}->($self) );
	}
	return $clone;
}

package Child;

sub new : constructor { bless {}, shift }

sub get : clonable('set') accessor meta { shift->{'_foo'} }

sub set : mutator {
	my $self = shift;
	$self->{'_foo'} = shift;
	return $self;
}

sub interface : abstract {}

package main;
use Data::Dumper;

my $orig = Child->new;
$orig->set('bar');
my $clone = $orig->clone;
warn $clone->get;
warn Dumper( Reflect::get_methods( $clone ) );