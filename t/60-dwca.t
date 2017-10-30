use Test::More;
BEGIN {
    eval { require XML::Twig };
    if ($@) {
        plan 'skip_all' => 'XML::Twig not installed';
    }
    else {
        eval { require Archive::Zip };
        if ($@) {
            plan 'skip_all' => 'Archive::Zip not installed';
        }
        else {
            Test::More->import('no_plan');
        }
    }
}
use Net::Ping;
use Bio::Phylo::IO 'parse';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# a set of fossil occurrences of th feral horse, Equus ferus Boddaert, 1785
# this corresponds with data set doi:10.15468/dl.yyyhyn
my $url = 'http://api.gbif.org/v1/occurrence/download/request/0074675-160910150852091.zip';
	
# like every Bio::Phylo::IO module, we can parse directly from a web location
my $proj = parse(
	'-format' => 'dwca',
	'-url'    => $url,
	'-as_project' => 1,
);

# write a CSV file with MAXENT header
for my $t ( @{ $proj->get_items(_TAXON_) } ) {
	my $exp  = expected();
	my $i = 0;
	for my $m ( @{ $t->get_meta } ) {
		my $lat = $m->get_meta_object('dwc:decimalLatitude');
		my $lon = $m->get_meta_object('dwc:decimalLongitude');
		ok( $lat == $exp->[$i]->[0], "Latitude=$lat" );
		ok( $lon == $exp->[$i]->[1], "Longitude=$lon" );
		$i++;
	}
}

sub expected {
	[
		[27.28,-81.86],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[27.28,-81.86],
		[27.83,-82.81],
		[27.83,-82.81],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.85,-82.72],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.9,-82.77],
		[30.72,-85.2],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.9,-82.77],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.9,-82.77],
		[29.85,-82.72],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.9,-82.77],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.9,-82.77],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.85,-82.72],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.84,-82.7],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[30.71,-84.86],
		[30.71,-84.86],
		[30.71,-84.86],
		[30.71,-84.86],
		[28.99,-82.34],
		[27.97,-81.84],
		[50.0,8.27],
		[50.0,8.27],
		[52.6,3.37],
		[30.17,-83.96],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[30.19,-84.26],
		[30.19,-84.26],
		[30.19,-84.26],
		[30.19,-84.26],
		[30.19,-84.26],
		[29.53,-81.76],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.84,-82.71],
		[29.02,-82.42],
		[29.02,-82.42],
		[29.02,-82.42],
		[29.02,-82.42],
		[29.09,-82.43],
		[29.09,-82.43],
		[29.09,-82.43],
		[29.09,-82.43],
		[29.09,-82.43],
		[27.14,-82.36],
		[29.59,-81.88],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[28.95,-81.34],
		[30.17,-83.96],
		[30.17,-83.96],
		[30.17,-83.96],
		[30.19,-83.94],
		[30.17,-83.96],
		[30.17,-83.96],
		[30.17,-83.96],
		[30.17,-83.96],
		[27.23,-81.88],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[27.83,-82.81],
		[30.22,-83.24],
		[30.22,-83.24],
		[30.22,-83.24],
		[27.68,-83.05],
		[30.22,-83.24],
		[30.22,-83.24],
		[30.22,-83.24],
		[27.68,-83.05],
		[27.68,-83.05],
		[30.22,-83.24],
		[29.28,-82.66],
		[30.22,-83.24],
		[30.14,-83.98],
		[30.22,-83.24],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.69],
		[29.28,-82.69],
		[29.28,-82.69],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.69],
		[29.28,-82.69],
		[29.28,-82.69],
		[29.28,-82.67],
		[29.28,-82.69],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.69],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[25.61,-80.31],
		[25.61,-80.31],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[25.61,-80.31],
		[29.85,-82.72],
		[29.84,-82.7],
		[30.16,-83.96],
		[29.96,-82.78],
		[29.84,-82.7],
		[29.69,-82.56],
		[29.96,-82.78],
		[29.69,-82.56],
		[29.96,-82.78],
		[27.54,-80.47],
		[27.53,-80.47],
		[27.54,-80.47],
		[27.53,-80.47],
		[29.64,-81.6],
		[27.53,-80.47],
		[27.53,-80.47],
		[29.64,-81.6],
		[29.64,-81.6],
		[27.53,-80.47],
		[27.53,-80.47],
		[27.53,-80.47],
		[30.27,-83.97],
		[30.15,-83.96],
		[28.77,-82.05],
		[28.77,-82.05],
		[28.77,-82.05],
		[28.77,-82.05],
		[29.68,-82.58],
		[29.69,-81.52],
		[27.24,-80.98],
		[27.17,-81.9],
		[30.19,-83.94],
		[30.19,-83.94],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[29.64,-81.6],
		[30.17,-83.96],
		[30.16,-83.96],
		[30.16,-83.96],
		[30.16,-83.96],
		[30.16,-83.96],
		[28.08,-80.63],
		[29.57,-81.17],
		[30.16,-83.96],
		[30.17,-83.96],
		[29.83,-82.68],
		[29.83,-82.68],
		[29.85,-82.62],
		[29.85,-82.62],
		[29.85,-82.62],
		[28.99,-82.35],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[30.27,-83.97],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.01,-82.63],
		[29.0,-82.38],
		[28.99,-82.35],
		[28.99,-82.35],
		[29.37,-81.9],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[25.57,-80.43],
		[25.57,-80.43],
		[25.57,-80.43],
		[25.57,-80.43],
		[25.57,-80.43],
		[25.57,-80.43],
		[29.85,-82.59],
		[25.57,-80.43],
		[27.6,-81.8],
		[27.68,-81.81],
		[27.68,-81.81],
		[27.68,-81.81],
		[27.68,-81.81],
		[27.68,-81.81],
		[27.28,-81.86],
		[27.28,-81.86],
		[27.38,-81.84],
		[27.38,-81.84],
		[27.38,-81.84],
		[27.38,-81.84],
		[27.38,-81.84],
		[27.25,-81.88],
		[27.25,-81.88],
		[27.43,-81.85],
		[27.25,-81.88],
		[27.25,-81.88],
		[27.25,-81.88],
		[27.25,-81.88],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.25,-81.88],
		[30.17,-83.96],
		[29.83,-82.69],
		[29.85,-82.72],
		[30.29,-81.39],
		[29.3,-82.73],
		[29.84,-82.68],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.28,-82.67],
		[29.84,-82.68],
		[29.84,-82.68],
		[29.84,-82.68],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.84,-82.7],
		[29.96,-82.78],
		[29.28,-82.69],
		[29.28,-82.69],
		[29.51,-81.95],
		[29.84,-82.7],
		[29.84,-82.7],
		[27.65,-80.4],
		[27.65,-80.4],
		[27.65,-80.4],
		[29.67,-82.34],
		[26.74,-80.89],
		[26.74,-80.89],
		[29.96,-82.78],
		[29.84,-82.7],
		[29.83,-82.68],
		[29.83,-82.69],
		[29.96,-82.78],
		[29.96,-82.78],
		[29.96,-82.78],
		[29.83,-82.64],
		[29.83,-82.64],
		[27.86,-82.84],
		[27.25,-81.88],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.3,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.31,-82.73],
		[29.32,-82.73],
		[29.31,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.31,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.33,-82.74],
		[29.33,-82.74],
		[29.32,-82.73],
		[29.33,-82.74],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[27.63,-80.39],
		[29.28,-82.66],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.43,-81.85],
		[29.32,-82.73],
		[29.32,-82.73],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.43,-81.85],
		[27.43,-81.85],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[27.63,-80.39],
		[29.32,-82.73],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.28,-82.74],
		[29.29,-82.73],
		[29.28,-82.74],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.3,-82.73],
		[29.29,-82.73],
		[29.29,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[29.3,-82.73],
		[27.65,-80.4],
		[27.63,-80.39],
		[29.15,-82.16],
		[27.63,-80.39],
		[27.63,-80.39],
		[29.32,-82.73],
		[29.66,-82.65],
		[27.63,-80.39],
		[27.63,-80.39],
		[29.28,-82.66],
		[29.28,-82.66],
		[29.85,-82.59],
		[29.85,-82.59],
		[29.85,-82.59],
		[30.29,-81.39],
		[30.29,-81.39],
		[30.29,-81.39],
		[30.29,-81.39],
		[29.84,-82.68],
		[29.15,-82.16],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.65,-80.4],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.8,-82.8],
		[27.8,-82.8],
		[27.8,-82.8],
		[27.8,-82.8],
		[27.8,-82.8],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.65,-80.4],
		[29.19,-82.14],
		[27.63,-80.39],
		[27.99,-82.83],
		[27.65,-80.4],
		[29.96,-82.78],
		[29.96,-82.78],
		[27.63,-80.39],
		[29.32,-82.73],
		[27.63,-80.39],
		[27.63,-80.39],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[29.32,-82.73],
		[27.63,-80.39],
		[27.63,-80.39],
		[27.63,-80.39],
		[29.32,-82.73],
		[27.81,-82.8],
		[29.96,-82.78],
		[27.65,-80.4],
		[27.63,-80.39],
		[29.96,-82.78],
		[27.63,-80.39],
		[27.65,-80.4],
		[27.63,-80.39],
		[27.63,-80.39],
		[29.52,-82.3],
		[27.63,-80.39],
		[29.19,-82.14],
		[35.15,38.82],
	]
}
