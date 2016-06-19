#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO 'parse_tree';

my $fig = <<FIG;
#nexus
begin trees;
tree Tree3 = [&U] (s2:0.6,((s43:0.2,s41:0.2,s44:0.2)[&name="C_5",label="i12"]:0.2,s23:0.4,s63:0.4,s84:0.4,s74:0.4,s83:0.4,s75:0.4,s87:0.4,s76:0.4,s86:0.4,s42:0.4,s11:0.4,s46:0.4,s103:0.4,s55:0.4,s97:0.4,s49:0.4,s39:0.4,(s68:0.2,s66:0.2,s71:0.2)[&name="C_1",label="i62"]:0.2,s6:0.4,s47:0.4,(s25:0.2,s30:0.2)[&name="C_11",label="i61"]:0.2,s45:0.4,s16:0.4,(s26:0.2,s32:0.2,s27:0.2,s29:0.2)[&name="C_13",label="i52"]:0.2,s92:0.4,(s8:0.2,s4:0.2,s5:0.2)[&name="C_0",label="i57"]:0.2,s82:0.4,s81:0.4,s85:0.4,s50:0.4,(s52:0.2,s53:0.2)[&name="C_19",label="i65"]:0.2,s7:0.4,(s54:0.2,s56:0.2)[&name="C_17",label="i88"]:0.2,s10:0.4,s31:0.4,s3:0.4,s24:0.4,s38:0.4,(s61:0.2,s62:0.2,s57:0.2,s59:0.2,s58:0.2,s60:0.2)[&name="MSRSG_SUPERFAMILY",label="i83"]:0.2,s17:0.4,s104:0.4,s9:0.4,s101:0.4,s33:0.4,s79:0.4,s80:0.4,s77:0.4,s78:0.4,s21:0.4,(s36:0.2,s35:0.2,s40:0.2)[&name="C_3",label="i96"]:0.2,(s64:0.2,s67:0.2,s69:0.2,s65:0.2,s70:0.2)[&name="MKFLL_SUPERFAMILY",label="i99"]:0.2,s98:0.4,s14:0.4,(s19:0.2,s22:0.2,s18:0.2,s20:0.2)[&name="T_SUPERFAMILY",label="i91"]:0.2,s34:0.4,s37:0.4,s13:0.4,s15:0.4,s12:0.4,(s72:0.2,s73:0.2)[&name="C_12",label="i38"]:0.2,(s96:0.2,s99:0.2,s100:0.2,s102:0.2)[&name="C_18",label="i34"]:0.2,s51:0.4,(s93:0.2,s88:0.2,s90:0.2)[&name="C_15",label="i27"]:0.2,(s89:0.2,s94:0.2,s91:0.2,s95:0.2)[&name="CONKUNIZIN",label="i24"]:0.2,s28:0.4,s48:0.4)[&label="i2"]:0.2,s1:0.6)[&label="i1"];
end;
FIG

my $tree = parse_tree(
	'-string' => $fig,
	'-format' => 'figtree',
);

ok( $tree->get_root->get_meta_object('fig:label') eq '"i1"' );