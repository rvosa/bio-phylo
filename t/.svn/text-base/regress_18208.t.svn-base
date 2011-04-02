use strict;
use Test::More tests => 9;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::Logger;

my $logger = Bio::Phylo::Util::Logger->new;
$logger->VERBOSE( -level => 0 );
my $tree;
my @tips = (
    "Methanococcus_voltae",
    "'Pyrococcus furiosus (includes Pyrococcus woesei)'",
    "Pyrococcus_abyssi",
    "Sulfolobus_solfataricus",
    "Sulfolobus_tokodaii",
    "Aeropyrum_pernix",
    "Desulfuroccus_amylolyticus",
    "'Methanococcus jannaschii (aka Methanocaldococcus jannaschii)'",
);

ok( $tree = parse(
        '-format' => 'newick',
        '-string' => do { local $/; <DATA> }
    )->first, '1 parse string' );

for my $tip ( @tips ) {
    my $result = $tree->get_by_regular_expression(
        '-value' => 'get_name',
        '-match' => qr/^\Q$tip\E$/,
    );
    ok( scalar @{ $result } == 1, "found $tip" );
}


__DATA__
[ lh=-4464.484953 ](Methanococcus_voltae:0.32692,(('Pyrococcus furiosus (includes Pyrococcus woesei)':0.05887,Pyrococcus_abyssi:0.03869)100:0.36861,
(((Sulfolobus_solfataricus:0.08344,Sulfolobus_tokodaii:0.10668)100:0.15268,Aeropyrum_pernix:0.20003)
100:0.09351,Desulfuroccus_amylolyticus:0.18345)100:0.28706)100:0.41157,'Methanococcus jannaschii (aka Methanocaldococcus jannaschii)':0.00001);
