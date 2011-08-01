use Test::More;
BEGIN {
    eval { require XML::Twig };
    if ($@) {
        plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        Test::More->import('no_plan');
    }
}
use strict;
use Bio::Phylo::IO 'parse';

# TEST PARSING OF TAXON SETS

my $sets1;
{
$sets1 = <<'SETS1';
<nex:nexml 
    version="0.9"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    generator="handmade"
    xmlns:nex="http://www.nexml.org/2009"
    xmlns="http://www.nexml.org/2009"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xsi:schemaLocation="http://www.nexml.org/2009 ../xsd/nexml.xsd">
    <otus id="taxa1">        
        <otu id="t1"/>
        <otu id="t2"/>
        <otu id="t3"/>
        <otu id="t4"/>
        <otu id="t5"/>
        <set otu="t1 t2" id="set1"/>
    </otus>
</nex:nexml>
SETS1
}


{
    my $proj1 = parse(
        '-format' => 'nexml',
        '-string' => $sets1,
        '-as_project' => 1,
    );
    
    for my $taxa ( @{ $proj1->get_taxa } ) {
        my ($set) = @{ $taxa->get_sets };
        ok($set);
        $taxa->visit( sub {
            my $taxon = shift;
            my $name = $taxon->get_xml_id;
            if ( $name eq 't1' or $name eq 't2' ) {
                ok( $taxa->is_in_set($taxon,$set) );
            }
            else {
                ok( ! $taxa->is_in_set($taxon,$set) );
            }
        });
    }
    
    # TEST SERIALIZE TAXON SETS
    
    my %ids1;
    my $xml1 = $proj1->to_xml;
    XML::Twig->new(
        'twig_handlers' => {
            'set' => sub {
                my ( $twig, $elt ) = @_;
                %ids1 = map { $_ => 1 } grep { /\S/ } split /\s+/, $elt->att('otu');
            }
        }
    )->parse($xml1);
    my @ids1 = keys %ids1;
    # ok(exists $ids1{'t1'}); # we no longer try to round-trip ids in projects
    # ok(exists $ids1{'t2'});
    ok(scalar(@ids1)==2);
}

# TEST PARSING OF TREE SETS

my $sets2;
{
$sets2 = <<'SETS2';
<?xml version="1.0" encoding="UTF-8"?>
<nex:nexml 
    version="0.9"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    generator="handmade"
    xmlns:nex="http://www.nexml.org/2009"
    xmlns="http://www.nexml.org/2009"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xsi:schemaLocation="http://www.nexml.org/2009 ../xsd/nexml.xsd">
    <otus 
        id="taxa1">        
        <otu id="t1"/>
        <otu id="t2"/>
        <otu id="t3"/>
        <otu id="t4"/>
        <otu id="t5"/>
    </otus>
    <trees otus="taxa1" id="trees1">       
        <tree xsi:type="nex:IntTree" id="tree1">            
            <node id="n1"/>
            <node id="n2"/>
            <node id="n3"/>
            <rootedge target="n1" id="root"/>
            <edge source="n1" target="n2" id="e1"/>
            <edge source="n1" target="n3" id="e2"/> 
        </tree>
        <set tree="tree1" id="set3"/>        
    </trees>
</nex:nexml>
SETS2
}


{
    my $proj2 = parse(
        '-format' => 'nexml',
        '-string' => $sets2,
        '-as_project' => 1,
    );
    
    for my $forest ( @{ $proj2->get_forests } ) {
        my ($set) = @{ $forest->get_sets };
        ok($set);
        $forest->visit( sub {
            my $tree = shift;
            my $name = $tree->get_xml_id;
            if ( $name eq 'tree1' ) {
                ok( $forest->is_in_set($tree,$set) );
            }
        });
    }
    
    # TEST SERIALIZE TREE SETS
    
    my %ids2;
    my $xml2 = $proj2->to_xml;
    XML::Twig->new(
        'twig_handlers' => {
            'set' => sub {
                my ( $twig, $elt ) = @_;
                %ids2 = map { $_ => 1 } grep { /\S/ } split /\s+/, $elt->att('tree');
            }
        }
    )->parse($xml2);
    my @ids2 = keys %ids2;
    # ok(exists $ids2{'tree1'}); # we no longer try to roundtrip ids in projects
    ok(scalar(@ids2)==1);
}

# TEST PARSING OF NODE SETS
my $sets3;
{
$sets3 = <<'SETS3';
<?xml version="1.0" encoding="UTF-8"?>
<nex:nexml 
    version="0.9"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    generator="handmade"
    xmlns:nex="http://www.nexml.org/2009"
    xmlns="http://www.nexml.org/2009"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xsi:schemaLocation="http://www.nexml.org/2009 ../xsd/nexml.xsd">
    <otus 
        id="taxa1">        
        <otu id="t1"/>
        <otu id="t2"/>
        <otu id="t3"/>
        <otu id="t4"/>
        <otu id="t5"/>
    </otus>
    <trees otus="taxa1" id="trees1">       
        <tree xsi:type="nex:IntTree" id="tree1">            
            <node id="n1"/>
            <node id="n2"/>
            <node id="n3"/>
            <rootedge target="n1" id="root"/>
            <edge source="n1" target="n2" id="e1"/>
            <edge source="n1" target="n3" id="e2"/>
            <set node="n1 n2" id="set3"/>        
        </tree>        
    </trees>
</nex:nexml>
SETS3
}


{
    my $proj3 = parse(
        '-format' => 'nexml',
        '-string' => $sets3,
        '-as_project' => 1,
    );
    
    for my $forest ( @{ $proj3->get_forests } ) {
        for my $tree ( @{ $forest->get_entities } ) {
            my ($set) = @{ $tree->get_sets };
            ok($set);
            $tree->visit(sub {
                my $node = shift;
                my $name = $node->get_xml_id;
                if ( $name eq 'n1' or $name eq 'n2' ) {
                    ok($tree->is_in_set($node,$set));
                }
                else {
                    ok(! $tree->is_in_set($node,$set));
                }
            });
        }
    }

    # TEST SERIALIZE NODE SETS

    my %ids3;
    my $xml3 = $proj3->to_xml;
    XML::Twig->new(
        'twig_handlers' => {
            'set' => sub {
                my ( $twig, $elt ) = @_;
                %ids3 = map { $_ => 1 } grep { /\S/ } split /\s+/, $elt->att('node');
            }
        }
    )->parse($xml3);
    my @ids3 = keys %ids3;
    # ok(exists $ids3{'n1'}); # we no longer try to roundtrip ids in projects
    # ok(exists $ids3{'n2'});
    ok(scalar(@ids3)==2);
}

# TEST PARSE CHARACTER SETS

my $sets4;
{
$sets4 = <<'SETS4';
<nex:nexml 
    version="0.9" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.nexml.org/2009 ../xsd/nexml.xsd"
    xmlns:nex="http://www.nexml.org/2009"
    xmlns="http://www.nexml.org/2009">
    <otus id="taxa1" label="Primary taxa block">
        <otu id="t1" label="Homo sapiens"/>
        <otu id="t2" label="Pan paniscus"/>
        <otu id="t3" label="Pan troglodytes"/>
        <otu id="t4" label="Gorilla gorilla"/>
        <otu id="t5" label="Pongo pygmaeus"/>
    </otus>
    <characters otus="taxa1" id="m3" xsi:type="nex:ContinuousCells" label="Continuous characters">        
        <format>
            <char id="ContinuousCharacter1"/>
            <char id="ContinuousCharacter2"/>
            <char id="ContinuousCharacter3"/>
            <char id="ContinuousCharacter4"/>
            <char id="ContinuousCharacter5"/>
            <set id="set1" char="ContinuousCharacter1 ContinuousCharacter2"/>
        </format>
        <matrix>
            <row id="ContinuousCellsRow1" otu="t1">
                <cell char="ContinuousCharacter1" state="-1.545414144070023"/>
                <cell char="ContinuousCharacter2" state="-2.3905621575431044"/>
                <cell char="ContinuousCharacter3" state="-2.9610221833467265"/>
                <cell char="ContinuousCharacter4" state="0.7868662069161243"/>
                <cell char="ContinuousCharacter5" state="0.22968509237534918"/>
            </row>
            <row id="ContinuousCellsRow2" otu="t2">
                <cell char="ContinuousCharacter1" state="-1.6259836379710066"/>
                <cell char="ContinuousCharacter2" state="3.649352410850134"/>
                <cell char="ContinuousCharacter3" state="1.778885099660406"/>
                <cell char="ContinuousCharacter4" state="-1.2580877968480846"/>
                <cell char="ContinuousCharacter5" state="0.22335354995610862"/>
            </row>
            <row id="ContinuousCellsRow3" otu="t3">
                <cell char="ContinuousCharacter1" state="-1.5798979984134964"/>
                <cell char="ContinuousCharacter2" state="2.9548251411133157"/>
                <cell char="ContinuousCharacter3" state="1.522005675256233"/>
                <cell char="ContinuousCharacter4" state="-0.8642016921755289"/>
                <cell char="ContinuousCharacter5" state="-0.938129801832388"/>
            </row>
            <row id="ContinuousCellsRow4" otu="t4">
                <cell char="ContinuousCharacter1" state="2.7436692306788086"/>
                <cell char="ContinuousCharacter2" state="-0.7151148143399818"/>
                <cell char="ContinuousCharacter3" state="4.592207937774776"/>
                <cell char="ContinuousCharacter4" state="-0.6898841440534845"/>
                <cell char="ContinuousCharacter5" state="0.5769509574453064"/>
            </row>
            <row id="ContinuousCellsRow5" otu="t5">
                <cell char="ContinuousCharacter1" state="3.1060827493657683"/>
                <cell char="ContinuousCharacter2" state="-1.0453787389160105"/>
                <cell char="ContinuousCharacter3" state="2.67416332763427"/>
                <cell char="ContinuousCharacter4" state="-1.4045634106692808"/>
                <cell char="ContinuousCharacter5" state="0.019890469925520196"/>
            </row>
        </matrix>
    </characters>
</nex:nexml>
SETS4
}

{
    my $proj4 = parse(
        '-format' => 'nexml',
        '-string' => $sets4,
        '-as_project' => 1,
    );
    
    for my $matrix ( @{ $proj4->get_matrices } ) {
        my $characters = $matrix->get_characters;
        my ($set) = @{ $characters->get_sets };
        for my $char ( @{ $characters->get_entities } ) {
            my $name = $char->get_xml_id;
            if ( $name =~ m/(?:1|2)$/ ) {
                ok($characters->is_in_set($char,$set));
            }
            else {
                ok(! $characters->is_in_set($char,$set));
            }
        }
    }

    # TEST SERIALIZE CHARACTER SETS

    my %ids4;
    my $xml4 = $proj4->to_xml;
    XML::Twig->new(
        'twig_handlers' => {
            'set' => sub {
                my ( $twig, $elt ) = @_;
                %ids4 = map { $_ => 1 } grep { /\S/ } split /\s+/, $elt->att('char');
            }
        }
    )->parse($xml4);
    my @ids4 = keys %ids4;
    ok(exists $ids4{'ContinuousCharacter1'});
    ok(exists $ids4{'ContinuousCharacter2'});
    ok(scalar(@ids4)==2);
}
