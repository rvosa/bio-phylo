# $Id: 14-nexus.t 1524 2010-11-25 19:24:12Z rvos $
use strict;

#use warnings;
use Test::More tests => 6;
use Bio::Phylo::IO qw(parse);

#Bio::Phylo::IO->VERBOSE( -level => 1 );
# Up until the next big block of comment tokens, a number of nexus strings is
# defined.
################################################################################
################################################################################
################################################################################
################################################################################
# This string holds a valid (mesquite) nexus file
my $testparse = <<TESTPARSE
#NEXUS
[written Wed Jun 08 00:30:00 CEST 2005 by Mesquite  version 1.02+ (build g8)]

BEGIN TAXA;
	DIMENSIONS NTAX=5;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5
	;

END;


BEGIN CHARACTERS;
[! Simulated Matrices on Current Tree:  Matrix #1; Simulator: Evolve DNA Characters; most recent tree: Default ladder [seed for matrix sim. 1118183366345]
     Evolve DNA Characters:  Simulated evolution using model Jukes-Cantor with the following parameters:
        Root states model (Equal Frequencies): Equal Frequencies
        Equilibrium states model (Equal Frequencies): Equal Frequencies
        Character rates model (Equal Rates): Equal Rates
        Rate matrix model (Single Rate): single rate

         Stored Probability Model for Simulation:  Current model "Jukes-Cantor":         Root states model (Equal Frequencies): Equal Frequencies
        Equilibrium states model (Equal Frequencies): Equal Frequencies
        Character rates model (Equal Rates): Equal Rates
        Rate matrix model (Single Rate): single rate

         Stored Matrices:  Character Matrices from file: Project with home file "testparse.nex"
     Tree of context:  Tree(s) used from Tree Window 2 showing Stored Trees. Last tree used: Default ladder  [tree: (1,(2,(3,(4,5))));]
]
	DIMENSIONS NCHAR=10;
	FORMAT DATATYPE = DNA GAP = - MISSING = ?;
	MATRIX
	taxon_1  TACCACTTGT
	taxon_2  GTTCTCTTCT
	taxon_3  AGCGTCTTTC
	taxon_4  ACTTTGTTTC
	taxon_5  GCCCCTCGAG


;


END;

BEGIN ASSUMPTIONS;
	TYPESET * UNTITLED   =  unord:  1 -  10;

END;

BEGIN MESQUITECHARMODELS;
	ProbModelSet * UNTITLED   =  'Jukes-Cantor':  1 -  10;
END;

BEGIN TREES;
[!Parameters: ]
	TRANSLATE
		1 taxon_1,
		2 taxon_2,
		3 taxon_3,
		4 taxon_4,
		5 taxon_5;
	TREE Default_ladder = (1,(2,(3,(4,5))));
	TREE Default_bush = (1,2,3,4,5);
	TREE Default_symmetrical = ((1,2),(3,(4,5)));

END;
TESTPARSE
  ;

# this string holds a valid nexus tree block
my $testparse_trees = <<TESTPARSE_TREES
#NEXUS
BEGIN TREES;
[!Parameters: ]
	TRANSLATE
		1 taxon_1,
		2 taxon_2,
		3 taxon_3,
		4 taxon_4,
		5 taxon_5;
	TREE Default_ladder = (1,(2,(3,(4,5))));
	TREE Default_bush = (1,2,3,4,5);
	TREE Default_symmetrical = ((1,2),(3,(4,5)));

END;
TESTPARSE_TREES
  ;

# this string holds a nexus file with a bad nchar specification.
my $testparse_bad = <<TESTPARSE_BAD
#NEXUS
[written Wed Jun 08 00:30:00 CEST 2005 by Mesquite  version 1.02+ (build g8)]

BEGIN TAXA;
	DIMENSIONS NTAX=5;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5
	;

END;


BEGIN CHARACTERS;
[! Simulated Matrices on Current Tree:  Matrix #1; Simulator: Evolve DNA Characters; most recent tree: Default ladder [seed for matrix sim. 1118183366345]
     Evolve DNA Characters:  Simulated evolution using model Jukes-Cantor with the following parameters:
        Root states model (Equal Frequencies): Equal Frequencies
        Equilibrium states model (Equal Frequencies): Equal Frequencies
        Character rates model (Equal Rates): Equal Rates
        Rate matrix model (Single Rate): single rate

         Stored Probability Model for Simulation:  Current model "Jukes-Cantor":         Root states model (Equal Frequencies): Equal Frequencies
        Equilibrium states model (Equal Frequencies): Equal Frequencies
        Character rates model (Equal Rates): Equal Rates
        Rate matrix model (Single Rate): single rate

         Stored Matrices:  Character Matrices from file: Project with home file "testparse.nex"
     Tree of context:  Tree(s) used from Tree Window 2 showing Stored Trees. Last tree used: Default ladder  [tree: (1,(2,(3,(4,5))));]
]
	DIMENSIONS NCHAR=11;
	FORMAT DATATYPE = DNA GAP = - MISSING = ?;
	MATRIX
	taxon_1  TACCACTTGT
	taxon_2  GTTCTCTTCT
	taxon_3  AGCGTCTTTC
	taxon_4  ACTTTGTTTC
	taxon_5  GCCCCTCGAG


;


END;

BEGIN ASSUMPTIONS;
	TYPESET * UNTITLED   =  unord:  1 -  10;

END;

BEGIN MESQUITECHARMODELS;
	ProbModelSet * UNTITLED   =  'Jukes-Cantor':  1 -  10;
END;

BEGIN TREES;
[!Parameters: ]
	TRANSLATE
		1 taxon_1,
		2 taxon_2,
		3 taxon_3,
		4 taxon_4,
		5 taxon_5;
	TREE Default_ladder = (1,(2,(3,(4,5))));
	TREE Default_bush = (1,2,3,4,5);
	TREE Default_symmetrical = ((1,2),(3,(4,5)));

END;
TESTPARSE_BAD
  ;

# this string holds a taxa block with a bad ntax specification
my $testparse_taxa_bad = <<TESTPARSE_TAXA_BAD
#NEXUS
[written Wed Jun 08 00:30:00 CEST 2005 by Mesquite  version 1.02+ (build g8)]

BEGIN TAXA;
	DIMENSIONS NTAX=6;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5
	;

END;
TESTPARSE_TAXA_BAD
  ;
my $bayes_phylogenies_tree_block = <<BAYES_PHYLOGENIES
#NEXUS
begin trees;
	translate
		0 Uria_aalge,
		1 Uria_lomvia,
		2 Alca_torda,
		3 Brachyramphus_marmoratus_perdix,
		4 Brachyramphus_brevirostris,
		5 Brachyramphus_marmoratus_marmoratus,
		6 Alle_alle,
		7 Fratercula_cirrhata,
		8 Cerorhinca_monocerata,
		9 Fratercula_arctica,
		10 Fratercula_corniculata,
		11 Ptychoramphus_aleuticus,
		12 Aethia_cristatella,
		13 Aethia_pygmaea,
		14 Aethia_pusilla,
		15 Cyclorrhynchus_psittacula,
		16 Cepphus_grylle,
		17 Cepphus_carbo,
		18 Cepphus_columba,
		19 Synthliboramphus_craveri,
		20 Synthliboramphus_hypoleucus,
		21 Synthliboramphus_antiquus,
		22 Synthliboramphus_wumizusume,
		23 Podiceps_cristatus,
		24 Pygoscelis_papua,
		25 Pygoscelis_antarctica,
		26 Pygoscelis_adeliae,
		27 Aptenodytes_forsteri,
		28 Aptenodytes_patagonicus,
		29 Eudyptula_minor,
		30 Spheniscus_humboldti,
		31 Spheniscus_mendiculus,
		32 Spheniscus_magellanicus,
		33 Spheniscus_demersus,
		34 Megadyptes_antipodes,
		35 Eudyptes_pachyrhynchus,
		36 Eudyptes_chrysocome,
		37 Eudyptes_chrysolophus,
		38 Eudyptes_sclateri;
		tree tree.0.16248.085507 = (((((1:0.0252829964,((37:0.0923922678,36:0.0227291363):0.0214856938,(30:0.0985772880,0:0.0009462633):0.0085211709):0.0179755543):0.0205001767,(7:0.0424374264,((9:0.0669529421,14:0.0573991137):0.0739853752,((20:0.0677125225,(4:0.0005873572,((22:0.0164514388,6:0.0634953974):0.0923654357,10:0.0081590705):0.0717563701):0.0904661023):0.0679236955,(28:0.0620291126,27:0.0415875050):0.0650770216):0.0101495576):0.0062417913):0.0281845666):0.0134608664,(((((34:0.0995649978,31:0.0060399110):0.0074011584,((24:0.0026846325,16:0.0276615400):0.0735381721,11:0.0420489735):0.0819518305):0.0789395164,23:0.0040709433):0.0874707185,((21:0.0518027951,(19:0.0563251535,2:0.0725701259):0.0849605911):0.0495047209,(((((5:0.0584078805,12:0.0317612163):0.0522162737,(17:0.0697702365,29:0.0320984447):0.0050194401):0.0539123659,35:0.0302218356):0.0541191319,(15:0.0724595328,26:0.0634974059):0.0725055498):0.0968988513,18:0.0135335244):0.0395651510):0.0346867079):0.0332131995,(32:0.0215632626,33:0.0558144064):0.0468566682):0.0573485880):0.0085197300,((3:0.0806758770,13:0.0947391639):0.0114522838,(8:0.0883078090,25:0.0681993985):0.0984385842):0.0638312341):0.0133569866,38:0.0608513758);
end;
BAYES_PHYLOGENIES
  ;
my $bayes_phylogenies_newick =
'(((((Uria_lomvia:0.025283,((Eudyptes_chrysolophus:0.0923923,Eudyptes_chrysocome:0.0227291):0.0214857,(Spheniscus_humboldti:0.0985773,Uria_aalge:0.000946263):0.00852117):0.0179756):0.0205002,(Fratercula_cirrhata:0.0424374,((Fratercula_arctica:0.0669529,Aethia_pusilla:0.0573991):0.0739854,((Synthliboramphus_hypoleucus:0.0677125,(Brachyramphus_brevirostris:0.000587357,((Synthliboramphus_wumizusume:0.0164514,Alle_alle:0.0634954):0.0923654,Fratercula_corniculata:0.00815907):0.0717564):0.0904661):0.0679237,(Aptenodytes_patagonicus:0.0620291,Aptenodytes_forsteri:0.0415875):0.065077):0.0101496):0.00624179):0.0281846):0.0134609,(((((Megadyptes_antipodes:0.099565,Spheniscus_mendiculus:0.00603991):0.00740116,((Pygoscelis_papua:0.00268463,Cepphus_grylle:0.0276615):0.0735382,Ptychoramphus_aleuticus:0.042049):0.0819518):0.0789395,Podiceps_cristatus:0.00407094):0.0874707,((Synthliboramphus_antiquus:0.0518028,(Synthliboramphus_craveri:0.0563252,Alca_torda:0.0725701):0.0849606):0.0495047,(((((Brachyramphus_marmoratus_marmoratus:0.0584079,Aethia_cristatella:0.0317612):0.0522163,(Cepphus_carbo:0.0697702,Eudyptula_minor:0.0320984):0.00501944):0.0539124,Eudyptes_pachyrhynchus:0.0302218):0.0541191,(Cyclorrhynchus_psittacula:0.0724595,Pygoscelis_adeliae:0.0634974):0.0725055):0.0968989,Cepphus_columba:0.0135335):0.0395651):0.0346867):0.0332132,(Spheniscus_magellanicus:0.0215633,Spheniscus_demersus:0.0558144):0.0468567):0.0573486):0.00851973,((Brachyramphus_marmoratus_perdix:0.0806759,Aethia_pygmaea:0.0947392):0.0114523,(Cerorhinca_monocerata:0.0883078,Pygoscelis_antarctica:0.0681994):0.0984386):0.0638312):0.013357,Eudyptes_sclateri:0.0608514):0; ';
################################################################################
################################################################################
################################################################################
################################################################################
# Done defining nexus tokens, let's try to parse them.
print "--------------------------------------------------------------------\n";
eval { parse( '-format' => 'nexus', '-string' => $testparse ) };
if ($@) {
    print $@->trace->as_string;
    die $@;
}
ok( parse( '-format' => 'nexus', '-string' => $testparse ), '1 good parse' );
print "--------------------------------------------------------------------\n";
ok( parse( '-format' => 'nexus', '-string' => $testparse_trees ),
    '2 tree block' );
print "--------------------------------------------------------------------\n";
eval { parse( '-format' => 'nexus', '-string' => $testparse_taxa_bad ) };
ok( UNIVERSAL::isa( $@, 'Bio::Phylo::Util::Exceptions::BadFormat' ),
    '3 bad ntax' );
print "--------------------------------------------------------------------\n";
eval { parse( '-format' => 'nexus', '-string' => $testparse_bad ) };
ok( UNIVERSAL::isa( $@, 'Bio::Phylo::Util::Exceptions::BadFormat' ),
    '4 bad nchar' );
print "--------------------------------------------------------------------\n";
eval { parse( '-format' => 'nexus', '-file' => 'DOES_NOT_EXIST' ) };
ok( $@->isa('Bio::Phylo::Util::Exceptions::FileError'), '5 file error' );
my $bayes_phylogenies_nexus_tree = parse(
    '-format'     => 'nexus',
    '-string'     => $bayes_phylogenies_tree_block,
    '-as_project' => 1,
)->get_forests->[0]->first;
my $bayes_phylogenies_newick_tree = parse(
    '-format' => 'newick',
    '-string' => $bayes_phylogenies_newick,
)->first;
ok(
    $bayes_phylogenies_nexus_tree->calc_symdiff($bayes_phylogenies_newick_tree)
      == 0,
    '6 translate table starts at 0'
);
