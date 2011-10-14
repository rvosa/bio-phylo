use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

{
    my $sets = <<'SETS';
#NEXUS
BEGIN TAXA;
	TITLE Taxa2;
	DIMENSIONS NTAX=5;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5 
	;
END;
BEGIN CHARACTERS;
	TITLE  Character_Matrix;
	DIMENSIONS  NCHAR=5;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1 2";
	MATRIX
	taxon_1  ?1111
	taxon_2  ??211
	taxon_3  ??222
	taxon_4  ??222
	taxon_5  ???2?
;
END;
BEGIN SETS;
	CHARSET Stored_char._set = 1 - 2 4;
END;
SETS

    my $project = parse(
        '-format' => 'nexus',
        '-string' => $sets,
        '-as_project' => 1,
    );
    my ($matrix) = @{ $project->get_items(_MATRIX_) };
    my $characters = $matrix->get_characters;
    my ($set) = @{ $characters->get_sets };
    is( $set->get_name, 'Stored_char._set', 'set has right name' );
    for my $i ( 0 .. $#{ $characters->get_entities } ) {
        my $char = $characters->get_by_index($i);
        if ( $i == 0 || $i == 1 || $i == 3 ) {
            ok( $characters->is_in_set($char,$set), 'char is in set' );
        }
        else {
            ok( ! $characters->is_in_set($char,$set), 'char is not in set' );
        }
    }
}

{
    my $mesquite_sets = <<'MESQUITE_SETS';
#NEXUS
BEGIN TAXA;
	TITLE Taxa2;
	DIMENSIONS NTAX=5;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5 
	;
END;
BEGIN CHARACTERS;
	TITLE  Character_Matrix;
	DIMENSIONS  NCHAR=5;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1 2";
	MATRIX
	taxon_1  ?1111
	taxon_2  ??211
	taxon_3  ??222
	taxon_4  ??222
	taxon_5  ???2?
;
END;
BEGIN CHARACTERS;
	TITLE  Character_Matrix2;
	DIMENSIONS  NCHAR=2;
	FORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = "  0 1";
	MATRIX
	taxon_1  ??
	taxon_2  ??
	taxon_3  ??
	taxon_4  ??
	taxon_5  ??
;
END;
BEGIN SETS;
	CHARSET Stored_char._set  (CHARACTERS = Character_Matrix)  =   1 -  2 4;
END;
MESQUITE_SETS

    my $project = parse(
        '-format' => 'nexus',
        '-string' => $mesquite_sets,
        '-as_project' => 1,
    );
    my ($matrix) = @{ $project->get_items(_MATRIX_) };
    my $characters = $matrix->get_characters;
    my ($set) = @{ $characters->get_sets };
    is( $set->get_name, 'Stored_char._set', 'set has right name' );
    for my $i ( 0 .. $#{ $characters->get_entities } ) {
        my $char = $characters->get_by_index($i);
        if ( $i == 0 || $i == 1 || $i == 3 ) {
            ok( $characters->is_in_set($char,$set), 'char is in set' );
        }
        else {
            ok( ! $characters->is_in_set($char,$set), 'char is not in set' );
        }
    }
}