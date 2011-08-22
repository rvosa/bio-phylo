use Test::More 'no_plan';
use strict;
use Bio::Phylo;
use Bio::Phylo::Factory;
use Bio::Phylo::IO 'parse';

my $proj = parse(
    '-format' => 'nexus',
    '-handle' => \*DATA,
    '-as_project' => 1,
);

my $rdf = $proj->to_cdao;
ok($rdf);

__DATA__
#NEXUS

BEGIN TAXA;
	TITLE Taxa;
	DIMENSIONS NTAX=3;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 
	;
END;

BEGIN CHARACTERS;
	TITLE  Character_Matrix;
	DIMENSIONS  NCHAR=2;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1";
	MATRIX
		taxon_1  ??
		taxon_2  ??
		taxon_3  ??
	;
END;

BEGIN TREES;
	Title Default_Trees;
	LINK Taxa = Taxa;
	TRANSLATE
		1 taxon_1,
		2 taxon_2,
		3 taxon_3;
	TREE Default_symmetrical = (1,(2,3));
	TREE Default_bush = (1,2,3);
	TREE Default_ladder = (1,(2,3));
END;

