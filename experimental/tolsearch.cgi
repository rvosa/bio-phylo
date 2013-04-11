#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Bio::Phylo::PhyloWS::Service::Tolsearch;

Bio::Phylo::PhyloWS::Service::Tolsearch
    ->new( '-url' => "http://localhost/cgi-bin/tolsearch/phylows/" )
    ->handle_request( CGI->new );
