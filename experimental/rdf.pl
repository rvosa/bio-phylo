use strict;
use warnings;
use RDF::Trine::Store::Memory;
use RDF::Trine::Parser;
use RDF::Trine::Model;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger ':levels';

my $logger = Bio::Phylo::Util::Logger->new(
    '-level'  => DEBUG,
    '-method' => [
        'Bio::Phylo::Parsers::Cdao::_process_matrices',
        'Bio::Phylo::Parsers::Cdao::_create_characters',
        'Bio::Phylo::Parsers::Cdao::_create_rows',        
    ]
);

my $base   = 'http://example.org/';
my $store  = RDF::Trine::Store::Memory->new;
my $model  = RDF::Trine::Model->new( $store );
my $parser = RDF::Trine::Parser->new('rdfxml');

$parser->parse_file_into_model( $base, 'characters.rdf', $model );

print parse(
    '-format'     => 'cdao',
    '-file'       => 'characters.rdf',
    '-model'      => $model,
    '-base'       => $base,
    '-as_project' => 1,
)->to_xml;