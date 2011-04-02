# $Id: 18-taxlist.t 1524 2010-11-25 19:24:12Z rvos $
use strict;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse';
{
    my $taxa = parse(
        '-format' => 'taxlist',
        '-handle' => \*DATA,
    )->[0];
    ok( $taxa->get_ntax == 4 );
}
{
    my $string = <<STRING;
taxon1
taxon2
taxon3
taxon4
STRING
    my $taxa = parse(
        '-format' => 'taxlist',
        '-string' => $string,
    )->[0];
    ok( $taxa->get_ntax == 4 );
}
{
    my $taxa = parse(
        '-format'   => 'taxlist',
        '-string'   => 'taxon1,taxon2,taxon3,taxon4',
        '-fieldsep' => ',',
    )->[0];
    ok( $taxa->get_ntax == 4 );
}
__DATA__
taxon1
taxon2
taxon3
taxon4
