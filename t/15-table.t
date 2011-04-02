# $Id: 15-table.t 1524 2010-11-25 19:24:12Z rvos $
use strict;
use Test::More 'no_plan';
use Bio::Phylo::Parsers::Table;
use Bio::Phylo::IO qw(parse unparse);
Bio::Phylo->VERBOSE( -level => 0 );
my $string = do { local $/; <DATA> };
my $matrix;
ok(
    $matrix = parse(
        '-format' => 'table',
        '-type'   => 'standard',
        '-string' => $string,
      )->[0],
    '2 parse table'
);
ok( $matrix->get_type =~ /^standard$/i );
ok( $matrix->get_ntax == 10 );
ok( $matrix->get_nchar == 3 );
my $string1 = 'taxon_1,1,1,2|taxon_2,2,1,2|taxon_3,2,2,2|taxon_4,1,2,1';
ok(
    $matrix = parse(
        '-format'   => 'table',
        '-type'     => 'standard',
        '-fieldsep' => ',',
        '-linesep'  => '|',
        '-string'   => $string1,
      )->[0],
    '2 parse table'
);
__DATA__
taxon_1	1	1	2
taxon_2	2	1	2
taxon_3	2	2	2
taxon_4	1	2	1
taxon_5	2	1	1
taxon_6	1	1	2
taxon_7	1	2	2
taxon_8	1	2	1
taxon_9	1	1	1
taxon_10	2	1	1
