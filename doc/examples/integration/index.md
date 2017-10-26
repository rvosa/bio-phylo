---
title: Data integration example
layout: index
---

Input data
==========

The [mammal supertree][1] represents a time-calibrated synthesis of the phylogenetic 
relationships among the extant mammals (normalized agains the [Mammal Species of the World][2]
taxonomy). Here we use a [nexus file](Bininda-emonds_2007_mammals.nex) of the data tree.

The [PanTHERIA][3] project is a trait database of the mammals, containing mostly 
life-history traits. Conveniently, this database uses the same taxonomy as the mammal
supertree. Here we use a [tab-separated file](PanTHERIA_1-0_WR93_Aug2008.tsv) that 
represents the August, 2008 release of the database.

Integrating the data sets
=========================

As a first step, we do an inner join of the two data sets, so that the merger only 
includes the taxa that are both present in the tree as well as the database. From the
database, we embed one data column, which we log-transform (because the default is
body mass) and transform to color values along the spectrum (i.e. the lowest observed
value is red, the highest violet). In addition, we annotate the tree such that 
monophyletic genera receive a clade label on their MRCA node. We do all this by executing
[this script](binindaXpantheria.pl), like so:

    perl binindaXpantheria.pl \
    	--tree=Bininda-emonds_2007_mammals.nex \
		--data=PanTHERIA_1-0_WR93_Aug2008.tsv \
		--names=MSW93_Binomial \
		--column='5-1_AdultBodyMass_g' \
	> tree.xml

All the arguments shown here are the default values that are also embedded in the script.
The `--names` argument specifies which column in the PanTHERIA database contains the 
taxon names that should match those in the tree. The `--column` argument specifies which
trait to plot on the tree. Hence, you can experiment with other traits besides the
example given here (which is body mass), but keep in mind that the script log-transforms
the input values, which might make sense for body mass, but not necessarily for the other
traits in the database (let me know if there needs to be a switch to turn the 
transformation on and off). 

There is also an optional `--verbose` argument that can be used multiple times to increase
the verbosity of the script. By default, only warnings and error messages are printed;
by increasing this value, also informational messages and debugging messages can be
printed. (It might be reassuring to do this because some of the steps take some time and
this way you get some progress feedback.) The result of the script is normally written to
STDOUT, so here we re-direct it to a [file](tree.xml), which is in 
[nexml](http://nexml.org) format.

Visualizing the result
======================

In the next step, we visualize the results as a radial phylogram with painted branches and
braces to mark up the monophyletic genera. The [drawer script](drawer.pl) is invoked as
follows:

    perl drawer.pl \
		--width=12000 \
		--height=12000 \
		--shape=radial \
		--nexml=tree.xml \
	> tree.svg

Again, all the arguments shown here are the default values that are embedded in the 
script. The `--width` and `--height` values are in pixels. `--shape` specifies the tree
shape, and `--nexml` the location of the file that we produced in the previous step. The
output is written to STDOUT so we re-direct into the file [tree.svg](tree.svg). In this
SVG file, the taxon names have been made clickable, triggering a query to the 
[Encyclopedia of Life][4]. Because there is some potential for compatibility issues with
SVG (not all browser and editors interpret and support the standard to the same extent) I
also made a [PDF version](tree.pdf) (by opening the SVG in Illustrator and saving to PDF).


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