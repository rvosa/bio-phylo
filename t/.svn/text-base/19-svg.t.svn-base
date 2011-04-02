# $Id$
use Test::More;
BEGIN {
    eval { require SVG };
    if ( $@ ) {
         plan 'skip_all' => 'SVG not installed';
    }
    else {
        plan 'tests' => 13;
    }
}
use strict;
use lib 'lib/';
use Bio::Phylo::IO;

require Bio::Phylo::Treedrawer;
my $tree = Bio::Phylo::IO->parse( -format => 'newick', -string => '((A:1,B:1)n1:1,C:1)n2:0;' )->first;
my $treedrawer = Bio::Phylo::Treedrawer->new;

ok($treedrawer->set_width(400), 'test 1');
ok($treedrawer->set_height(600), 'test 2');
ok($treedrawer->set_mode('clado'), 'test 3');
ok($treedrawer->set_shape('curvy'), 'test 4');
ok($treedrawer->set_padding(50), 'test 5');
ok($treedrawer->set_node_radius(0), 'test 6');
ok($treedrawer->set_text_horiz_offset(10), 'test 7');
ok($treedrawer->set_text_vert_offset(3), 'test 8');
ok($treedrawer->set_text_width(150), 'test 9');
ok($treedrawer->set_tree($tree), 'test 10');
ok($treedrawer->set_format('svg'), 'test 11');
ok($treedrawer->set_scale_options( -width => '100%', -minor => '2%', -major => '10%' ), 'test 12');
ok($treedrawer->draw, 'test 13');
