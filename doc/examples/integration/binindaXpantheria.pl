#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Convert::Color;
use List::Util 'sum';
use Convert::Color::HSV;
use Bio::Phylo::Factory;
use Bio::Phylo::IO qw'parse_tree unparse';
use Bio::Phylo::Util::Logger ':levels';
use Bio::Phylo::Util::CONSTANT ':namespaces';

# process command line arguments
my $tree   = 'Bininda-emonds_2007_mammals.nex';
my $data   = 'PanTHERIA_1-0_WR93_Aug2008.tsv';
my $names  = 'MSW93_Binomial';
my $column = '5-1_AdultBodyMass_g';
my $verbosity = WARN;
GetOptions(
	'tree=s'   => \$tree,
	'data=s'   => \$data,
	'names=s'  => \$names,
	'column=s' => \$column,
	'verbose+' => \$verbosity,
);

# instantiate helper objects
my $fac = Bio::Phylo::Factory->new;
my $log = Bio::Phylo::Util::Logger->new(
	'-level' => $verbosity,
	'-class' => 'main',
);
$log->info("going to read tree '$tree'");
my $t = parse_tree(
	'-format' => 'nexus',
	'-file'   => $tree,
);
$t->visit(sub{ 
	my $n = shift;
	if ( my $name = $n->get_name ) {
		$name =~ s/_/ /g;
		$n->set_name($name);
	}
});
$t->set_namespaces( 'bp' => _NS_BIOPHYLO_ );

# read data file
$log->info("going to read data file $data");
my %header;
open my $fh, '<', $data or die $!;
while(<$fh>) {
	chomp;
	my @fields = split /\t/, $_;
	
	# create header to column index mapping
	if ( not %header ) {
		$log->info("indexing table header");
		my $i = 0;
		$header{$_} = $i++ for @fields;
		$log->info( "column index of $names is ".$header{$names} );
		$log->info( "column index of $column is ".$header{$column} );
	}
	
	# process data
	else {
		my $name = $fields[ $header{$names}  ];
		my $col  = $fields[ $header{$column} ];
		if ( $col != -999 and my $tip = $t->get_by_name($name) ) {
			$log->info("PanTHERIA taxon '$name' with ${column}=$col is in '$tree'");
			
			# dealing with body mass, so log transform is a good idea
			my $transformed = log($col)/log(10);
			$tip->set_generic( $column => $transformed );
			$tip->set_meta_object( 'bp:' . $column => $col );
		}
		else {
			$log->warn("PanTHERIA taxon '$name' is not in '$tree'");
		}
	}
}

# prune tips without data, collect value range
my ( @prune, @values );
$t->visit(sub{
	my $n = shift;
	if ( $n->is_terminal ) {
		my $value = $n->get_generic( $column );
		if ( defined $value ) {
			push @values, $value;
		}
		else {
			push @prune, $n;
			my $name = $n->get_name;			
			$log->warn("Supertree taxon '$name' has no PanTHERIA data");
		}
	}
});
$t->prune_tips(\@prune);
@values = sort { $a <=> $b } @values;
my ( $min, $max ) = ( $values[0], $values[-1] );

# encode HUE
$log->info("going to encode branch colors");
$t->visit_depth_first(
	'-post' => sub {
		my $n = shift;
		if ( $n->is_terminal ) {
			my $raw = $n->get_generic( $column );
			my $scaled = ( $raw - $min ) / ( $max - $min );
			my $c = Convert::Color::HSV->new( $scaled * 360, 1, 1 );
			my $rgb = join ',', map { int(255*$_) } $c->rgb;
			$n->set_generic( 'hue' => $scaled );			
			$n->set_branch_color( "rgb($rgb)" );
			
		}
		else {
			my @vals = map { $_->get_generic('hue') } @{ $n->get_children };
			
			# this should really be using contrasts
			my $averaged = sum(@vals) / scalar(@vals);
			my $c = Convert::Color::HSV->new( $averaged * 360, 1, 1 );
			my $rgb = join ',', map { int(255*$_) } $c->rgb;
			$n->set_generic( 'hue' => $averaged );
			$n->set_branch_color( "rgb($rgb)" );
		}	
	}
);

# annotate clade labels
$log->info("going to annotate clade labels");
$t->visit_depth_first(
	'-post' => sub {
		my $n = shift;
		if ( $n->is_terminal ) {
			my $name = $n->get_name;
			my ($genus) = split / /, $name;
			$n->set_generic( 'genus' => [ $genus ] );
		}
		else {
			my %names;
			for my $c ( @{ $n->get_children } ) {
				my @names = @{ $c->get_generic('genus') };
				++$names{$_} for @names;
			}
			$n->set_generic( 'genus' => [ keys %names ] );
		}
	}
);
$log->info("second pass");
{
	my %seen;
	$t->visit_depth_first(
		'-pre' => sub {
			my $n = shift;
			my @genera = @{ $n->get_generic('genus') };
			if ( scalar(@genera) == 1 and not $seen{$genera[0]} ) {
				$n->set_clade_label( $genera[0] );
				$seen{$genera[0]}++;
			}
		}
	);
}

# print result
$log->info("going to export nexml");
my $proj   = $fac->create_project;
my $forest = $fac->create_forest;
$forest->insert($t);
$proj->insert($forest);
$proj->insert($forest->make_taxa);
print unparse(
	'-format' => 'nexml',
	'-phylo'  => $proj,
);