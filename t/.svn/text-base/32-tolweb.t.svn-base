use Test::More;
BEGIN {
    eval { require XML::Twig };
    if ( $@ ) {
        plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        Test::More->import('no_plan');
    }
}
use Bio::Phylo::IO 'parse';
my $string = do { local $/; <DATA> };

my $obj;
ok( $obj = parse( '-format' => 'tolweb', '-string' => $string ) );
isa_ok( $obj->[0], 'Bio::Phylo::Forest' );

my $proj;
ok( $proj = parse( '-format' => 'tolweb', '-string' => $string, '-as_project' => 1 ) );
isa_ok( $proj, 'Bio::Phylo::Project' );

__DATA__
<?xml version="1.0" standalone="yes"?>

<TREE>
  <NODE EXTINCT="0" ID="133799" CONFIDENCE="0" PHYLESIS="0" LEAF="0" HASPAGE="0" ANCESTORWITHPAGE="367" ITALICIZENAME="0" INCOMPLETESUBGROUPS="0" SHOWAUTHORITY="0" SHOWAUTHORITYCONTAINING="0" IS_NEW_COMBINATION="0" COMBINATION_DATE="null" CHILDCOUNT="2">
    <NAME></NAME>
    <DESCRIPTION></DESCRIPTION>
    <AUTHORITY></AUTHORITY>
    <NAMECOMMENT></NAMECOMMENT>
    <COMBINATION_AUTHOR></COMBINATION_AUTHOR>
    <AUTHDATE>null</AUTHDATE>
    <NODES>
      <NODE EXTINCT="0" ID="133800" CONFIDENCE="0" PHYLESIS="0" LEAF="0" HASPAGE="0" ANCESTORWITHPAGE="367" ITALICIZENAME="0" INCOMPLETESUBGROUPS="0" SHOWAUTHORITY="0" SHOWAUTHORITYCONTAINING="0" IS_NEW_COMBINATION="0" COMBINATION_DATE="null" CHILDCOUNT="2">
        <NAME></NAME>
        <DESCRIPTION></DESCRIPTION>
        <AUTHORITY></AUTHORITY>
        <NAMECOMMENT></NAMECOMMENT>
        <COMBINATION_AUTHOR></COMBINATION_AUTHOR>
        <AUTHDATE>null</AUTHDATE>
        <NODES>
          <NODE EXTINCT="0" ID="384" CONFIDENCE="0" PHYLESIS="0" LEAF="1" HASPAGE="1" ANCESTORWITHPAGE="367" ITALICIZENAME="1" INCOMPLETESUBGROUPS="0" SHOWAUTHORITY="1" SHOWAUTHORITYCONTAINING="0" IS_NEW_COMBINATION="0" COMBINATION_DATE="null" CHILDCOUNT="0">
            <NAME><![CDATA[Bembidion argenteolum]]></NAME>
            <DESCRIPTION></DESCRIPTION>
            <AUTHORITY><![CDATA[Ahrens]]></AUTHORITY>
            <NAMECOMMENT></NAMECOMMENT>
            <COMBINATION_AUTHOR></COMBINATION_AUTHOR>
            <AUTHDATE>1812</AUTHDATE>
            <OTHERNAMES>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="0" DATE="1844" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion glabriusculum]]></NAME>
                <AUTHORITY><![CDATA[Motschulsky]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="1" DATE="1926" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion trifoveolatipennis]]></NAME>
                <AUTHORITY><![CDATA[Emden]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="2" DATE="1908" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion virens]]></NAME>
                <AUTHORITY><![CDATA[Schilsky]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="3" DATE="1833" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion azureum]]></NAME>
                <AUTHORITY><![CDATA[Gebler]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="4" DATE="1843" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion chalybaeum]]></NAME>
                <AUTHORITY><![CDATA[Sturm]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
              <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="5" DATE="1899" ITALICIZENAME="1">
                <NAME><![CDATA[Bembidion amethystinum]]></NAME>
                <AUTHORITY><![CDATA[Meier]]></AUTHORITY>
                <COMMENTS></COMMENTS>
              </OTHERNAME>
            </OTHERNAMES>
          </NODE>
          <NODE EXTINCT="0" ID="385" CONFIDENCE="0" PHYLESIS="0" LEAF="1" HASPAGE="1" ANCESTORWITHPAGE="367" ITALICIZENAME="1" INCOMPLETESUBGROUPS="0" SHOWAUTHORITY="1" SHOWAUTHORITYCONTAINING="0" IS_NEW_COMBINATION="0" COMBINATION_DATE="null" CHILDCOUNT="0">
            <NAME><![CDATA[Bembidion semenovi]]></NAME>
            <DESCRIPTION></DESCRIPTION>
            <AUTHORITY><![CDATA[Lindroth]]></AUTHORITY>
            <NAMECOMMENT></NAMECOMMENT>
            <COMBINATION_AUTHOR></COMBINATION_AUTHOR>
            <AUTHDATE>1965</AUTHDATE>
          </NODE>
        </NODES>
      </NODE>
      <NODE EXTINCT="0" ID="382" CONFIDENCE="0" PHYLESIS="0" LEAF="1" HASPAGE="1" ANCESTORWITHPAGE="367" ITALICIZENAME="1" INCOMPLETESUBGROUPS="0" SHOWAUTHORITY="1" SHOWAUTHORITYCONTAINING="0" IS_NEW_COMBINATION="0" COMBINATION_DATE="null" CHILDCOUNT="0">
        <NAME><![CDATA[Bembidion alaskense]]></NAME>
        <DESCRIPTION></DESCRIPTION>
        <AUTHORITY><![CDATA[Lindroth]]></AUTHORITY>
        <NAMECOMMENT></NAMECOMMENT>
        <COMBINATION_AUTHOR></COMBINATION_AUTHOR>
        <AUTHDATE>1962</AUTHDATE>
        <OTHERNAMES>
          <OTHERNAME ISIMPORTANT="0" ISPREFERRED="0" SEQUENCE="0" DATE="1965" ITALICIZENAME="1">
            <NAME><![CDATA[Bembidion colvillense]]></NAME>
            <AUTHORITY><![CDATA[Lindroth]]></AUTHORITY>
            <COMMENTS></COMMENTS>
          </OTHERNAME>
        </OTHERNAMES>
      </NODE>
    </NODES>
  </NODE>
</TREE>