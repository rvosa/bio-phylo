use Test::More;
BEGIN {
    eval { require SVG };
    if ( $@ ) {
         plan 'skip_all' => 'SVG not installed';
    }
    else {
        plan 'tests' => 1;
    }
}
use Bio::Phylo::IO 'parse';
require Bio::Phylo::Treedrawer;

 my $string = '((A:1,B:2)n1:3,C:4)n2:0;';
 my $tree = parse( -format => 'newick', -string => $string )->first;

 my $treedrawer = Bio::Phylo::Treedrawer->new(
    -width  => 800,
    -height => 600,
    -shape  => 'CURVY', # curvogram
    -mode   => 'PHYLO', # cladogram
    -format => 'SVG'
 );

 $treedrawer->set_scale_options(
    -width => '100%',
    -major => '10%', # major cross hatch interval
    -minor => '2%',  # minor cross hatch interval
    -label => 'MYA',
 );

 $treedrawer->set_tree($tree);
 
my $t1 = $treedrawer->draw;
my $t2 = $treedrawer->draw;

ok( $t1 eq $t2, '1: multiple draws yields same svg' );

