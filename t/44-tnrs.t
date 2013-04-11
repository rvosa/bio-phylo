#!/usr/bin/perl
use Test::More;
BEGIN {
    eval { require XML::Twig; require JSON };
    if ($@) {
        plan 'skip_all' => 'XML::Twig or JSON not installed';
    }
    else {
        Test::More->import('no_plan');
    }
}

use strict;
use warnings;
use Bio::Phylo::IO qw'parse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

my $project = parse(
	'-handle' => \*DATA,
	'-format' => 'tnrs',
	'-as_project' => 1
);

my ($taxa) = @{ $project->get_items(_TAXA_) };
ok( $taxa->get_ntax == 4 );

__DATA__
 {
    "metadata": {
        "jobId": 1,
        "submitDate": "2012-06-06T14:54Z",
        "sources": [{
            "sourceId": "ITIS",
            "sourceName": "Integrated Taxonomic Information System",
            "uri": "http://www.itis.gov/",
            "rank": 1,
            "status": "online",
            "annotations": {"TSN": "Taxonomic Serial Number, ITIS' internal identifier"}
        }, {
            "sourceId": "NCBI Taxonomy",
            "sourceName": "NCBI Taxonomy",
            "uri": "http://www.ncbi.nlm.nih.gov/taxonomy",
            "rank": 2,
            "status": "online",
            "annotations": {
				"nucleotide_uri": "A link to nucleotide sequences on GenBank for this taxon",
				"protein_uri": "A link to protein sequences on GenBank for this taxon."
			}
        }, {
            "sourceId": "iPlant TNRS",
            "sourceName": "iPlant Collaborative Taxonomic Name Resolution Service v3.0 ",
            "uri": "http://tnrs.iplantcollaborative.org/",
            "rank": 3,
            "status": "online",
            "annotations": {"Authority": "The taxonomic authority for the species."}
        }, {
            "sourceId": "ABC TNRS",
            "sourceName": "Animals, Birds and Cattle TNRS",
            "uri": "http://www.example.com/tnrs",
            "rank": 4,
            "status": "offline",
            "annotations": {}
        }]
    },
    "names": [{
        "submittedName": "Panthera tigris",
        "matchCount": 1,
        "matches": [{
            "sourceId": "ITIS",
            "matchedName": "Panthera tigris",
            "acceptedName": "Panthera tigris",
            "uri": "http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=183805",
            "annotations": { "TSN": "183805" },
            "score": 1.0
        }]
    }, {
        "submittedName": "Eutamias minimus",
        "matchCount": 1,
        "matches": [{
            "sourceId": "ITIS",
            "matchedName": "Eutamias minimus",
            "acceptedName": "Tamias minimus",
            "uri": "http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=180195",
            "annotations": { "TSN": "180195" },
            "score": 0.5
        }]
    }, {
        "submittedName": "Magnifera indica",
        "matchCount": 1,
        "matches": [{
            "sourceId": "iPlant TNRS",
            "matchedName": "Mangifera indica",
            "acceptedName": "Mangifera indica",
            "uri": "http://www.tropicos.org/Name/1300071",
            "annotations": { "Authority": "L." },
            "score": 0.98
        }]
    }, {
        "submittedName": "Humbert humbert",
        "matchCount": 0,
        "matches": []
    }]
  }
