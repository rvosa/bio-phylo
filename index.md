---
layout: index
---

      <header>
        <h1>Bio-phylo</h1>
        <p>Bio::Phylo - Phyloinformatic analysis using Perl</p>

        <p class="view"><a href="https://github.com/rvosa/bio-phylo">View the Project on GitHub <small>rvosa/bio-phylo</small></a></p>


        <ul>
          <li><a href="https://github.com/rvosa/bio-phylo/zipball/master">Download <strong>ZIP File</strong></a></li>
          <li><a href="https://github.com/rvosa/bio-phylo/tarball/master">Download <strong>TAR Ball</strong></a></li>
          <li><a href="https://github.com/rvosa/bio-phylo">View On <strong>GitHub</strong></a></li>
        </ul>
      </header>
      <section>
        <h1>
<a id="biophylo" class="anchor" href="#biophylo" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>Bio::Phylo</h1>

<p>An object-oriented toolkit for analyzing and manipulating phyloinformatic data. </p>

<h2>
<a id="description" class="anchor" href="#description" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>DESCRIPTION</h2>

<p>Phylogenetics is the branch of evolutionary biology that deals with reconstructing and 
analyzing the tree of life. This distribution provides objects and methods to aid in 
handling and analyzing phylogenetic data.</p>

<h2>
<a id="compatibility" class="anchor" href="#compatibility" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>COMPATIBILITY</h2>

<p>Bio::Phylo installs without problems on most popular, current platforms (Win32, OSX, 
Linux, Solaris, IRIX, FreeBSD, OpenBSD, NetBSD), on Perl versions &gt;= 5.8.0</p>

<p>For a list of automated test results for the latest release number visit:</p>

<p><a href="http://testers.cpan.org/show/Bio-Phylo.html">http://testers.cpan.org/show/Bio-Phylo.html</a></p>

<p>Currently, the build status at Travis is:</p>

<p><a href="https://travis-ci.org/rvosa/bio-phylo"><img src="https://travis-ci.org/rvosa/bio-phylo.svg?branch=master" alt="Build Status"></a></p>

<h2>
<a id="installation" class="anchor" href="#installation" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>INSTALLATION</h2>

<p>Bio::Phylo has no dependencies for its core install. However, some additional 
functionality will not work (e.g. XML parsing) until the CPAN module that enables 
it has been installed (e.g. XML::Twig). You can install these at a later date if 
and when need arises. For example, when you get an error message at runtime that 
alerts you to a missing dependency. If any of such additional CPAN modules are 
found to be missing at installation time, a warning will be emitted, but 
installation and unit testing can continue.</p>

<p>To install the Bio::Phylo distribution itself, run the following commands: </p>

<ul>
<li><code>perl Makefile.PL</code></li>
<li><code>make</code></li>
<li>
<code>make test</code> (Optional, runs unit tests, which should pass)</li>
<li><code>make install</code></li>
</ul>

<p>(For platform specific information on what 'make' command to use, check "perl -V:make". 
On Windows this usually returns "make='nmake';", which means you'll need the free 'nmake' 
utility)</p>

<h2>
<a id="contributors" class="anchor" href="#contributors" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>CONTRIBUTORS</h2>

<ul>
<li>Rutger Vos</li>
<li>Jason Caravas</li>
<li>Klaas Hartmann</li>
<li>Mark A. Jensen</li>
<li>Chase Miller</li>
<li>Aki Mimoto</li>
<li>Hannes Hettling</li>
<li>Florent Angly</li>
</ul>

<h2>
<a id="bugs" class="anchor" href="#bugs" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>BUGS</h2>

<p>Please report any bugs or feature requests on the GitHub bug tracker:</p>

<p><a href="https://github.com/rvosa/bio-phylo/issues">https://github.com/rvosa/bio-phylo/issues</a></p>

<h2>
<a id="acknowledgements" class="anchor" href="#acknowledgements" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>ACKNOWLEDGEMENTS</h2>

<p>The authors would like to thank the BioPerl project for providing the community
with a terrific toolkit that other software, such as this, can be built on
(<a href="http://www.bioperl.org">http://www.bioperl.org</a>); and Arne Mooers from the FAB* lab (<a href="http://www.sfu.ca/%7Efabstar">http://www.sfu.ca/~fabstar</a>) 
for comments and requests.</p>

<p>The research leading to these results has received funding from the European
Community's Seventh Framework Programme (FP7/2007-2013) under grant agreement
no. 237046.</p>

<h2>
<a id="see-also" class="anchor" href="#see-also" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>SEE ALSO</h2>

<p>Read the manual: perldoc Bio::Phylo::Manual</p>

<h2>
<a id="citation" class="anchor" href="#citation" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>CITATION</h2>

<p>If you use Bio::Phylo in published research, please cite it:</p>

<p>Rutger A Vos, Jason Caravas, Klaas Hartmann, Mark A Jensen
and Chase Miller, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
BMC Bioinformatics 12:63.
doi:10.1186/1471-2105-12-63</p>

<h2>
<a id="copyright--license" class="anchor" href="#copyright--license" aria-hidden="true"><span aria-hidden="true" class="octicon octicon-link"></span></a>COPYRIGHT &amp; LICENSE</h2>

<p>Copyright 2005-2015 Rutger Vos, All Rights Reserved. This program is free software; 
you can redistribute it and/or modify it under the same terms as Perl itself.</p>
      </section>
      <footer>
        <p>This project is maintained by <a href="https://github.com/rvosa">rvosa</a></p>
        <p><small>Hosted on GitHub Pages &mdash; Theme by <a href="https://github.com/orderedlist">orderedlist</a></small></p>
      </footer>