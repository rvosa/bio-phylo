use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

{

    my $testnexus = <<'TESTNEXUS';
#NEXUS

BEGIN TAXA;
	TITLE Taxa;
	DIMENSIONS NTAX=3;
	TAXLABELS
		Polar_bear Grizzly_bear Black_bear 
	;
END;


BEGIN CHARACTERS;
	TITLE  'Matrix in file "test3.nex"';
	DIMENSIONS  NCHAR=2;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1";
	CHARSTATELABELS 
		1 hello /  hi bye, 2 goodbye /  bye hi ; 
	MATRIX
	Polar_bear    10
	Grizzly_bear  01
	Black_bear    10
;
END;
TESTNEXUS

    my ($matrix) = @{ parse(
        '-format' => 'nexus',
        '-string' => $testnexus,
        '-as_project' => 1,
    )->get_items(_MATRIX_) };
    
    my @expected = (
        {
            'charlabel'   => 'hello',
            'statelabels' => [ 'hi', 'bye' ],
        },
        {
            'charlabel'   => 'goodbye',
            'statelabels' => [ 'bye', 'hi' ]
        },
    );
    
    my @charlabels  = @{ $matrix->get_charlabels };
    my @statelabels = @{ $matrix->get_statelabels };
    
    for my $i ( 0 .. $#charlabels ) {
        ok( $charlabels[$i] eq $expected[$i]->{'charlabel'} );
        for my $j ( 0 .. $#{ $statelabels[$i] } ) {
            ok($statelabels[$i]->[$j] eq $expected[$i]->{'statelabels'}->[$j] );
        }
    }

}

{
    my $testnexus = <<'TESTNEXUS';
#NEXUS

BEGIN TAXA;
	TITLE Taxa;
	DIMENSIONS NTAX=3;
	TAXLABELS
		Polar_Bear Grizzly_Bear Black_Bear 
	;
END;

BEGIN CHARACTERS;
	TITLE  Character_Matrix;
	DIMENSIONS  NCHAR=2;
	FORMAT DATATYPE = CONTINUOUS GAP = - MISSING = ?;
CHARSTATELABELS 
		1 Body_Mass,
		2 Home_Range ; 
	MATRIX
	Polar_Bear     265.0 116.0
	Grizzly_Bear   251.0 83.0
	Black_Bear     93.0 57.0
;
END;
TESTNEXUS

    my ($matrix) = @{ parse(
        '-format' => 'nexus',
        '-string' => $testnexus,
        '-as_project' => 1,
    )->get_items(_MATRIX_) };
    
    my @expected = qw(Body_Mass Home_Range);    
    my @charlabels = @{ $matrix->get_charlabels };
    
    for my $i ( 0 .. $#charlabels ) {
        ok( $charlabels[$i] eq $expected[$i] );
    }
}
