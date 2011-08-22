use strict;
use warnings;
use RDF::Trine::Store::Memory;
use RDF::Trine::Parser;
use RDF::Trine::Model;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger ':levels';

#my $logger = Bio::Phylo::Util::Logger->new(
#    '-level' => DEBUG,
#    '-class' => 'Bio::Phylo::Parsers::Cdao',
#);

my $base   = 'http://example.org/';
my $store  = RDF::Trine::Store::Memory->new;
my $model  = RDF::Trine::Model->new( $store );
my $parser = RDF::Trine::Parser->new('rdfxml');

$parser->parse_file_into_model( $base, 'trees.rdf', $model );
#my $node = RDF::Trine::Node::Resource->new($base . '#ne16');
#
#my $iterator = $model->get_statements($node);
#while ( my $inner = $iterator->next ) {
#    print $inner->subject, ' ', $inner->predicate, ' ', $inner->object, "\n";
#}

print parse(
    '-format' => 'cdao',
    '-file'   => 'trees.rdf',
    '-model'  => $model,
    '-base'   => $base,
    '-as_project' => 1,
)->to_xml;