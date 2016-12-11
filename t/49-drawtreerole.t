#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
	use_ok('Bio::Phylo::Forest::DrawTreeRole');
}

my $tree = new_ok('Bio::Phylo::Forest::DrawTreeRole');

my @properties = qw(width height node_radius tip_radius node_color node_shape
node_image branch_color branch_shape branch_width branch_style collapsed_clade_width
font_face font_size font_style margin margin_top margin_bottom margin_left 
margin_right padding padding_top padding_bottom padding_left padding_right
mode shape text_horiz_offset text_vert_offset);

for my $p ( @properties ) {
	my $setter = "set_$p";
	my $getter = "get_$p";
	my $value = 'CLADO';
	ok( $tree->$setter($value), "set $p" );
	ok( $tree->$getter eq $value, "get $p returns $value" );
}

eval { $tree->DOES_NOT_EXIST };
ok( $@ =~ /Can't locate object method "DOES_NOT_EXIST"/ );