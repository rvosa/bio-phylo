use strict;
use warnings;
use File::Spec;
use Test::More;
use English qw'no_match_vars';
if ( not $ENV{'TEST_AUTHOR'} ) {
    my $msg = 'env var TEST_AUTHOR not set';
    plan( 'skip_all' => $msg );
}
eval { require Test::Perl::Critic; };
if ($EVAL_ERROR) {
    my $msg = 'Test::Perl::Critic required to criticise code';
    plan( 'skip_all' => $msg );
}
my $rcfile = File::Spec->catfile( 't', 'perlcriticrc' );
Test::Perl::Critic->import( '-profile' => $rcfile );
Test::Perl::Critic::all_critic_ok();
