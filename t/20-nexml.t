use Test::More;

BEGIN {
    eval { require XML::Twig };
    if ( not $ENV{'NEXML_ROOT'} ) {
        plan 'skip_all' => 'env var NEXML_ROOT not set';
    }
    elsif ($@) {
        plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        Test::More->import('no_plan');
    }
}
use strict;
use warnings;
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::Logger;
use Data::Dumper;
use Bio::Phylo::Factory;
my $fac = Bio::Phylo::Factory->new;
my $XML_PATH = $ENV{'NEXML_ROOT'} . '/examples' || '../examples';    # TODO fixme

# here we just parse a file with only taxon elements
my $taxa = parse( '-format' => 'nexml', '-file' => "$XML_PATH/taxa.xml" )->[0];

# check the ids for the children
my @ids      = qw(t1 t2 t3 t4 t5);
my @children = @{ $taxa->get_entities };
for my $i ( 0 .. $#children ) {
    ok( $ids[$i] eq $children[$i]->get_xml_id, "$ids[$i]" );
}
ok( unparse( '-format' => 'nexml', '-phylo' => $taxa ), "serialized taxa" );

# here we parse a file with taxon elements and a trees element
my $blocks    = parse( '-format' => 'nexml', '-file' => "$XML_PATH/trees.xml" );
my $forest    = $blocks->[1];
my %internals = map { $_ => 1 } qw(n1 n3 n4 n7);
my %terminals = map { $_ => 1 } qw(n2 n5 n6 n8 n9);
my %parent_of = (
    'n3' => 'n1',
    'n4' => 'n3',
    'n7' => 'n3',
    'n2' => 'n1',
    'n5' => 'n4',
    'n6' => 'n4',
    'n8' => 'n7',
    'n9' => 'n7',
);
my %taxon_of = (
    'n2' => 't1',
    'n5' => 't3',
    'n6' => 't2',
    'n8' => 't5',
    'n9' => 't4',
);
for my $tree ( @{ $forest->get_entities } ) {

    for my $node ( @{ $tree->get_entities } ) {
        my $id = $node->get_name;
        if ( $node->is_internal ) {
            ok( exists $internals{$id}, "$id is an internal node" );
        }
        else {
            ok( exists $terminals{$id}, "$id is a terminal node" );
            ok( $node->get_taxon->get_xml_id eq $taxon_of{$id},
                "taxon if $id is $taxon_of{$id}" );
        }
        if ( my $parent = $node->get_parent ) {
            my $parent_id = $parent->get_name;
            ok( $parent_of{$id} eq $parent_id, "$parent_id is parent of $id" );
        }
    }
}
ok( $forest->first->calc_symdiff( $forest->last ) == 0,
    "identical topologies, symdiff == 0" );
ok( unparse( '-format' => 'nexml', '-phylo' => $forest ), "serialized forest" );

# here we parse a file with two character matrices, one continuous, one standard
$blocks = parse( '-format' => 'nexml', '-file' => "$XML_PATH/characters.xml" );
my $raw_matrices = {
    'CONTINUOUS' => [
        [
            -1.545414144070023,  -2.3905621575431044,
            -2.9610221833467265, 0.7868662069161243,
            0.22968509237534918
        ],
        [
            -1.6259836379710066, 3.649352410850134,
            1.778885099660406,   -1.2580877968480846,
            0.22335354995610862
        ],
        [
            -1.5798979984134964, 2.9548251411133157,
            1.522005675256233,   -0.8642016921755289,
            -0.938129801832388
        ],
        [
            2.7436692306788086, -0.7151148143399818,
            4.592207937774776,  -0.6898841440534845,
            0.5769509574453064
        ],
        [
            3.1060827493657683, -1.0453787389160105,
            2.67416332763427,   -1.4045634106692808,
            0.019890469925520196
        ],
    ],
    'STANDARD' => [ [ 1, 2 ], [ 2, 2 ], [ 3, 4 ], [ 2, 3 ], [ 4, 1 ], ],
    'DNA' => [
        [
            'a', 'c', 'g', 'c', 't', 'c', 'g', 'c', 'a', 't',
            'c', 'g', 'c', 'a', 't', 'c', 'g', 'c', 'g', 'a'
        ],
        [
            'a', 'c', 'g', 'c', 't', 'c', 'g', 'c', 'a', 't',
            'c', 'g', 'c', 'a', 't', 'c', 'g', 'c', 'g', 'a'
        ],
        [
            'a', 'c', 'g', 'c', 't', 'c', 'g', 'c', 'a', 't',
            'c', 'g', 'c', 'a', 't', 'c', 'g', 'c', 'g', 'a'
        ],
    ],
    'RNA' => [
        [
            'a', 'c', 'g', 'c', 'u', 'c', 'g', 'c', 'a', 'u',
            'c', 'g', 'c', 'a', 'u', 'c', 'g', 'c', 'g', 'a'
        ],
        [
            'a', 'c', 'g', 'c', 'u', 'c', 'g', 'c', 'a', 'u',
            'c', 'g', 'c', 'a', 'u', 'c', 'g', 'c', 'g', 'a'
        ],
        [
            'a', 'c', 'g', 'c', 'u', 'c', 'g', 'c', 'a', 'u',
            'c', 'g', 'c', 'a', 'u', 'c', 'g', 'c', 'g', 'a'
        ],
    ]
};
for my $block (@$blocks) {
    if ( $block->isa('Bio::Phylo::Taxa') ) {
        ok( $block, "got taxa block" );
        next;
    }
    my $rows = $block->get_entities;
    my $type = uc $block->get_type;
    for my $i ( 0 .. $#{$rows} ) {
        ok( $rows->[$i]->get_taxon->get_xml_id eq 't' . ( $i + 1 ),
            "found linked taxon" );
        if ( exists $raw_matrices->{$type} ) {
            my @chars = $rows->[$i]->get_char;
            for my $j ( 0 .. $#chars ) {
                my $value_in_matrix_object = $chars[$j];
                my $value_in_raw_array     = $raw_matrices->{$type}->[$i]->[$j];
                if ( ( $type eq 'CONTINUOUS' ) || ( $type eq 'STANDARD' ) ) {
                    ok(
                        $value_in_matrix_object == $value_in_raw_array,
"value in numerical cell (obj: $value_in_matrix_object raw: $value_in_raw_array)"
                    );
                }
                else {
                    ok(
                        lc($value_in_matrix_object) eq lc($value_in_raw_array),
"value in symbol cell (obj: $value_in_matrix_object raw: $value_in_raw_array)"
                    );
                }
            }
        }
    }
    ok( unparse( '-format' => 'nexml', '-phylo' => $block ),
        "serialized $block" );
}
{
    my $matrix = Bio::Phylo::Matrices::Matrix->new(
        '-type'   => 'dna',
        '-matrix' => [ [qw'taxon1 A C G T C G'], [qw'taxon2 A C G T C G'], ],
        '-charlabels' => [qw'c1 c2 c3 c4 c5 c6']
    );

    # testing character annotations
    my $char = $matrix->get_characters->get_entities->[0];
    $char->add_meta(
        $fac->create_meta(
            '-namespaces' =>
              { 'dcterms' => 'http://purl.org/dc/elements/1.1/' },
            '-triple' =>
              { 'dcterms:description' => 'this is a character annotation' }
        )
    );
    my ($meta) = @{ $char->get_meta };
    ok( $meta->get_object    eq 'this is a character annotation' );
    ok( $meta->get_predicate eq 'dcterms:description' );

    # testing annotation for unambiguous state
    my $to = $matrix->get_type_object;
    $to->add_meta_for_state(
        $fac->create_meta(
            '-namespaces' => { 'dc' => 'http://purl.org/dc/terms/description' },
            '-triple' => { 'dc:description' => 'this is an unambiguous state' }
        ),
        'A'
    );
    my ($umeta) = @{ $to->get_meta_for_state('A') };
    ok( $umeta->get_object    eq 'this is an unambiguous state' );
    ok( $umeta->get_predicate eq 'dc:description' );

    # testing annotation for ambiguous state
    $matrix->get_type_object->add_meta_for_state(
        $fac->create_meta(
            '-namespaces' => { 'dc' => 'http://purl.org/dc/terms/description' },
            '-triple' => { 'dc:description' => 'this is an ambiguous state' }
        ),
        'X'
    );
    my ($ameta) = @{ $to->get_meta_for_state('X') };
    ok( $ameta->get_object    eq 'this is an ambiguous state' );
    ok( $ameta->get_predicate eq 'dc:description' );
}
