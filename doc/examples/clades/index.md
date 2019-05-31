---
title: Clade and taxon visualization example
layout: index
---

Input data
==========

The [mammal supertree][1] represents a time-calibrated synthesis of the phylogenetic 
relationships among the extant mammals (normalized against the 
[Mammal Species of the World][2] taxonomy). Here we use a 
[nexus file](Bininda-emonds_2007_mammals.nex) of the dated tree.

Visualizing taxa and clades
===========================

The 


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
[3]: http://doi.org/10.1890/08-1494.1
[4]: http://eol.org