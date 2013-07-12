#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO qw'parse';

# try to detect nexus data
my $nexus = <<'NEXUS';
#NEXUS
BEGIN TAXA;
	DIMENSIONS NTAX=5;
	TAXLABELS
		taxon_1 taxon_2 taxon_3 taxon_4 taxon_5
	;
END;
NEXUS

my $p = parse(
	'-string'     => $nexus,
	'-as_project' => 1,
);

ok( $p->get_taxa->[0]->get_ntax == 5, "detected nexus" );