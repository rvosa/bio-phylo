# $Id: 19-svg.t 838 2009-03-04 20:47:20Z rvos $
use Test::More 'no_plan';
use strict;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Treedrawer;
use Bio::Phylo::Util::Logger ':levels';
use Bio::Phylo::Factory;
my $factory = Bio::Phylo::Factory->new;
$factory->register_class( 'tree' => 'Bio::Phylo::Forest::DrawTree' );
$factory->register_class( 'node' => 'Bio::Phylo::Forest::DrawNode' );
my $tree = parse(
    -format  => 'newick',
    -string  => do { local $/; <DATA> },
    -factory => $factory
)->first;
$tree->visit(
    sub {
        my $node = shift;
        $node->set_url( 'http://google.com/search?q=' . $node->get_id );
        my $c = sub { int rand 255 };
        $node->set_generic(
            'pie' => {
                "Eaten"     => int rand 100,
                "Not eaten" => int rand 100,
            }
        );
    }
);
my $treedrawer = Bio::Phylo::Treedrawer->new(
    -width       => 800,
    -height      => 600,
    -shape       => 'RECT',         # curvogram
    -mode        => 'PHYLO',        # phylogram
    -format      => 'Processing',
    -node_radius => 40,
);
$treedrawer->set_tree($tree);
ok( $treedrawer->draw );
__DATA__
((Galago_matschiei:3.6487,Euoticus_elegantulus:3.6487):4.86839,(Galagoides_zanzibaricus:3.57452,Galagoides_demidoff:3.57452):4.94257):0;
