#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Bio::Phylo::IO 'parse';

BEGIN {
    eval { require SVG };
    if ($@) {
        plan 'skip_all' => 'SVG not installed';
        done_testing();
    }
}

# test if the module can be loaded
BEGIN {
	use_ok('Bio::Phylo::Treedrawer');
}

# test if the drawer can be instantiated
my $treedrawer = new_ok('Bio::Phylo::Treedrawer');

# parse a tree object
my $tree = Bio::Phylo::IO->parse(
    '-format' => 'newick',
    '-string' => '((A:1,B:1)n1:1,C:1)n2:0;'
)->first;

# test basic drawer setters
ok( $treedrawer->set_width(400),            'set width' );
ok( $treedrawer->set_height(600),           'set height' );
ok( $treedrawer->set_mode('clado'),         'set mode to clado' );
ok( $treedrawer->set_shape('curvy'),        'set shape to curvy' );
ok( $treedrawer->set_padding(50),           'set padding' );
ok( $treedrawer->set_node_radius(0),        'set node radius' );
ok( $treedrawer->set_text_horiz_offset(10), 'set text horiz offset' );
ok( $treedrawer->set_text_vert_offset(3),   'set text vert offset' );
ok( $treedrawer->set_text_width(150),       'set text width' );
ok( $treedrawer->set_tree($tree),           'set tree' );
ok( $treedrawer->set_format('svg'),         'set out format' );
ok(
    $treedrawer->set_scale_options(
        '-width' => '100%',
        '-minor' => '2%',
        '-major' => '10%'
    ),
    'set scale options'
);

# test drawing 
ok( $treedrawer->draw, 'draw' );
done_testing();