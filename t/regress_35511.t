use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger;
my $logger = Bio::Phylo::Util::Logger->new;
$logger->VERBOSE( '-level' => 0 );
my $newick = <<NEWICK;
((A,B),(C,D));
NEWICK
my @tips = qw(A B C D);
my $tree = parse( '-format' => 'newick', '-string' => $newick )->first;
for my $tipname (@tips) {
    eval { $tree->prune_tips( [$tipname] ) };
    ok( !$@ );
}
ok( scalar @{ $tree->get_entities } == 0 );
