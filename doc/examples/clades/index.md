---
title: Clade and taxon visualization example
layout: index
---

Input data
==========

The [mammal supertree][1] represents a time-calibrated synthesis of the phylogenetic 
relationships among the extant mammals (normalized against the 
[Mammal Species of the World][2] taxonomy). Here we use a 
[nexus file](Bininda-emonds_2007_mammals.nex) of the dated tree. The file includes a 
[characters][3] block that holds a single binary character, where state `1` means that 
the species is domesticated and state `0` means this is a wild species. In addition,
the file includes a [taxon set][4] specifying the [Ungulates][5].

Visualizing taxa and clades
===========================

The visualization must do the following:

1. Fit quite tightly: it's a very big tree that we want to squeeze in a single figure.
2. Show the Ungulates as a clade.
3. Show the domesticated species.


Dependencies
============

The scripts are written in Perl, and require a number of packages that are freely 
available from the comprehensive Perl archive network. If you know what you are doing and
you have a correctly configured system, the installation is as simple as issuing the
command `sudo cpanm Package::Name`, where `Package::Name` is one of the packages below. 
(I'm afraid I can't provide support for setting up your environment and installing
dependencies. These are standard operations for which there is ample documentation 
online.) Required packages:

- [Convert::Color](http://search.cpan.org/dist/Convert-Color)
- [List::Util](http://search.cpan.org/dist/List-Util)
- [Bio::Phylo](http://search.cpan.org/dist/Bio-Phylo)
- [SVG](http://search.cpan.org/dist/SVG)

[1]: http://doi.org/10.1038/nature05634
[2]: http://www.departments.bucknell.edu/biology/resources/msw3/
[3]: https://github.com/rvosa/bio-phylo/blob/gh-pages/doc/examples/clades/Bininda-emonds_2007_mammals.nex#L12-L4528
[4]: https://github.com/rvosa/bio-phylo/blob/gh-pages/doc/examples/clades/Bininda-emonds_2007_mammals.nex#L9049-L9051
[5]: https://en.wikipedia.org/wiki/Ungulate