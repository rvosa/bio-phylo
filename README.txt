Bio::Phylo
==========

An object-oriented Perl toolkit for analyzing and manipulating phyloinformatic data. 

DESCRIPTION
-----------
Phylogenetics is the branch of evolutionary biology that deals with reconstructing and 
analyzing the tree of life. This distribution provides objects and methods to aid in 
handling and analyzing phylogenetic data.

COMPATABILITY
-------------
Bio::Phylo installs without problems on most popular, current platforms (Win32, OSX, 
Linux, Solaris, IRIX, FreeBSD, OpenBSD, NetBSD), on Perl versions >= 5.8.0

For a list of automated test results visit:

http://testers.cpan.org/show/Bio-Phylo.html

Currently, the build status is:

[![Build Status](https://travis-ci.org/rvosa/bio-phylo.svg?branch=master)](https://travis-ci.org/rvosa/bio-phylo)

INSTALLATION
------------
Bio::Phylo has no dependencies for its core install. However, some additional 
functionality will not work (e.g. XML parsing) until the CPAN module that enables it has 
been installed (e.g. XML::Twig). You can install these at a later date if and when need 
arises. If any of such additional CPAN modules are found to be missing at installation 
time, a warning will be emitted, but installation can continue.

To install the Bio::Phylo distribution itself, run the
following commands: 

perl Makefile.PL
make
make test
make install
 
(For platform specific information on what 'make' command to use, check "perl -V:make". 
On Windows this usually returns "make='nmake';", which means you'll need the free 'nmake' 
utility)

AUTHORS
-------
Rutger Vos
Jason Caravas
Klaas Hartmann
Mark A. Jensen
Chase Miller
Aki Mimoto

BUGS
----
Please report any bugs or feature requests on the GitHub bug tracker:

https://github.com/rvosa/bio-phylo/issues
 
ACKNOWLEDGEMENTS
----------------
The authors would like to thank the BioPerl project for providing the community
with a terrific toolkit that other software, such as this, can be built on
(http://www.bioperl.org); and Arne Mooers from the FAB* lab (http://www.sfu.ca/~fabstar) 
for comments and requests.

The research leading to these results has received funding from the European
Community's Seventh Framework Programme (FP7/2007-2013) under grant agreement
no. 237046.

SEE ALSO
--------
Read the manual: perldoc Bio::Phylo::Manual

CITATION
--------
If you use Bio::Phylo in published research, please cite it:

Rutger A Vos, Jason Caravas, Klaas Hartmann, Mark A Jensen
and Chase Miller, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
BMC Bioinformatics 12:63.
doi:10.1186/1471-2105-12-63

COPYRIGHT & LICENSE
-------------------
Copyright 2005-2014 Rutger Vos, All Rights Reserved. This program is free software; 
you can redistribute it and/or modify it under the same terms as Perl itself.

