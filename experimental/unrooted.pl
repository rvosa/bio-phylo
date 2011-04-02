#!/usr/bin/perl
use strict;
use warnings;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Treedrawer;

my $PI2 = 8 * atan2(1, 1);
my $td = Bio::Phylo::Treedrawer->new( 
	'-format' => 'svg', 
	'-shape'  => 'diag', 
	'-width'  => 600, 
	'-height' => 600,
	'-collapsed_clade_width' => 8,
);
$td->set_tree( parse( '-format' => 'newick', '-string' => do { local $/; <DATA> } )->first );

my $t = $td->get_tree;
my $is_clado = 0;#$t->is_cladogram;
my $tip_count = scalar @{ $t->get_terminals };
my ( $counter, $xmax, $ymax ) = ( 0, 0, 0 );
$t->visit_depth_first(
	'-pre' => sub {
		my $n = shift;
		
		# set the period for tips, which (here) is the position (fraction) on a circle that the i'th 
		# tip occupies. For example, if this is the 4th seen tip out of 8, 'period' is 0.5. We will
		# use this later to do the trigonometry for the position and angle of the node on a circle.
		# i.e. x = sin(2*pi*rad), y = cos(2*pi*rad) on a unit circle.
		if ( $n->is_terminal ) {
			my $rad = $counter / $tip_count;
			$n->set_generic( 'period' => $rad );
			$counter++;
		}
		
		# set the 'depth' field, which sets the distance from the root, either in cumulative branch
		# lengths, or in number of nodes. We later use this to multiply the trigonometric 
		# coordinates.
		if ( my $p = $n->get_parent ) {
			if ( $is_clado ) {
				$n->set_generic( 'depth' => 1 );
			}
			else {
				$n->set_generic( 'depth' => $n->get_branch_length||0 );
			}
		}
		else {
			$n->set_generic( 'depth' => 0 );		
		}
	},
	'-post' => sub {
		my $n = shift;
		
		# here we set the period for internal nodes, which we calculate by taking the average over
		# all immediate children
		if ( $n->is_internal ) {
			my $sum = 0;
			my @children = @{ $n->get_children };
			$sum += $_->get_generic('period') for @children;
			$n->set_generic( 'period' => $sum / scalar @children );
		}
		
		# here we compute the coordinates relative to 0,0 on the unit circle.
		my $x = sin($n->get_generic('period')*$PI2) * $n->get_generic('depth');
		my $y = cos($n->get_generic('period')*$PI2) * $n->get_generic('depth');
		$n->set_x( $x ); # make these coordinates relative to parent
		$n->set_y( $y );
	},
);

$t->visit_depth_first(
	'-pre' => sub {
		
		# here we translate the coordinates from their position relative to 0,0 on the
		# unit circle to coordinates relative to the parent's coordinates
		my $n = shift;
		my ( $px, $py ) = ( 0, 0 );
		if ( my $p = $n->get_parent ) {
			( $px, $py ) = ( $p->get_x, $p->get_y );
		}
		my ( $x, $y ) = ( $n->get_x + $px, $n->get_y + $py );		
		$n->set_x( $x );
		$n->set_y( $y );
	},
	'-post' => sub {
		my $n = shift;
		my ( $x, $y ) = ( $n->get_x, $n->get_y );	
		my $xpos = sqrt($x*$x);
		my $ypos = sqrt($y*$y);
		$xmax = $xpos if $xpos > $xmax;
		$ymax = $ypos if $ypos > $ymax;		
	}
);

my $xscale = $td->get_width  / ( ($xmax||1) * 2 );
my $yscale = $td->get_height / ( ($ymax||1) * 2 );
my $xplus = $td->get_width  / 2;
my $yplus = $td->get_height / 2;
$t->visit(
	sub {
		my $n = shift;
		$n->set_x( $n->get_x * $xscale + $xplus );
		$n->set_y( $n->get_y * $yscale + $yplus );		
	}
);
print $td->render;


__DATA__
((((((Galago_matschiei:3.6487,Euoticus_elegantulus:3.6487):4.86839,(Galagoides_zanzibaricus:3.57452,Galagoides_demidoff:3.57452):4.94257):0,((Otolemur_garnettii:4.24098,Otolemur_crassicaudatus:4.24098):4.27605,(Galago_alleni:5.39749,(Galago_gallarum:2.37158,(Galago_senegalensis:2.37158,Galago_moholi:2.37158):0):3.02591):3.11953):6.3e-05):12.4029,((Perodicticus_potto:4.69815,Arctocebus_calabarensis:4.69815):11.6497,(Loris_tardigradus:9.19418,(Nycticebus_pygmaeus:2.67234,Nycticebus_coucang:2.67234):6.52184):7.15369):4.57209):30.947,(Daubentonia_madagascariensis:39.4781,((((Lepilemur_mustelinus:11.204,(Lepilemur_septentrionalis:7.59107,(Lepilemur_ruficaudatus:5.02272,(Lepilemur_leucopus:3.00227,(Lepilemur_edwardsi:1.36641,Lepilemur_dorsalis:1.36641):1.63585):2.02045):2.56836):3.61297):5.96676,((Lemur_catta:6.23214,(Hapalemur_simus:5.66714,(Hapalemur_griseus:5.66714,Hapalemur_aureus:5.66714):0):0.564998):6.82367,(Varecia_variegata:11.8914,((Eulemur_rubriventer:3.06633,Eulemur_mongoz:3.06633):3.30316,(Eulemur_coronatus:3.75439,(Eulemur_macaco:3.67779,Eulemur_fulvus:3.67779):0.076596):2.6151):5.52195):1.16437):4.11499):4.87015,(Avahi_laniger:13.6107,(Indri_indri:7.43976,(Propithecus_diadema:5.87211,(Propithecus_verreauxi:1.53414,Propithecus_tattersalli:1.53414):4.33796):1.56766):6.17095):8.43024):5.47858,(Phaner_furcifer:17.0297,((Allocebus_trichotis:7.06198,(Microcebus_coquereli:4.09388,(Microcebus_rufus:2.72926,Microcebus_murinus:2.72926):1.36463):2.9681):4.40131,(Cheirogaleus_medius:9.40743,Cheirogaleus_major:9.40743):2.05586):5.56638):10.4899):11.9586):12.3889):13.2309,(((Tarsius_spectrum:15.9897,Tarsius_pumilus:15.9897):22.2262,(Tarsius_syrichta:16.0795,Tarsius_bancanus:16.0795):22.1364):24.3931,(((((((Chiropotes_satanas:3.67922,Chiropotes_albinasus:3.67922):4.4452,(Cacajao_melanocephalus:3.70937,Cacajao_calvus:3.70937):4.41505):3.76178,(Pithecia_pithecia:10.2411,(Pithecia_irrorata:6.55105,(Pithecia_aequatorialis:3.7806,(Pithecia_monachus:1.7649,Pithecia_albicans:1.7649):2.0157):2.77045):3.69002):1.64513):9.08215,(Callicebus_torquatus:16.4794,((Callicebus_modestus:7.32728,(Callicebus_donacophilus:3.08081,(Callicebus_olallae:3.08081,Callicebus_oenanthe:3.08081):0):4.24647):5.97682,(Callicebus_personatus:10.2952,((Callicebus_dubius:4.72722,(Callicebus_cupreus:1.99105,Callicebus_caligatus:1.99105):2.73618):3.26611,((Callicebus_hoffmannsi:2.35725,Callicebus_brunneus:2.35725):2.97278,(Callicebus_moloch:2.32718,Callicebus_cinerascens:2.32718):3.00284):2.66331):2.30191):3.00885):3.17531):4.48894):4.35162,((Alouatta_palliata:12.7369,(Alouatta_caraya:6.92023,(Alouatta_pigra:5.71088,(Alouatta_fusca:3.41788,(Alouatta_seniculus:1.61131,Alouatta_belzebul:1.61131):1.80657):2.293):1.20935):5.81666):7.95138,(((Ateles_paniscus:4.7004,(Ateles_marginatus:2.8909,Ateles_chamek:2.8909):1.8095):0,(Ateles_belzebuth:2.04664,(Ateles_geoffroyi:1.2092,Ateles_fusciceps:1.2092):0.837439):2.65376):6.59583,(Brachyteles_arachnoides:9.03194,(Lagothrix_lagotricha:2.91317,Lagothrix_flavicauda:2.91317):6.11876):2.26429):9.39204):4.6317):4.83535,((((Cebus_olivaceus:3.9671,Cebus_apella:3.9671):3.30047,(Cebus_capucinus:0.138835,Cebus_albifrons:0.138835):7.12873):15.9199,(Saimiri_boliviensis:8.42997,(Saimiri_vanzolinii:6.82962,(Saimiri_sciureus:3.94673,(Saimiri_ustus:1.75833,Saimiri_oerstedii:1.75833):2.1884):2.88289):1.60036):14.7575):2.49736,((Aotus_lemurinus:15.7892,((Aotus_vociferans:4.52261,Aotus_brumbacki:4.52261):7.23237,(Aotus_nancymaae:8.67574,(Aotus_miconax:6.28365,(Aotus_infulatus:4.15512,(Aotus_nigriceps:2.62541,(Aotus_trivirgatus:1.23196,Aotus_azarai:1.23196):1.39346):1.52971):2.12853):2.39208):3.07924):4.0342):6.24331,((Callimico_goeldii:18.3758,((Callithrix_pygmaea:3.71312,(Callithrix_humeralifera:2.07107,Callithrix_argentata:2.07107):1.64205):7.64608,((Callithrix_flaviceps:3.42958,Callithrix_aurita:3.42958):7.77439,((Callithrix_kuhlii:0.255971,Callithrix_geoffroyi:0.255971):0.255971,(Callithrix_penicillata:0.255971,Callithrix_jacchus:0.255971):0.255971):10.692):0.15523):7.01664):0.61583,((Leontopithecus_chrysomela:7.68227,(Leontopithecus_rosalia:3.84113,Leontopithecus_chrysopygus:3.84113):3.84113):7.97001,(((Saguinus_oedipus:3.27237,Saguinus_geoffroyi:3.27237):4.60936,(Saguinus_midas:3.31401,Saguinus_bicolor:3.31401):4.56772):4.80046,(Saguinus_leucopus:9.81891,((Saguinus_imperator:4.38323,(Saguinus_mystax:1.96062,Saguinus_labiatus:1.96062):2.42262):3.29356,(Saguinus_inustus:5.07181,(Saguinus_nigricollis:3.03334,(Saguinus_tripartitus:1.37792,Saguinus_fuscicollis:1.37792):1.65542):2.03846):2.60499):2.14212):2.86327):2.9701):3.33939):3.04082):3.65237):4.47046):21.0781,(((Pongo_pygmaeus:15.8431,(Gorilla_gorilla:6.41388,(Homo_sapiens:5.06909,(Pan_troglodytes:1.96134,Pan_paniscus:1.96134):3.10775):1.34478):9.42917):3.79517,((Hylobates_hoolock:4.01629,(Hylobates_pileatus:3.54814,((Hylobates_muelleri:0.888868,Hylobates_klossii:0.888868):2.65928,(Hylobates_moloch:3.52014,(Hylobates_lar:3.10557,Hylobates_agilis:3.10557):0.414571):0.028005):0):0.468146):1.8623,(Hylobates_syndactylus:4.01629,(Hylobates_gabriellae:1.80439,(Hylobates_leucogenys:0.792181,Hylobates_concolor:0.792181):1.01221):2.2119):1.8623):13.7596):12.7722,(((((((Trachypithecus_geei:5.13229,(Trachypithecus_auratus:3.73589,(Trachypithecus_francoisi:2.9008,((Trachypithecus_phayrei:0.696042,Trachypithecus_obscurus:0.696042):0.105296,(Trachypithecus_pileatus:0.801338,Trachypithecus_cristatus:0.801338):0):2.09946):0.835097):1.39639):1.8002,(Semnopithecus_entellus:6.93249,(Trachypithecus_vetulus:6.93249,Trachypithecus_johnii:6.93249):0):0):0,(Presbytis_potenziani:3.80452,(Presbytis_comata:1.59536,(Presbytis_frontata:1.59536,(Presbytis_rubicunda:1.59536,Presbytis_melalophos:1.59536):0):0):2.20916):3.12797):1.94541,(Pygathrix_nemaeus:8.00146,(Pygathrix_avunculus:3.87341,(Pygathrix_roxellana:2.60449,(Pygathrix_brelichi:1.03551,Pygathrix_bieti:1.03551):1.56897):1.26892):4.12805):0.876439):0.018766,(Nasalis_larvatus:3.48278,Nasalis_concolor:3.48278):5.41388):4.7058,((Procolobus_verus:5.25647,(Procolobus_pennantii:2.23774,Procolobus_badius:2.23774):3.01873):6.70346,(Colobus_satanas:6.03035,(Colobus_angolensis:3.48634,(Colobus_polykomos:0.800086,Colobus_guereza:0.800086):2.68625):2.54401):5.92958):1.64253):4.72766,(((((Mandrillus_sphinx:1.95826,Mandrillus_leucophaeus:1.95826):3.48489,(Cercocebus_torquatus:2.31318,Cercocebus_galeritus:2.31318):3.12998):1.27118,(Lophocebus_albigena:2.23338,(Theropithecus_gelada:1.5475,Papio_hamadryas:1.5475):0.685872):4.48096):2.51682,(Macaca_sylvanus:7.48375,((((Macaca_tonkeana:0.13504,Macaca_maura:0.13504):2.51899,(Macaca_ochreata:1.64531,Macaca_nigra:1.64531):1.00871):0.928615,(Macaca_silenus:2.25042,Macaca_nemestrina:2.25042):1.33223):2.6771,((Macaca_arctoides:2.80067,((Macaca_radiata:0.70926,Macaca_assamensis:0.70926):1.00024,(Macaca_thibetana:1.04751,Macaca_sinica:1.04751):0.661986):1.09117):1.63327,(Macaca_fascicularis:2.2216,(Macaca_fuscata:0.908084,(Macaca_mulatta:0.27622,Macaca_cyclopis:0.27622):0.631864):1.31352):2.21233):1.82581):1.22401):1.74741):2.02797,(Allenopithecus_nigroviridis:8.29204,(Miopithecus_talapoin:6.75124,((Erythrocebus_patas:5.17992,Chlorocebus_aethiops:5.17992):0.544109,((Cercopithecus_solatus:0.839612,(Cercopithecus_preussi:8.6e-05,Cercopithecus_lhoesti:8.6e-05):0.839526):4.08135,(Cercopithecus_hamlyni:4.22004,((Cercopithecus_neglectus:2.5642,((Cercopithecus_mona:0.789489,Cercopithecus_campbelli:0.789489):0.459721,(Cercopithecus_wolfi:0.769316,Cercopithecus_pogonias:0.769316):0.479894):1.31499):1.07305,((((Cercopithecus_erythrotis:1.04034,(Cercopithecus_cephus:0.490956,Cercopithecus_ascanius:0.490956):0.549383):0.664222,(Cercopithecus_petaurista:0.760628,Cercopithecus_erythrogaster:0.760628):0.943933):0.627724,(Cercopithecus_nictitans:0.96245,Cercopithecus_mitis:0.96245):1.36984):0.624653,(Cercopithecus_dryas:1.23689,Cercopithecus_diana:1.23689):1.72005):0.680311):0.582791):0.700924):0.803068):1.0272):1.54081):2.96708):7.071):14.0803):18.8231):11.3755):2.48889);