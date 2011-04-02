use Test::More;

BEGIN {

 # PHYLOWS_ENDPOINT is probably http://8ball.sdsc.edu:6666/treebase-web/phylows/
    if ( not $ENV{'PHYLOWS_ENDPOINT'} ) {
        plan 'skip_all' => 'env var PHYLOWS_ENDPOINT not set';
    }
    else {
        Test::More->import('no_plan');
    }
}
use strict;
use warnings;
use Bio::Phylo::Factory;
my $fac    = Bio::Phylo::Factory->new;
my $url    = $ENV{'PHYLOWS_ENDPOINT'};
my $logger = $fac->create_logger;
my $client = $fac->create_client( '-url' => $url );
$logger->VERBOSE( '-level' => 0 );
my $result = $client->get_query_result(
    '-query'        => sprintf( 'tb.identifier.study="%s"', 'S2484' ),
    '-section'      => 'study',
    '-recordSchema' => 'tree',
);
ok( $result->to_xml );
