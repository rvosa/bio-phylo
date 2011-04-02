use Bio::Phylo::IO 'parse';
use Test::More tests => 1;

my $tree = parse( -format => 'newick', -string => do { local $/ = undef; <DATA> } )->first;
my $string1 = $tree->to_newick;
my $string2 = $tree->remove_unbranched_internals->to_newick;

ok( $string1 ne $string2, '1: remove unbranched internals' );

__DATA__
(Aplysia,(((Schistosoma-NUM3,Caenorhabditis-NUM3),((((Saccharomyces-NUM2,Dictyostelium,(Pneumocystis,Schizosaccharomyces-NUM2)),(Drosophila-NUM2,Caenorhabditis-NUM2,Petrosia,Petrobiona,(Schistosoma-NUM2,Nematostella),(Chondrosia,Asbestopluma),(Crassostrea,(Mus-NUM2,Danio)),(Monosiga_ovata,Monosiga_brevicollis-NUM2),(Beroe,Rhabdocalyptus),(Eunicella,Funiculina))),((Caenorhabditis-NUM4,Schistosoma-NUM4,(Mus-NUM4,(Monosiga_brevicollis-NUM4,Drosophila-NUM4))),(Schizosaccharomyces-NUM4,Saccharomyces-NUM4))),(Schizosaccharomyces-NUM3,Saccharomyces-NUM3)))));