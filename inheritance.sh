#!/bin/bash
cd lib
pms=`find . -name "*.pm" | sed -e 's/\.\///'`
inheritance \
	--skip=Bio::Phylo::PhyloWS \
	--skip=Bio::Phylo::NeXML::DOM \
	--skip=Bio::Phylo::EvolutionaryModels \
	--collapse=Bio::Phylo::Parsers \
	--collapse=Bio::Phylo::Unparsers \
	--collapse=Bio::Phylo::Matrices::Datatype \
	--skip=Bio::Phylo::Taxa::TaxonLinker \
	--skip=Bio::Phylo::Taxa::TaxaLinker \
	--skip=Bio::Align::AlignI \
	--skip=Bio::Tree::TreeI \
	--skip=Bio::Seq  -- $pms > ../inheritance1.dot
cd ..