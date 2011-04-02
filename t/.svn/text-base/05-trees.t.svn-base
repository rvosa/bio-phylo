# $Id$
use strict;
use Bio::Phylo::Util::CONSTANT 'looks_like_instance';
use Test::More 'no_plan';
use Bio::Phylo::IO qw(parse);

my $data;
while (<DATA>) {
    $data .= $_;
}

ok( 1 );

ok( my $trees = parse(
    -string => $data,
    -format => 'newick' )
);

ok( $trees->get_by_value(
    -value  => 'calc_tree_length',
    -lt => 15 )
);

ok( ! scalar @{$trees->get_by_value(
    -value => 'calc_tree_length',
    -lt => 1 )}
);

ok( $trees->get_by_value(
    -value => 'calc_tree_length',
    -le => 14 )
);

ok( $trees->get_by_value(
    -value  => 'calc_tree_length',
    -gt => 5 )
);

ok( ! scalar @{$trees->get_by_value(
    -value => 'calc_tree_length',
    -gt => 30 )}
);

ok( $trees->get_by_value(
    -value  => 'calc_tree_length',
    -ge => 14 )
);

ok( ! scalar @{$trees->get_by_value(
    -value => 'calc_tree_length',
    -ge => 30 )}
);

ok( $trees->get_by_value(
    -value => 'calc_tree_length',
    -eq => 14 )
);

eval { $trees->insert('BAD!') };
ok( looks_like_instance $@, 'Bio::Phylo::Util::Exceptions::ObjectMismatch' );
ok( $trees->_container );
ok( $trees->_type );

my $newick = <<NEWICK;
((A,B),C);
((A,C),B);
((A,B),C);
NEWICK

my $forest = parse( '-format' => 'newick', '-string' => $newick );
my $cons = $forest->make_consensus('-fraction' => 0.5);

ok( $forest->first->calc_symdiff($cons) == 0, 'simple consensus' );

my $taxa;
ok( $taxa = $forest->make_taxa );

my $nodes = $forest->first->get_nodes_for_taxa($taxa);
ok( scalar @{ $nodes } == 3 );

my $two_taxa = [ $taxa->get_by_index(0), $taxa->get_by_index(1) ];
my $two_nodes = $forest->first->get_nodes_for_taxa($two_taxa);
ok( scalar @{ $two_nodes } == 2 );

my $taxon_A = $taxa->get_by_name('A');
my $taxon_B = $taxa->get_by_name('B');
is( $forest->calc_split_frequency([$taxon_A,$taxon_B]), 2/3 );

__DATA__
((H:1,I:1):1,(G:1,(F:0.01,(E:0.3,(D:2,(C:0.1,(A:1,B:1)cherry:1):1):1):1):1):1):0;
(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B:1):1):1):1):1):1):1):0;
