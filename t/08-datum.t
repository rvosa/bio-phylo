# $Id: 08-datum.t 838 2009-03-04 20:47:20Z rvos $
use strict;

#use warnings;
use Test::More tests => 37;
use Bio::Phylo::Matrices::Datum;
use Bio::Phylo::Taxa::Taxon;
use Bio::Phylo::Forest;
my $taxon = Bio::Phylo::Taxa::Taxon->new;
ok( my $datum = new Bio::Phylo::Matrices::Datum, '1 initialize' );
$datum->VERBOSE( -level => 0 );

# the name method
eval { $datum->set_name(':') };
ok( $datum->get_name eq ':', '2 bad name' );
ok( $datum->set_name('OK'), '3 good name' );
ok( $datum->get_name,       '4 retrieve name' );

# the taxon method
eval { $datum->set_taxon('BAD!') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::ObjectMismatch'), '5 bad node ref' );
eval { $datum->set_taxon( new Bio::Phylo::Forest ) };
ok( $@->isa('Bio::Phylo::Util::Exceptions::ObjectMismatch'), '6 bad node ref' );
ok( $datum->set_taxon($taxon), '7 good node ref' );
ok( $datum->get_taxon,         '8 retrieve node ref' );

# the desc method
ok( $datum->set_desc('OK'), '9 set desc' );
ok( $datum->get_desc,       '10 get desc' );

# the weight method
eval { $datum->set_weight('BAD!') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadNumber'), '11 bad weight' );
ok( $datum->set_weight(1),                              '12 good weight' );
ok( $datum->get_weight,                                 '13 retrieve weight' );

# char w/o type
eval { $datum->set_char('A') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadFormat'),
    '14 char without type' );

# the type method
eval { $datum->set_type('BAD!') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadFormat'), '15 bad type' );
ok( $datum->set_type('DNA'),                            '16 good type' );
ok( $datum->get_type,                                   '17 retrieve type' );

# testing char types
$datum->set_type('DNA');
ok( $datum->set_char('A'), '18 good DNA' );
eval { $datum->set_char('I') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '19 bad DNA' );
$datum->set_type('RNA');
ok( $datum->set_char('A'), '20 good RNA' );
eval { $datum->set_char('I') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '21 bad RNA' );
$datum->set_type('STANDARD');
ok( $datum->set_char('1'), '22 good STANDARD' );
eval { $datum->set_char('B') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '23 bad STANDARD' );
$datum->set_type('PROTEIN');
ok( $datum->set_char('A'), '24 good PROTEIN' );
eval { $datum->set_char('J') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '25 bad PROTEIN' );
$datum->set_type('NUCLEOTIDE');
ok( $datum->set_char('A'), '26 good NUCLEOTIDE' );
eval { $datum->set_char('I') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '27 bad NUCLEOTIDE' );
$datum->set_type('CONTINUOUS');
ok( $datum->set_char('-1.43345e+34'), '28 good CONTINUOUS' );
eval { $datum->set_char('B') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadString'), '29 bad CONTINUOUS' );
ok( $datum->get_char, '30 retrieve character' );

# the position method
eval { $datum->set_position('BAD!') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::BadNumber'), '31 bad pos' );
ok( $datum->set_position(1),                            '32 good pos' );
ok( $datum->get_position,                               '33 retrieve pos' );

# the get method
eval { $datum->get('frobnicate') };
ok( $@->isa('Bio::Phylo::Util::Exceptions::UnknownMethod'), '34 bad get' );
ok( $datum->get('get_type'),                                '35 good get' );
ok( $datum->_container,                                     '36 container' );
ok( $datum->_type, '37 container type' );
