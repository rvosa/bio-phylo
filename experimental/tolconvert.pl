#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::CONSTANT qw':objecttypes looks_like_object';

=begin comment

This example script reads the file 'tol.xml', which containes a subtree in ToLWeb XML 
format (in this case, the subtree for Bembidion, as a salute to David Maddison) and 
writes it out in NeXML in the file 'tol-nexml.xml'. By examining the input and output
it should be fairly obvious how the metadata elements and attributes[1] from the ToLWeb 
XML are converted to semantic annotations in NeXML. 

Note that the NeXML writer does not do any pretty printing (indentation), so to see a
slightly more easily readable version of the result, look at 'tol-nexml-pp.xml';

[1] http://tolweb.org/tree/home.pages/downloadtree.html

=cut comment

open my $filehandle, '>', 'tol-nexml.xml';

print $filehandle parse(
    '-format'     => 'tolweb',
    '-file'       => 'tol.xml',
    '-as_project' => 1,
)->to_xml;