use Test::More;
BEGIN {
    eval { require XML::LibXML::Reader };
    if ( $@ ) {
        plan 'skip_all' => 'XML::LibXML not installed';
    }
    eval { require XML::Twig };
    if ( $@ ) {
	plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        plan 'tests' => 82;
    }
}
use strict;
use File::Temp qw(tempfile);
use File::Spec;

use_ok('Bio::Phylo::NeXML::DOM');
use_ok('XML::Twig');

# check if XML::LibXML is available
my $TEST_XML_LIBXML = eval { require XML::LibXML; 1 };

# element order required by NeXML standard
# see _order() routine below
my $nexml_order = {
    'nex:nexml'  => [qw( otus trees characters )],
    'otus'       => [qw( otu )],
    'otu'        => [qw( id label )],
    'trees'      => [qw( tree )],
    'tree'       => [qw( node edge rootedge )],
    'characters' => [qw( format matrix )],
    'format'     => [qw( states char )],
    'states'     => [qw( state uncertain_state_set )],
    'uncertain_state_set' => [qw( member )],
    'matrix'     => [qw( row )],
    'row'        => [qw( cell seq )]
};

# test DOM mapping formats for interface compliance and functionality

my @formats     = qw( twig libxml );
my @fac_methods = qw( create_element create_document get_format set_format );
my @elt_methods = qw( new get_attributes set_attributes clear_attributes
                   get_tag set_tag set_text get_text clear_text
                   get_parent get_children get_first_daughter get_last_daughter
                   get_next_sister get_previous_sister get_elements_by_tagname
                   set_child prune_child to_xml );
my @doc_methods = qw( new set_encoding get_encoding set_root get_root
                   get_element_by_id get_elements_by_tagname
                   to_xml );

my $twig = XML::Twig->new();
ok( $twig->parse( do { local $/; <DATA> } ), 'test data parsed');
ok( my $test = $twig->root->simplify(keyattr=>[]), 'test XML file as nested data structure' );
$test = {'nex:nexml'=>$test};

for my $format (@formats) {
    SKIP : {
	skip "XML::LibXML not present; skipping", 39 unless (($format eq 'twig') || $TEST_XML_LIBXML);
	ok( my $dom = Bio::Phylo::NeXML::DOM->new(-format => $format),
	    "$format object" );
	
	can_ok( $dom, @fac_methods );
	
	ok( my $elt = $dom->create_element('-tag' => 'boog'), "$format element" );
	ok( my $doc = $dom->create_document, "$format document" );
	
	can_ok( $elt, @elt_methods);
	can_ok( $doc, @doc_methods);
	
	1;
	
	ok( $elt = _parse( undef, 'nex:nexml', $test, $dom), "parse XML structure as $format DOM");
	ok( $doc->set_root($elt), "set $format document root element" );
	SKIP : {
	    #skip 'env var NEXML_ROOT not set', 3 unless $ENV{'NEXML_ROOT'};
	    skip 'skipping remote NeXML validation tests', 3 if 1;
	    my ( $fh, $fn ) = tempfile();
	    ok( $fh, 'make temp file' );
	    ok( print( $fh $doc->to_xml ), "write XML from $format DOM" );
	    $fn =~ s/\\/\//g;
	    is(system( $ENV{'NEXML_ROOT'} . '/perl/script/nexvl.pl', '-Q', $fn) + 1, 1, 'dom-generated XML is valid NeXML');	    
	    #is( (qx{ bash -c " if (../script/nexvl.pl -Q $fn) ; then echo -n 1 ; else echo -n 0 ; fi" })[0], 1, 'dom-generated XML is valid NeXML' );
	}
	is( scalar $doc->get_elements_by_tagname('row'), 6, "get_elements_by_tagname");
	ok( my $s11 = $doc->get_element_by_id('s11'), "found uncertain_state_set s11" );
	ok( my $s12 = $doc->get_element_by_id('s12'), "found uncertain_state_set s12" );
	ok( !$doc->get_element_by_id('s13'), "no s13" );
	ok( !$elt->get_elements_by_tagname('boog'), "no boog here");
	is( scalar $s12->get_elements_by_tagname('member'), 11, "found all members of s12");
	
	
	# test: *_text methods
	ok( $s11->set_text("This state set is somewhat uncertain"), "set text");
	ok( $s11->set_text(" and it still is."), "set 2d text");
	is( $s11->get_text, "This state set is somewhat uncertain and it still is.", "text concatenated");
	ok($s11->clear_text, "clear text attempt");
	ok( !$s11->get_text, "text is gone");
	# test: traversal, prune methods - make sure ids of pruned descendants
	#  disappear from document
	ok( $s12->set_child( $dom->create_element(
	    '-tag'        => 'boog',
	    '-attributes' => {'id'=>'schlarb'}) ), 'test child');
	ok( my $child = $doc->get_element_by_id('schlarb'), 'found child');
	ok( !$s12->prune_child($elt), "can't prune a non-child");
	ok( $s12->prune_child( $child ), "prune child");
	ok( !$doc->get_element_by_id('schlarb'), "child gone by_id");
	# test: clear_* methods
	ok( my $row13 = $doc->get_element_by_id('row13'), "get row13");
	is( $row13->get_attributes('label')->{'label'}, "otuD", "get label");
	ok( $row13->clear_attributes('label'), "clear label attempt");
	ok( !$row13->get_attributes('label')->{'label'}, "label gone" );
	ok( $row13->clear_attributes('id', 'otu'), "clear id, otu attrs");
	ok( !$row13->get_attributes('otu')->{'otu'}, "otu attr gone");
	ok( !$doc->get_element_by_id('row13'), "row13 id gone by_id");
	is( $row13->get_first_daughter->get_tag, "cell", "first child");
	is( $row13->get_next_sister->get_attributes('label')->{'label'}, "otuE", "next sibling");
	is( $row13->get_previous_sister->get_attributes('label')->{'label'}, "otuC", "prev sibling");
	is( $elt->get_first_daughter->get_tag, "otus", "first child of root");
	is( $elt->get_last_daughter->get_tag, "characters", "last child of root");
    }
} # formats

sub _parse {
    my ($elt, $key, $h, $dom) = @_;
    unless ($elt) {
	$elt = $dom->create_element('-tag' => $key);
	foreach my $k ( _order($key, keys %{$$h{$key}}) ) {
	    _parse($elt, $k, $$h{$key}{$k}, $dom);
	}
	return $elt;
    }
    for (ref $h) {
	!$_ && do {
	    $elt->set_attributes($key, $h);
	    last;
	};
	/HASH/ && do {
	    my $new_elt = $dom->create_element('-tag' => $key);
	    $elt->set_child($new_elt);
	    foreach my $new_key (_order($key, keys %$h)) {
		_parse($new_elt, $new_key, $$h{$new_key}, $dom);
	    }
	    last;
	};
	/ARRAY/ && do {
	    foreach my $new_item (@$h) {
		_parse($elt, $key, $new_item, $dom);
	    }
	    last;
	};
    }
    return;
}

sub _order {
    my ($key, @a) = @_;
    return @a unless ($$nexml_order{$key});
    my (%h, @o,$max);
    @h{ @{$$nexml_order{$key}} } = (0..@{$$nexml_order{$key}});
    @o = @h{@a};
    $max = 0;
    for my $o ( @o ) {
    	next unless $o;
    	$max = $o if $o > $max;
    }
    #$max = ($_ > $max ? $_ : $max) for @o;
    map { $_ = ++$max unless defined } @o;
    @a[@o] = @a;
    return @a;
}
	
__DATA__
<nex:nexml generator="Bio::Phylo::Project v.0.17_RC9_841" version="0.9" xmlns="http://www.nexml.org/2009" xmlns:nex="http://www.nexml.org/2009" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.nexml.org/2009 http://www.nexml.org/2009/nexml.xsd">
<!-- this is a simple test file generated from a NEXUS file -->
<otus id="otus1">
    <otu id="otu2" label="otuA"/>
    <otu id="otu3" label="otuB"/>
    <otu id="otu4" label="otuC"/>
    <otu id="otu5" label="otuD"/>
    <otu id="otu6" label="otuE"/>
    <otu id="otu7" label="otuF"/>
  </otus>
  <trees id="trees16" otus="otus1">
    <tree id="tree18" label="'the tree'" xsi:type="nex:IntTree">
      <node id="node19" root="true"/>
      <node id="node20" label="otuA" otu="otu2"/>
      <node id="node21"/>
      <node id="node22"/>
      <node id="node27"/>
      <node id="node23"/>
      <node id="node26" label="otuD" otu="otu5"/>
      <node id="node28" label="otuE" otu="otu6"/>
      <node id="node29" label="otuF" otu="otu7"/>
      <node id="node24" label="otuB" otu="otu3"/>
      <node id="node25" label="otuC" otu="otu4"/>
      <edge id="edge20" length="4" source="node19" target="node20"/>
      <edge id="edge21" length="1" source="node19" target="node21"/>
      <edge id="edge22" length="1" source="node21" target="node22"/>
      <edge id="edge27" length="2" source="node21" target="node27"/>
      <edge id="edge23" length="1" source="node22" target="node23"/>
      <edge id="edge26" length="2" source="node22" target="node26"/>
      <edge id="edge28" length="1" source="node27" target="node28"/>
      <edge id="edge29" length="1" source="node27" target="node29"/>
      <edge id="edge24" length="1" source="node23" target="node24"/>
      <edge id="edge25" length="1" source="node23" target="node25"/>
    </tree>
  </trees>
  <characters id="characters8" otus="otus1" xsi:type="nex:StandardCells">
    <format>
      <states id="states10">
        <state id="s1" symbol="0"/>
        <state id="s2" symbol="1"/>
        <state id="s3" symbol="2"/>
        <state id="s4" symbol="3"/>
        <state id="s5" symbol="4"/>
        <state id="s6" symbol="5"/>
        <state id="s7" symbol="6"/>
        <state id="s8" symbol="7"/>
        <state id="s9" symbol="8"/>
        <state id="s10" symbol="9"/>
        <uncertain_state_set id="s11" symbol="-"></uncertain_state_set>
        <uncertain_state_set id="s12" symbol="?">
          <member state="s1"/>
          <member state="s2"/>
          <member state="s3"/>
          <member state="s4"/>
          <member state="s5"/>
          <member state="s6"/>
          <member state="s7"/>
          <member state="s8"/>
          <member state="s9"/>
          <member state="s10"/>
          <member state="s11"/>
        </uncertain_state_set>
      </states>
      <char id="c1" states="states10"/>
    </format>
    <matrix>
      <row id="row9" label="otuA" otu="otu2">
        <cell char="c1" state="s1"/>
      </row>
      <row id="row11" label="otuB" otu="otu3">
        <cell char="c1" state="s3"/>
      </row>
      <row id="row12" label="otuC" otu="otu4">
        <cell char="c1" state="s3"/>
      </row>
      <row id="row13" label="otuD" otu="otu5">
        <cell char="c1" state="s1"/>
      </row>
      <row id="row14" label="otuE" otu="otu6">
        <cell char="c1" state="s2"/>
      </row>
      <row id="row15" label="otuF" otu="otu7">
        <cell char="c1" state="s1"/>
      </row>
    </matrix>
  </characters>
</nex:nexml>
    
       
    
