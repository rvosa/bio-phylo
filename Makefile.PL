#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find;

my %recommended = (
    'SVG'           => '0',
    'Math::Random'  => '0',
    'Math::CDF'     => '0',
    'XML::XML2JSON' => '0',    
    'XML::Twig'     => '0',
    'XML::LibXML'   => '0',
    'List::Util'    => '0',
    'SWF::Builder'  => '0',
    'PDF::API2'     => '0',
    'GD'            => '0',
    'JSON'          => '0',
    'Archive::Zip'  => '0',
    'RDF::Trine'    => '0',
    'RDF::Query'    => '0',
);

check_prereq( keys %recommended );

my %parms = (
    'NAME'         => 'Bio::Phylo', # EU::MM apparently now wants Package::Name
    'AUTHOR'       => 'Rutger Vos',
    'PL_FILES'     => {},
    'EXE_FILES'    => [],
    'VERSION_FROM' => 'lib/Bio/Phylo.pm',
    'LICENSE'      => 'perl',
    'ABSTRACT'     => 'An object-oriented Perl toolkit for analyzing and manipulating phyloinformatic data.',
    'clean'        => {},    
    'dist'         => {
        'COMPRESS' => 'gzip -9f',
        'SUFFIX'   => 'gz',
        'TARFLAGS' => '-c -v -f',
    },
);

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $parms{META_MERGE} = {
        resources => {
            homepage    => 'http://biophylo.blogspot.com/',
            bugtracker  => 'https://github.com/rvosa/bio-phylo/issues',
            repository  => 'git://github.com/rvosa/bio-phylo.git',
            license     => 'http://dev.perl.org/licenses/',
            MailingList => 'mailto:bio-phylo@googlegroups.com',
        },
        'recommends' => \%recommended,
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
