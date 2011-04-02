#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Treedrawer;

my $PI2 = 8 * atan2(1, 1);
my $td = Bio::Phylo::Treedrawer->new( 
	'-format' => 'svg', 
	'-shape'  => 'diag', 
	'-width'  => 600, 
	'-height' => 600,
);
$td->set_tree( parse( '-format' => 'newick', '-string' => do { local $/; <DATA> } )->first );

my $t = $td->get_tree;
my $is_clado = $t->is_cladogram;
my $tip_count = scalar @{ $t->get_terminals };
my ( $counter, $xmax, $ymax ) = ( 0, 0, 0 );
$t->visit_depth_first(
	'-post' => sub {
		my $n = shift;
#		warn $n->get_name;
		if ( $n->is_internal ) {
			my $sum = 0;
			my @children = @{ $n->get_children };
			$sum += $_->get_generic('rad') for @children;
			$n->set_generic( 'rad' => $sum / scalar @children );
		}
		my $x = sin($n->get_generic('rad')*$PI2);# * $n->get_generic('depth');
		my $y = cos($n->get_generic('rad')*$PI2);# * $n->get_generic('depth');
		$n->set_x( $x ); # make these coordinates relative to parent
		$n->set_y( $y );
	},
	'-pre' => sub {
		my $n = shift;
		if ( $n->is_terminal ) {
			my $rad = $counter / $tip_count;
			$n->set_generic( 'rad' => $rad );
			$counter++;
		}
		if ( my $p = $n->get_parent ) {
			if ( $is_clado ) {
				$n->set_generic( 'depth' => $p->get_generic('depth') + 1 );
			}
			else {
				$n->set_generic( 'depth' => $p->get_generic('depth') + $n->get_branch_length );
			}
		}
		else {
			$n->set_generic( 'depth' => 0 );		
		}
	},
);

$t->visit_depth_first(
	'-pre' => sub {
		my $n = shift;
		my ( $px, $py ) = ( 0, 0 );
		my ( $x, $y ) = ( $n->get_x, $n->get_y );
		if ( my $p = $n->get_parent ) {
			( $px, $py ) = ( $p->get_x, $p->get_y );
		}
		$n->set_x( $px + $x );
		$n->set_y( $py + $y );
	},
	'-post' => sub {
		my $n = shift;
		my ( $x, $y ) = ( $n->get_x, $n->get_y );	
		my $xpos = sqrt($x*$x);
		my $ypos = sqrt($y*$y);
		$xmax = $xpos if $xpos > $xmax;
		$ymax = $ypos if $ypos > $ymax;		
	}
);

my $xscale = $td->get_width  / ( $xmax * 2 );
my $yscale = $td->get_height / ( $ymax * 2 );
my $xplus = $td->get_width  / 2;
my $yplus = $td->get_height / 2;
$t->visit(
	sub {
		my $n = shift;
		$n->set_x( $n->get_x * $xscale + $xplus );
		$n->set_y( $n->get_y * $yscale + $yplus );		
	}
);
print $td->render;


__DATA__
((A,B),C);