#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Bio::Phylo::IO qw'parse unparse';
use Bio::Phylo::Util::Logger ':levels';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

my $project = parse(
	'-format' => 'figtree',
	'-handle' => \*DATA,
	'-as_project' => 1,
);
my @nodes = @{ $project->get_items(_NODE_) };
isa_ok( $project, 'Bio::Phylo::Project' );

# check if the tip labels were parsed correctly
{
	my %tips = map { $_ => 1 } qw(
		Rheodytes_leukops35
		'Elusor_macrurus.mtg'
		Emydura_macquarii
		Emydura_victoriae26
		Emydura_subglobosa61
		Emydura_worrelli
		Emydura_tanybaraga24
		Myuchelys_belli
		'Myuchelys_latisternum.mtg'
		Myuchelys_georgesi
		Elseya_albagula
		Elseya_branderhorsti17
		'Elseya_dentata.mtg'
		Elseya_novaeguineae_ENG_44
		Elseya_novaeguineae_ENG_45
		Elseya_novaeguineae_ENG_56
		Elseya_irwini
		Elseya_lavarackorum
	);	
	my $tips = 0;
	for my $n ( @nodes ) {				
		if ( $n->is_terminal ) {
			ok( $tips{$n->get_name}, "seen ".$n->get_name );
			$tips++;
		}
	}	
	ok( $tips == scalar keys %tips, "seen all tips" );
}

# check if the semantic annotations on tips are numerically correct
{
	my ($tip) = grep { $_->get_name eq 'Rheodytes_leukops35' } @nodes;
	my %exp = (
		'rate_range_min'     => 6.6550818320187645E-6,
		'rate_range_max'     => 3.960232740601061E-4,
		'height_95_HPD_min'  => 0.0,
		'height_95_HPD_max'  => 1.3002932064409833E-11,
		'length_range_min'   => 17.31209330178,
		'length_range_max'   => 74.13411454879,
		'height_median'      => 5.9969806898152456E-12,
		'length_95_HPD_min'  => 33.20550349826,
		'length_95_HPD_max'  => 56.91609759285,
		'height'             => 5.890988898895368E-12,
		'rate'               => 8.568983696811668E-5,
		'height_range_min'   => 0.0,
		'height_range_max'   => 2.3007373783912044E-11,
		'rate_median'        => 7.824099697386572E-5,
		'length'             => 45.30304838469565,
		'length_median'      => 45.6958945488,
		'rate_95_HPD_min'    => 1.4711122976004055E-5,
		'rate_95_HPD_max'    => 1.7022936607067858E-4,		
	);
	for my $key ( keys %exp ) {
		my $obs = $tip->get_meta_object( 'fig:' . $key );
		ok( $obs == $exp{$key}, "$key: $obs == $exp{$key}" );
	}
}

# check if the semantic annotations on nodes are numerically correct
{
	my ($node) = grep { $_->get_name eq 'testnode' } @nodes;
	my %exp = (
		'height_95_HPD_min' => 33.205503498260995,
		'height_95_HPD_max' => 56.916097592862,
		'length_range_min'  => 0.003196191310465,
		'length_range_max'  => 38.95629186913,
		'length_95_HPD_min' => 0.01269239072315,
		'length_95_HPD_max' => 21.71438182055,
		'height_range_min'  => 17.312093301779996,
		'height_range_max'  => 74.134114548793,
		'rate_95_HPD_min'   => 8.680575467146931E-9,
		'rate_95_HPD_max'   => 1.7176073055922414E-4,
		'rate_range_min'    => 8.680575467146931E-9,
		'rate_range_max'    => 0.007487588613295,
		'height_median'     => 45.6958945488,
		'rate'              => 5.005783458213507E-5,
		'height'            => 45.30304838470156,
		'posterior'         => 1.0,
		'rate_median'       => 2.4371535825758798E-5,
		'length'            => 11.147755764354484,
		'length_median'     => 10.643015261725001
	);
	for my $key ( keys %exp ) {
		my $obs = $node->get_meta_object( 'fig:' . $key );
		ok( $obs == $exp{$key}, "$key: $obs == $exp{$key}" );
	}
}

my $output = unparse(
	'-format' => 'figtree',
	'-phylo'  => $project,
);
ok( $output );


__DATA__
#NEXUS

Begin taxa;
	Dimensions ntax=18;
	Taxlabels
		Rheodytes_leukops35
		'Elusor_macrurus.mtg'
		Emydura_macquarii
		Emydura_victoriae26
		Emydura_subglobosa61
		Emydura_worrelli
		Emydura_tanybaraga24
		Myuchelys_belli
		'Myuchelys_latisternum.mtg'
		Myuchelys_georgesi
		Elseya_albagula
		Elseya_branderhorsti17
		'Elseya_dentata.mtg'
		Elseya_novaeguineae_ENG_44
		Elseya_novaeguineae_ENG_45
		Elseya_novaeguineae_ENG_56
		Elseya_irwini
		Elseya_lavarackorum
		;
End;

Begin trees;
	Translate
		1 Rheodytes_leukops35,
		2 'Elusor_macrurus.mtg',
		3 Emydura_macquarii,
		4 Emydura_victoriae26,
		5 Emydura_subglobosa61,
		6 Emydura_worrelli,
		7 Emydura_tanybaraga24,
		8 Myuchelys_belli,
		9 'Myuchelys_latisternum.mtg',
		10 Myuchelys_georgesi,
		11 Elseya_albagula,
		12 Elseya_branderhorsti17,
		13 'Elseya_dentata.mtg',
		14 Elseya_novaeguineae_ENG_44,
		15 Elseya_novaeguineae_ENG_45,
		16 Elseya_novaeguineae_ENG_56,
		17 Elseya_irwini,
		18 Elseya_lavarackorum
		;
tree TREE1 = [&R] ((1[&rate_range={6.6550818320187645E-6,3.960232740601061E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={17.31209330178,74.13411454879},height_median=5.9969806898152456E-12,length_95%_HPD={33.20550349826,56.91609759285},height=5.890988898895368E-12,rate=8.568983696811668E-5,height_range={0.0,2.3007373783912044E-11},rate_median=7.824099697386572E-5,length=45.30304838469565,length_median=45.6958945488,rate_95%_HPD={1.4711122976004055E-5,1.7022936607067858E-4}]:45.30304838469567,2[&rate_range={2.5563296144800284E-6,4.8018261546760283E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={17.31209330178,74.13411454879},height_median=5.9969806898152456E-12,length_95%_HPD={33.20550349826,56.91609759285},height=5.890988898895368E-12,rate=8.100441668631028E-5,height_range={0.0,2.3007373783912044E-11},rate_median=7.359016475556727E-5,length=45.30304838469565,length_median=45.6958945488,rate_95%_HPD={1.3320921454702606E-5,1.645278537092137E-4}]:45.30304838469567)testnode[&height_95%_HPD={33.205503498260995,56.916097592862},length_range={0.003196191310465,38.95629186913},length_95%_HPD={0.01269239072315,21.71438182055},height_range={17.312093301779996,74.134114548793},rate_95%_HPD={8.680575467146931E-9,1.7176073055922414E-4},rate_range={8.680575467146931E-9,0.007487588613295},height_median=45.6958945488,rate=5.005783458213507E-5,height=45.30304838470156,posterior=1.0,rate_median=2.4371535825758798E-5,length=11.147755764354484,length_median=10.643015261725001]:11.147755764354365,((((3[&rate_range={7.1118020504098046E-6,0.002918537518411},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={2.334579418611,26.69843124574},height_median=5.9969806898152456E-12,length_95%_HPD={4.438478278174,14.52680527168},height=5.902032226395945E-12,rate=2.8901180034371566E-4,height_range={0.0,2.6005864128819667E-11},rate_median=2.4234928241913562E-4,length=9.102411278380604,length_median=8.724956759077,rate_95%_HPD={2.2798751737701053E-5,6.714535910909797E-4}]:9.102411278380586,4[&rate_range={8.276130255925727E-6,0.002475046631854},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={2.334579418611,26.69843124574},height_median=5.9969806898152456E-12,length_95%_HPD={4.438478278174,14.52680527168},height=5.902032226395945E-12,rate=2.876352757320733E-4,height_range={0.0,2.6005864128819667E-11},rate_median=2.4053439086769773E-4,length=9.102411278380604,length_median=8.724956759077,rate_95%_HPD={2.6141830320625182E-5,6.696223467493425E-4}]:9.102411278380586)[&height_95%_HPD={4.438478278182004,14.526805271680999},length_range={3.865142672919,33.47140846687},length_95%_HPD={9.680495854781,25.6979917226},height_range={2.334579418611,26.698431245739997},rate_95%_HPD={8.226051450217575E-10,9.746690438868013E-5},rate_range={8.226051450217575E-10,8.597001009910277E-4},height_median=8.724956759084002,rate=2.958270495565502E-5,height=9.102411278386489,posterior=1.0,rate_median=1.805956218688832E-5,length=17.44503269018451,length_median=17.331735832255]:17.445032690184384,((5[&rate_range={3.3884539052449095E-7,9.583828346163068E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={3.009549322662,24.26583028226},height_median=5.009326287108706E-12,length_95%_HPD={4.95844219696,14.58855427349},height=5.842293989179883E-12,rate=1.0419549163665919E-4,height_range={0.0,2.4989788016682724E-11},rate_median=7.652396343403292E-5,length=9.729612096247012,length_median=9.5017912709035,rate_95%_HPD={3.3884539052449095E-7,2.893321179638733E-4}]:9.729612096246981,6[&rate_range={2.641788419360796E-7,0.001182801228112},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={3.009549322662,24.26583028226},height_median=5.009326287108706E-12,length_95%_HPD={4.95844219696,14.58855427349},height=5.842293989179883E-12,rate=1.0454881405628488E-4,height_range={0.0,2.4989788016682724E-11},rate_median=7.669055322529E-5,length=9.729612096247012,length_median=9.5017912709035,rate_95%_HPD={8.75774329272121E-7,2.929055818021885E-4}]:9.729612096246981)[&height_95%_HPD={4.958442196965805,14.588554273495994},length_range={0.1071999864741,17.82056558268},length_95%_HPD={1.041061251572,9.213209847159},height_range={3.0095493226640073,24.265830282260005},rate_95%_HPD={5.290293182372616E-9,2.4539886376389534E-4},rate_range={5.290293182372616E-9,0.005111883553004},height_median=9.501791270907503,rate=6.727032484890618E-5,height=9.729612096252824,posterior=1.0,rate_median=3.315964009690644E-5,length=4.816670724735127,length_median=4.53012847003]:4.8166707247351965,7[&rate_range={8.226051450217575E-10,3.9986551900870787E-4},height_95%_HPD={0.0,1.3990586467116373E-11},length_range={5.106591632402,30.94332123274},height_median=5.009326287108706E-12,length_95%_HPD={9.03885772412,20.2494281734},height=5.816383095615345E-12,rate=3.308854186742996E-5,height_range={0.0,2.3099744339560857E-11},rate_median=1.9656572807499505E-5,length=14.546282820982194,length_median=14.32716031816,rate_95%_HPD={8.226051450217575E-10,1.1139939994612546E-4}]:14.546282820982205)[&height_95%_HPD={9.038857724121996,20.249428173409},length_range={2.380508391724,30.96917426144},length_95%_HPD={6.109673187309,18.53674202529},height_range={5.106591632404005,30.943321232740004},rate_95%_HPD={5.530148779955431E-9,1.2677554803630897E-4},rate_range={5.530148779955431E-9,6.676915745623156E-4},height_median=14.327160318169003,rate=3.752582717321094E-5,height=14.54628282098802,posterior=1.0,rate_median=2.186944072941434E-5,length=12.001161147582987,length_median=11.73556556215]:12.00116114758285)[&height_95%_HPD={18.644096844664,34.799712150809995},length_range={0.0770368407402,29.913772793},length_95%_HPD={0.7619466874657,9.537511657733},height_range={12.883921149684,43.166076136353},rate_95%_HPD={5.1144012557736186E-5,0.00224386201205},rate_range={3.180784460826117E-5,0.02648206786205},height_median=26.3586783928895,rate=8.646155344098033E-4,height=26.54744396857087,posterior=1.0,rate_median=6.519767423614807E-4,length=4.777486150644464,length_median=4.35057209324]:4.777486150644666,((8[&rate_range={1.7891122959339579E-9,9.703400485868205E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={1.698734541447,28.98394293405},height_median=5.9898752624576446E-12,length_95%_HPD={3.632360445868,13.1628690146},height=5.807461450933834E-12,rate=4.958114303325537E-5,height_range={0.0,2.5011104298755527E-11},rate_median=2.7503393688849815E-5,length=7.97874661917768,length_median=7.606204804589,rate_95%_HPD={1.7891122959339579E-9,1.719172564537334E-4}]:7.978746619177648,9[&rate_range={5.237247223503465E-5,0.004404127017239},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={1.698734541447,28.98394293405},height_median=5.9898752624576446E-12,length_95%_HPD={3.632360445868,13.1628690146},height=5.807461450933834E-12,rate=6.432979818545888E-4,height_range={0.0,2.5011104298755527E-11},rate_median=5.624134639063666E-4,length=7.97874661917768,length_median=7.606204804589,rate_95%_HPD={1.0057259204474508E-4,0.001372009435131}]:7.978746619177648)[&height_95%_HPD={3.6323604458680023,13.162869014610294},length_range={1.704014916881,37.08026172605},length_95%_HPD={7.068846469646,24.41391856654},height_range={1.6987345414499941,28.983942934058003},rate_95%_HPD={7.485022686959401E-9,1.0759788420361407E-4},rate_range={3.523935381945244E-9,8.380479620608383E-4},height_median=7.606204804598207,rate=3.2659928153479394E-5,height=7.978746619183456,posterior=1.0,rate_median=1.9331901907914978E-5,length=15.643055992813826,length_median=15.52818030403]:15.643055992813883,10[&rate_range={9.51444164184618E-6,9.901267549398388E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={7.811701566496,43.38009649345},height_median=5.9969806898152456E-12,length_95%_HPD={15.06088113148,32.45323952996},height=5.874953539032744E-12,rate=1.543378303429449E-4,height_range={0.0,2.7995383788947947E-11},rate_median=1.3829194659493413E-4,length=23.62180261199154,length_median=23.475786602105,rate_95%_HPD={2.598190607904444E-5,3.2000790741165393E-4}]:23.621802611991463)[&height_95%_HPD={15.060881131494,32.453239529961},length_range={0.4150016837856,29.62119719621},length_95%_HPD={1.946347815629,14.72008396923},height_range={7.811701566500986,43.380096493458005},rate_95%_HPD={4.371544015291046E-4,0.00459831139314},rate_range={2.428073290516741E-4,0.03083501047754},height_median=23.475786602114,rate=0.0021381941815684672,height=23.62180261199734,posterior=1.0,rate_median=0.0018044625514795,length=7.703127507218055,length_median=7.1637802771225]:7.703127507218198)[&height_95%_HPD={22.384242790836005,39.750635291058},length_range={3.56601739588,39.01366415777},length_95%_HPD={11.68301264841,29.06164696195},height_range={15.613113733035,55.79910948481},rate_95%_HPD={2.7427403773481475E-9,9.87988372584572E-5},rate_range={2.7427403773481475E-9,4.660735063170074E-4},height_median=31.12418928407805,rate=3.0125745847311026E-5,height=31.324930119215537,posterior=1.0,rate_median=1.8512828552221764E-5,length=20.565312309339895,length_median=20.577493179675]:20.565312309339973,(11[&rate_range={3.2950983633963015E-9,1.9552333878734314E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={15.93004257969,58.274379978},height_median=5.9969806898152456E-12,length_95%_HPD={28.12097720098,46.00177595717},height=5.950543225361117E-12,rate=1.7175492021076138E-5,height_range={0.0,2.3000268356554443E-11},rate_median=1.1435457853538785E-5,length=37.384183912838125,length_median=37.3419227119,rate_95%_HPD={3.2950983633963015E-9,5.3129693754651714E-5}]:37.38418391283822,(((12[&rate_range={1.5387504196594186E-9,9.496165053689018E-4},height_95%_HPD={0.0,1.3010037491767434E-11},length_range={1.433581993737,20.6953920068},height_median=5.9969806898152456E-12,length_95%_HPD={2.821684762946,9.757406470603},height=5.884537814936951E-12,rate=5.675337512050841E-5,height_range={0.0,2.3995028186618583E-11},rate_median=3.074044514194049E-5,length=6.16040113611658,length_median=5.929231986846,rate_95%_HPD={1.5387504196594186E-9,2.0066544880611032E-4}]:6.160401136116555,13[&rate_range={2.738349684296879E-7,0.00310728350684},height_95%_HPD={0.0,1.3010037491767434E-11},length_range={1.433581993737,20.6953920068},height_median=5.9969806898152456E-12,length_95%_HPD={2.821684762946,9.757406470603},height=5.884537814936951E-12,rate=2.692882622003228E-4,height_range={0.0,2.3995028186618583E-11},rate_median=1.8007638621032166E-4,length=6.16040113611658,length_median=5.929231986846,rate_95%_HPD={4.019341988731692E-7,8.164220249419297E-4}]:6.160401136116555)[&height_95%_HPD={2.8216847629490047,9.757406470618001},length_range={5.575988039412,34.10763284734},length_95%_HPD={10.74289573227,24.35986943548},height_range={1.4335819937450012,20.695392006814018},rate_95%_HPD={8.182122388356006E-5,6.064382518395379E-4},rate_range={1.8554830910576864E-5,0.001366389294192},height_median=5.929231986851999,rate=3.11507767923937E-4,height=6.160401136122439,posterior=1.0,rate_median=2.8466040973617517E-4,length=17.291468608372004,length_median=17.18592940677]:17.29146860837221,((14[&rate_range={4.82187988367463E-6,9.748099604975168E-4},height_95%_HPD={0.0,1.3095302620058646E-11},length_range={5.459147654751,34.09911951593},height_median=5.7980287238024175E-12,length_95%_HPD={11.01277102588,24.47026083882},height=5.912653269555675E-12,rate=1.555888203041368E-4,height_range={0.0,2.3000268356554443E-11},rate_median=1.3523345265890115E-4,length=17.420148727965213,length_median=17.31388704793,rate_95%_HPD={1.533201302070589E-5,3.382863034011099E-4}]:17.42014872796529,15[&rate_range={1.2047034695341407E-9,3.741205278859006E-4},height_95%_HPD={0.0,1.3095302620058646E-11},length_range={5.459147654751,34.09911951593},height_median=5.7980287238024175E-12,length_95%_HPD={11.01277102588,24.47026083882},height=5.912653269555675E-12,rate=2.905370539406488E-5,height_range={0.0,2.3000268356554443E-11},rate_median=1.7410415051306174E-5,length=17.420148727965213,length_median=17.31388704793,rate_95%_HPD={1.2047034695341407E-9,9.595219798530729E-5}]:17.42014872796529)[&height_95%_HPD={11.012771025883993,24.470260838825006},length_range={0.001113951176436,14.68450341682},length_95%_HPD={0.01019312454127,5.386507948252},height_range={5.459147654757004,34.09911951593601},rate_95%_HPD={2.901607794957528E-9,4.2473724656577296E-4},rate_range={2.901607794957528E-9,0.01075430647938},height_median=17.31388704793265,rate=1.1333412875691424E-4,height=17.420148727971203,posterior=1.0,rate_median=4.616267577278042E-5,length=2.3790114793185726,length_median=2.0728525770669997]:2.379011479318603,16[&rate_range={2.0641785354238403E-7,4.7015003528099694E-4},height_95%_HPD={0.0,1.3002932064409833E-11},length_range={6.826705458356,35.08708272395},height_median=5.9969806898152456E-12,length_95%_HPD={13.32660463404,26.84043486744},height=5.923602668389783E-12,rate=5.783856463195402E-5,height_range={0.0,2.3000268356554443E-11},rate_median=4.462917681909899E-5,length=19.79916020728379,length_median=19.704428890655002,rate_95%_HPD={8.77886272385531E-7,1.5677812288957698E-4}]:19.799160207283883)[&height_95%_HPD={13.32660463404499,26.840434867440997},length_range={0.1260316934824,19.3304617325},length_95%_HPD={0.5665955030686,7.317464727642},height_range={6.826705458359996,35.087082723951994},rate_95%_HPD={4.66831963083223E-4,0.007646859464867},rate_range={2.360432774773691E-4,0.0653955653469},height_median=19.704428890667,rate=0.0032268822514500846,height=19.799160207289805,posterior=1.0,rate_median=0.0025804351386465,length=3.6527095372048324,length_median=3.3237057539499997]:3.652709537204842)[&height_95%_HPD={16.565523364294997,30.599168590079007},length_range={0.04016005032555,17.10615170651},length_95%_HPD={1.183374973462,8.948814420304},height_range={9.780448105448002,39.575777510017005},rate_95%_HPD={3.0148519304680654E-9,2.4829648978991024E-4},rate_range={3.0148519304680654E-9,0.002038356059305},height_median=23.319536302983348,rate=6.937851545997661E-5,height=23.451869744494648,posterior=1.0,rate_median=3.481766311527862E-5,length=4.75611669234821,length_median=4.45831775987]:4.756116692348254,(17[&rate_range={5.429597160647324E-6,0.002435743845359},height_95%_HPD={0.0,1.3990586467116373E-11},length_range={1.743613063032,29.50745498781},height_median=5.9969806898152456E-12,length_95%_HPD={3.885941816727,12.81281687562},height=5.918756659584851E-12,rate=3.2694970500345865E-4,height_range={0.0,2.5003998871397926E-11},rate_median=2.722109052815129E-4,length=7.900927286328332,length_median=7.5869672425745005,rate_95%_HPD={2.785890596541039E-5,7.584622029155317E-4}]:7.900927286328378,18[&rate_range={1.6225356232227406E-7,0.001583073698934},height_95%_HPD={0.0,1.3990586467116373E-11},length_range={1.743613063032,29.50745498781},height_median=5.9969806898152456E-12,length_95%_HPD={3.885941816727,12.81281687562},height=5.918756659584851E-12,rate=1.2379330656183082E-4,height_range={0.0,2.5003998871397926E-11},rate_median=8.981780888349459E-5,length=7.900927286328332,length_median=7.5869672425745005,rate_95%_HPD={1.6225356232227406E-7,3.490449001772762E-4}]:7.900927286328378)[&height_95%_HPD={3.8859418167299964,12.812816875620001},length_range={5.90022565873,36.83759407986},length_95%_HPD={12.75370589568,28.08145761891},height_range={1.743613063044009,29.507454987817},rate_95%_HPD={3.8310009367873836E-7,1.5205380034707762E-4},rate_range={1.242771366534364E-7,5.183419133659715E-4},height_median=7.586967242577007,rate=5.753807214899097E-5,height=7.900927286334297,posterior=1.0,rate_median=4.44359484188766E-5,length=20.307059150508493,length_median=20.220217825985]:20.307059150508604)[&height_95%_HPD={20.379866592096995,35.72475000671599},length_range={1.550467947197,27.28054299557},length_95%_HPD={3.785997038196,15.23946008984},height_range={11.848977002192996,46.431427759689996},rate_95%_HPD={1.7113870796404118E-9,1.51598209268046E-4},rate_range={1.7113870796404118E-9,0.001052536448641},height_median=28.091138004410595,rate=4.428697223870432E-5,height=28.2079864368429,posterior=1.0,rate_median=2.4685815914700256E-5,length=9.176197476001187,length_median=8.863120955427]:9.176197476001263)[&height_95%_HPD={28.120977200986005,46.001775957178005},length_range={3.256459595903,34.01312642678},length_95%_HPD={6.877573175133,22.32515032905},height_range={15.930042579692994,58.27437997800699},rate_95%_HPD={1.763988998042814E-4,0.001220795517501},rate_range={7.653121973499907E-5,0.003071838662339},height_median=37.3419227119054,rate=6.357379749229032E-4,height=37.384183912844165,posterior=1.0,rate_median=5.752490111097016E-4,length=14.506058515711688,length_median=14.272031498995]:14.506058515711345)[&height_95%_HPD={42.857653898619,59.2460259128},length_range={6.280613468732099E-4,24.33264874567},length_95%_HPD={6.280613468732099E-4,11.38770702906},height_range={32.137913457473005,71.35387497421},rate_95%_HPD={2.9796484984979303E-9,3.3327906049885405E-4},rate_range={2.9796484984979303E-9,0.01613106549913},height_median=52.3086589066925,rate=9.197156474544209E-5,height=51.89024242855551,posterior=1.0,rate_median=3.696204484566394E-5,length=4.5605617205004485,length_median=3.828252364515]:4.5605617205004165)[&height_95%_HPD={53.149747746329,61.047138562785996},height_median=55.9682378977875,height=56.45080414905593,rate=1.0,posterior=1.0,height_range={52.59135819968,77.72819194855599},length=0.0];
End;