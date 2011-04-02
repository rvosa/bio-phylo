use Test::More;
BEGIN {
    eval { require Math::CDF };
    if ( $@ ) {
        plan 'skip_all' => 'Math::CDF not installed';
    }
    else {
    	Test::More->import('no_plan');
    }
}
use strict;
use warnings;
use Bio::Phylo::Util::CONSTANT qw(
    looks_like_object
    looks_like_instance
    _TREE_
    _FOREST_
);

# Test to see if we can require the module we're exercising
require_ok('Bio::Phylo::EvolutionaryModels');

# For convenience we import the sample routine so we can write sample(...) 
# instead of Bio::Phylo::EvolutionaryModels::sample(...).
Bio::Phylo::EvolutionaryModels->import('sample');

# Example A
# Simulate a single tree with ten species from the constant rate birth model
# with parameter 0.5
{
    my $tree = Bio::Phylo::EvolutionaryModels::constant_rate_birth(
        'birth_rate' => .5,
        'tree_size'  => 10
    );
    ok(looks_like_object($tree,_TREE_), "object is a tree");
    my $tipcount = scalar @{ $tree->get_terminals };
    is(10,$tipcount, "crb tree has ${tipcount}==10 tips");
    ok($tree->is_ultrametric(0.01), 'crb tree is ultrametric');
}

# Example B
# Sample 5 trees with ten species from the constant rate birth model using
# the b algorithm
{
    my ( $sample, $stats ) = sample(
        'sample_size'       => 5,
        'tree_size'         => 10,
        'algorithm'         => 'b',
        'algorithm_options' => { 'rate' => 1 },
        'model'             => \&Bio::Phylo::EvolutionaryModels::constant_rate_birth,
        'model_options'     => { 'birth_rate' => .5 }
    );
    
    ok( looks_like_instance($sample,'ARRAY'), "b sample is an array" );
    is( scalar @{ $sample }, 5, "b sample has 5 trees" );
    for my $t ( @{ $sample } ) {
        is( scalar @{ $t->get_terminals }, 10, "b tree has 10 tips" ); 
    }
    for my $t ( @{ $sample } ) {
	ok( $t->is_ultrametric(0.01), "b tree is ultrametric" );
    }
}

# Example C
# Sample 5 trees with ten species from the constant rate birth and death model
# using the bd algorithm and two threads (useful for dual core processors)
# NB: we must specify an nstar here, an appropriate choice will depend on the
# birth_rate and death_rate we are giving the model
{
    my ( $forest, $stats ) = sample(
        'sample_size'       => 5,
        'tree_size'         => 10,
        'threads'           => 1,
        'algorithm'         => 'bd',
	'output_format'     => 'forest',
        'algorithm_options' => { 'rate'       => 1, 'nstar'      => 30 },
        'model_options'     => { 'birth_rate' => 1, 'death_rate' => .8 },    
        'model' => \&Bio::Phylo::EvolutionaryModels::constant_rate_birth_death,
    );
    ok( looks_like_object($forest,_FOREST_), "bd sample is a forest" ); 
    my $sample = $forest->get_entities;
    is( scalar @{ $sample }, 5, "bd sample has 5 trees" );
    SKIP : {
	skip "bd trees have too many tips", scalar @{ $sample };
	for my $t ( @{ $sample } ) {
	    my $count = scalar @{ $t->get_terminals };
	    is( $count, 10, "bd tree has ${count}==10 tips" );
	}
    };
    SKIP : {
	skip "bd trees aren't ultrametric", scalar @{ $sample };
	for my $t ( @{ $sample } ) {
	    ok( $t->is_ultrametric, "bd tree is ultrametric");
	}
    };
}

# Example D
# Sample 5 trees with ten species from the constant rate birth and death model
# using incomplete taxon sampling
#
# sampling_probability is set so that the true tree has 10 species with 50%
# probability, 11 species with 30% probability and 12 species with 20%
# probability
#
# NB: we must specify an mstar here this will depend on the model parameters
# and the incomplete taxon sampling parameters
{
    my $algorithm_options = {
        'rate'  => 1, 
        'nstar' => 30, 
        'mstar' => 12,     
        'sampling_probability' => [ .5, .3, .2 ],
    };
                       
    my ( $forest, $stats ) = sample(
        'sample_size'       => 5,
        'tree_size'         => 10,
        'algorithm'         => 'incomplete_sampling_bd',
        'algorithm_options' => $algorithm_options,
	'output_format'     => 'forest',
        'model_options'     => { 'birth_rate' => 1, 'death_rate' => .8 },
        'model' => \&Bio::Phylo::EvolutionaryModels::constant_rate_birth_death,    
    );
    ok( looks_like_object( $forest, _FOREST_ ), "isb sample is forest" );
    my $sample = $forest->get_entities;
    is( scalar @{ $sample }, 5, "isb sample has 5 trees" );
    SKIP : {
	skip "isb trees have too many tips", scalar @{ $sample };
        for my $t ( @{ $sample } ) {
            my $count = scalar @{ $t->get_terminals };
            is( $count, 10, "isb tree has ${count}==10 tips" );
        }
    };
    SKIP : {
	skip "isb trees aren't ultrametric", scalar @{ $sample };
	for my $t ( @{ $sample } ) {
	    ok( $t->is_ultrametric, "isb tree is ultrametric" );
	}
    };
}

# Example E
# Sample 5 trees with ten species from a Yule model using the memoryless_b
# algorithm
#
# First we define the random function for the shortest pendant edge for a Yule
# model
{
    my $random_pendant_function = sub { 
        my %options = @_;
        return -log(rand) / $options{'birth_rate'} / $options{'tree_size'};
    };
     
    # Then we produce our sample
    my ( $forest, $stats ) = sample(
        'sample_size'       => 5,
        'tree_size'         => 10,
        'algorithm'         => 'memoryless_b',
	'output_format'     => 'forest',
        'model_options'     => { 'birth_rate'   => 1 },
        'algorithm_options' => { 'pendant_dist' => $random_pendant_function },
        'model' => \&Bio::Phylo::EvolutionaryModels::constant_rate_birth,    
    );    
    ok( looks_like_object( $forest, _FOREST_ ), 'mb result is a forest' );
    my $sample = $forest->get_entities;
    is( scalar @{ $sample }, 5, "mb sample has 5 trees" );
    for my $t ( @{ $sample } ) {
        is( scalar @{ $t->get_terminals }, 10, "mb tree has 10 tips" );
    }
    for my $t ( @{ $sample } ) {
	ok( $t->is_ultrametric(0.01), "mb tree is ultrametric" );
    }
}

# Example F
# Sample 5 trees with ten species from a constant birth death rate model using
# the constant_rate_bd algorithm
{
    my ( $forest ) = sample(
        'sample_size'   => 5,
        'tree_size'     => 10,
	'output_format' => 'forest',
        'algorithm'     => 'constant_rate_bd',
        'model_options' => { 'birth_rate' => 1, 'death_rate' => .8 }
    );
    ok( looks_like_object( $forest, _FOREST_ ), 'crb sample is forest' );
    my $sample = $forest->get_entities;
    is( scalar @{ $sample }, 5, "crb sample has 5 trees" );
    for my $t ( @{ $sample } ) {
        is( scalar @{ $t->get_terminals }, 10, "crb tree has 10 tips" );
    }
    for my $t ( @{ $sample } ) {
	ok( $t->is_ultrametric(0.01), 'crb tree is ultrametric' );
    }
}