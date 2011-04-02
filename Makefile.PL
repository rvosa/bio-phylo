# $Id: Makefile.PL 1661 2011-04-02 20:17:45Z rvos $
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

WriteMakefile(
    'NAME'         => 'Bio-Phylo',
    'AUTHOR'       => 'Rutger Vos',
    'PL_FILES'     => {},
    'EXE_FILES'    => [],
    'VERSION_FROM' => 'lib/Bio/Phylo.pm',
    'LICENSE'      => 'perl',
    'clean'        => {},    
    'dist'         => { 'COMPRESS' => 'gzip -9f', 'SUFFIX' => 'gz', },
);

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