use Test::More;
BEGIN {
    eval { require Bio::TreeIO };
    if ( $@ ) {
        plan 'skip_all' => "BioPerl not installed";
    }
    else {
    	Test::More->import('no_plan');
    }
}

# Read tree in BioPerl
use Bio::TreeIO;
my $bptreeio = Bio::TreeIO->new(
    '-format' => 'newick',
    '-fh'     => \*DATA
);
my $bptree = $bptreeio->next_tree;

# Convert BioPerl tree object to Phylo tree object
use Bio::Phylo::Forest::Tree;
my $phylo_tree;
eval { $phylo_tree = Bio::Phylo::Forest::Tree->new_from_bioperl($bptree) };
ok( ! $@, "conversion from BioPerl to Bio::Phylo threw no exceptions" );

# Now compare the strings
use Bio::Phylo::IO 'parse';
my $tree = parse( 
    '-format' => 'newick', 
    '-string' => '(((A:5,B:5)z:2,(C:4,D:4)y:1)x:3,E:10);'
)->first;
ok( $tree->calc_symdiff( $phylo_tree ) == 0, "converted and native trees are identical" );

# Some tree data
__DATA__
(((A:5,B:5)z:2,(C:4,D:4)y:1)x:3,E:10);