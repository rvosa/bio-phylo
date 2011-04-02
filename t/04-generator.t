# $Id: 04-generator.t 1583 2010-12-15 23:24:15Z rvos $
use Test::More;

BEGIN {
    eval { require Math::Random };
    if ($@) {
        plan 'skip_all' => 'Math::Random not installed';
    }
    else {
        Test::More->import('no_plan');
    }
}
use strict;
use Bio::Phylo;
require Bio::Phylo::Generator;
ok( my $gen = Bio::Phylo::Generator->new, 'init' );
my %args = ( '-tips' => 20, '-trees' => 1 );
{
    my $forest = $gen->gen_rand_pure_birth( '-model' => 'yule', %args );
    basic_tree_stats( $forest, @args{qw(-trees -tips)},
        'random pure birth yule' );
}
{
    my $forest = $gen->gen_rand_pure_birth( '-model' => 'hey', %args );
    basic_tree_stats( $forest, @args{qw(-trees -tips)},
        'random pure birth hey' );
}
{
    my $forest = $gen->gen_rand_birth_death( '-killrate' => 0.2, %args );
    basic_tree_stats( $forest, @args{qw(-trees -tips)}, 'random birth death' );
}
{
    my $forest = $gen->gen_exp_pure_birth( '-model' => 'yule', %args );
    basic_tree_stats( $forest, @args{qw(-trees -tips)},
        'expected pure birth yule' );
    for my $tree ( @{ $forest->get_entities } ) {
        my $times = $tree->calc_waiting_times;
        for my $i ( 0 .. $#{$times} ) {
            my $bt = $times->[$i]->[1];
            my $exp = $i ? 1 / ( $i + 1 ) : 0;
            if ($exp) {
                my $deviation = abs( $bt - $exp ) / $exp;
                ok( $deviation < 0.01, 'expected yule waiting time' );
            }
        }
    }
}
{
    my $forest = $gen->gen_exp_pure_birth( '-model' => 'hey', %args );
    basic_tree_stats( $forest, @args{qw(-trees -tips)},
        'expected pure birth hey' );
    for my $tree ( @{ $forest->get_entities } ) {
        my $times = $tree->calc_waiting_times;
        for my $i ( 0 .. $#{$times} ) {
            my $bt = $times->[$i]->[1];
            my $exp = $i ? 1 / ( $i * ( $i + 1 ) ) : 0;
            is(
                sprintf( "%.2f", $bt ),
                sprintf( "%.2f", $exp ),
                'expected hey waiting time'
            );
        }
    }
}
{
    my $forest = $gen->gen_coalescent(%args);
    basic_tree_stats( $forest, @args{qw(-trees -tips)}, 'coalescent' );
}
{
    my $forest = $gen->gen_equiprobable(%args);
    basic_tree_stats( $forest, @args{qw(-trees -tips)}, 'equiprobable' );
}
{
    my $forest = $gen->gen_balanced( '-trees' => 1, '-tips' => 16 );
    is( $forest->first->calc_imbalance, 0, 'balanced topology' );
    basic_tree_stats( $forest, 1, 16, 'balanced' );
}
{
    my $forest = $gen->gen_ladder( '-trees' => 1, '-tips' => 16 );
    is( $forest->first->calc_imbalance, 1, 'ladder topology' );
    basic_tree_stats( $forest, 1, 16, 'ladder' );
}
eval { $gen->gen_exp_pure_birth( -model => 'dummy' ); };
isa_ok( $@, 'Bio::Phylo::Util::Exceptions::BadFormat', 'exception' );
eval { $gen->gen_rand_pure_birth( -model => 'dummy' ); };
isa_ok( $@, 'Bio::Phylo::Util::Exceptions::BadFormat', 'exception' );

sub basic_tree_stats {
    my ( $forest, $ntrees, $ntips, $msg ) = @_;
    my @trees = @{ $forest->get_entities };
    is( scalar @trees, $ntrees, "$msg (tree count)" );
    for my $tree (@trees) {
        my $tips = $tree->get_terminals;
        is( scalar @{$tips}, $ntips, "$msg (tip count)" );
    }
}
