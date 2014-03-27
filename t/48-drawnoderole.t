#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
	use_ok('Bio::Phylo::Forest::DrawNodeRole');
}

my $node = new_ok('Bio::Phylo::Forest::DrawNodeRole');

my @properties = qw(x y radius tip_radius node_color node_outline_color
node_shape node_image branch_color branch_shape branch_width branch_style
collapsed collapsed_width font_face font_size font_style font_color
text_horiz_offset text_vert_offset rotation);

for my $p ( @properties ) {
	my $setter = "set_$p";
	my $getter = "get_$p";
	my $value = 'foo';
	ok( $node->$setter($value), "set $p" );
	ok( $node->$getter eq $value, "get $p returns $value" );
}

eval { $node->DOES_NOT_EXIST };
ok( $@ =~ /Can't locate object method "DOES_NOT_EXIST"/ );