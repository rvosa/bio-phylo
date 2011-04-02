# $Id: 00-load.t 838 2009-03-04 20:47:20Z rvos $
use Test::More tests => 1;

BEGIN {
    use_ok('Bio::Phylo');
}
diag("Testing Bio::Phylo $Bio::Phylo::VERSION, Perl $]");
