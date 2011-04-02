# $Id: 01-phylo.t 1237 2010-03-02 23:27:06Z rvos $
use strict;

#use warnings;
use Test::More tests => 6;
use Bio::Phylo;
my $data;
while (<DATA>) {
    $data .= $_;
}
ok( my $phylo = new Bio::Phylo, '1 init' );
ok( !Bio::Phylo->VERBOSE( -level => 0 ), '2 set terse' );
ok( $Bio::Phylo::VERSION, '3 version number' );
ok( $phylo->CITATION,     '4 citation' );
my $logger = $phylo->get_logger;
ok( $logger->set_listeners( sub { } ), '5 set listener' );
eval { $logger->set_listeners('foo') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadArgs') );
__DATA__
(H:1,(G:1,(F:1,(E:1,(D:1,(C:1,(A:1,B:1):1):1):1):1):1):1):0;
(H:1,(G:1,(F:1,((C:1,(A:1,B:1):1):1,(D:1,E:1):1):1):1):1):0;
