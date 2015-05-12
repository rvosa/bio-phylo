#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

eval { require Statistics::R };

 SKIP: {
		 skip 'Statistics::R not installed', 1, if $@;
		 
		 # get dna data
		 my $project = parse(
				 '-format'     => 'fasta',
				 '-type'       => 'dna',
				 '-handle'     => \*DATA,
				 '-as_project' => 1,
		     );
		 my ($matrix) = @{ $project->get_items(_MATRIX_) };
		 
		 for my $seq ( @{ $matrix->get_entities } ) {
				 $seq->set_generic('fasta_def_line'=>$seq->get_name);
		 }
		 
		 # get tree
		 my $newick = '((taxon2:1,taxon4:1):1,(taxon1:1,taxon3:1):1);';
		 my $tree = parse(
				 '-format' => 'newick',
				 '-string'   => $newick,
		     )->first->resolve;
		 
		 # replicate dna data
		 my $rep = $matrix->replicate('-tree'=>$tree);
		 ok($rep);
}

__DATA__
>taxon1
g----g--agagagagggattcgaaccctcgatagttcgttgttcagaactataccggttttcaag
>taxon2
g----g--agagagagggattcgaaccctcgatagttcgttgttcagaactataccggttttcaag
>taxon3
g----g--agagagagggattcgaaccctcgatagttcgttgttcagaactataccggttttcaag
>taxon4
gaaaag--agagagagggattcgaaccctcgatagttcgttgttcagaactataccggttttcaag
