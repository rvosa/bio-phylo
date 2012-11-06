#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find;

check_prereq( qw(
    SVG
    Math::Random
    XML::Twig
    XML::LibXML
    Math::CDF
    List::Util
    SWF::Builder
    XML::XML2JSON
    PDF::API2
    GD
) );

my %parms = (
    'NAME'         => 'Bio-Phylo',
    'AUTHOR'       => 'Rutger Vos',
    'PL_FILES'     => {},
    'EXE_FILES'    => [],
    'VERSION_FROM' => 'lib/Bio/Phylo.pm',
    'LICENSE'      => 'perl',
    'ABSTRACT'     => 'An object-oriented Perl toolkit for analyzing and manipulating phyloinformatic data.',
    'clean'        => {},    
    'dist'         => { 'COMPRESS' => 'gzip -9f', 'SUFFIX' => 'gz', },
);

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $parms{META_MERGE} = {
        resources => {
            homepage    => 'http://biophylo.blogspot.com/',
            bugtracker  => 'https://github.com/rvosa/bio-phylo',
            repository  => 'git://github.com/rvosa/bio-phylo.git',
        }
    };
}

WriteMakefile( %parms );

sub check_prereq {
    my @classes = @_;
    for my $class ( @classes ) {
        eval "require $class";
        if ( $@ ) {
            print "*** The optional dependency \"$class\" can't be loaded.\n";
            print "    I will continue, but some functionality will not be \n";
            print "    available. Refer to the Bio::Phylo README file for\n";
            print "    more information.\n\n";
        }
    }
}