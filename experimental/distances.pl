package Bio::Phylo::Matrices::DistanceMatrix;
use Bio::Phylo::Taxa::TaxaLinker;
use Bio::Phylo::Factory;
use constant _DISTANCE_MATRIX_ => 1;
use constant _DISTANCE_ => 2;
use vars '@ISA';
@ISA = qw(Bio::Phylo::Taxa::TaxaLinker);
my $fac = Bio::Phylo::Factory->new;

sub _type { _DISTANCE_MATRIX_ }

package Bio::Phylo::Matrices::Distance;
use constant _DISTANCE_MATRIX_ => 1;
use constant _DISTANCE_ => 2;

sub _type { _DISTANCE_ }
sub _container { _DISTANCE_MATRIX_ }

package main;

my $m = Bio::Phylo::Matrices::DistanceMatrix->new;
my $d = Bio::Phylo::Matrices::Distance->new( $t1, $t2, 0.2342 );
$m->insert($d); 