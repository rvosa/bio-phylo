use Test::More;

BEGIN {
	#plan 'skip_all' => 'XML::XML2JSON is permanently broken';
    eval { require XML::XML2JSON };
    if ($@) {
        plan 'skip_all' => 'XML::XML2JSON not installed';
    }
    eval { require XML::Twig };
    if ($@) {
        plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        Test::More->import('no_plan');
    }    
}
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Factory;
use Bio::Phylo::Util::CONSTANT qw':objecttypes looks_like_object';
use strict;
my $f = Bio::Phylo::Factory->new;
my $p = $f->create_project;
$p->insert(parse('-format'=>'newick','-string'=>'((taxon1,taxon2),taxon3);'));
my $json;
ok( $json = $p->to_json, "JSON correctly returned" );
my $pj = parse( '-format' => 'json', '-string' => $json, '-as_project' => 1 );
ok( looks_like_object( $pj, _PROJECT_ ), "project should be _PROJECT_" );
my ($tj) = @{ $pj->get_taxa };
ok( looks_like_object( $tj, _TAXA_ ), "taxa should be _TAXA_" );
ok( $tj->get_ntax == 3, "ntax should be 3" );
