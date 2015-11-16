package Bio::Phylo::Models::Substitution::Dna;
use Bio::Phylo::Util::CONSTANT qw'/looks_like/ :objecttypes';
use Bio::Phylo::Util::Exceptions qw'throw';
use Bio::Phylo::IO qw(parse unparse);
use Bio::Phylo::Util::Logger':levels';
use File::Temp qw(tempfile cleanup);

use strict;

sub _INDEX_OF_ { { A => 0, C => 1, G => 2, T => 3 } }
sub _BASE_AT_ { [qw(A C G T)] }

my $logger = Bio::Phylo::Util::Logger->new;

sub new {
    my $class = shift;
    my %args  = looks_like_hash @_;
    $class .= '::' . uc $args{'-type'} if $args{'-type'};
    delete $args{'-type'};
    my $self = {};
    bless $self, looks_like_class $class;
    while ( my ( $key, $value ) = each %args ) {
        $key =~ s/^-/set_/;
        $self->$key($value);
    }
    return $self;
}

sub get_catrates {
    throw 'NotImplemented' => 'FIXME';
}

sub get_nst { 6 }

# subst rate
sub get_rate {
    my $self = shift;
    if (@_) {
        my $src    = _INDEX_OF_()->{ uc shift };
        my $target = _INDEX_OF_()->{ uc shift };
        $self->{'_rate'} = [] if not $self->{'_rate'};
        if ( not $self->{'_rate'}->[$src] ) {
            $self->{'_rate'}->[$src] = [];
        }
        return $self->{'_rate'}->[$src]->[$target];
    }
    else {
        return return $self->{'_rate'};
    }
}

# number of states
sub get_nstates {
    my $states = _BASE_AT_;
    return scalar @{ $states };
}

# number of categories for gamma distribution
sub get_ncat { shift->{'_ncat'} }

# weights for rate categories
sub get_catweights { shift->{'_catweights'} }

# ti/tv ratio
sub get_kappa { shift->{'_kappa'} }

# gamma shape parameter
sub get_alpha { shift->{'_alpha'} }

# overall mutation rate
sub get_mu { shift->{'_mu'} }

# proportion of invariant sites
sub get_pinvar { shift->{'_pinvar'} }

# base freq
sub get_pi {
    my $self = shift;
    $self->{'_pi'} = [] if not $self->{'_pi'};
    if (@_) {
        my $base = uc shift;
        return $self->{'_pi'}->[ _INDEX_OF_()->{$base} ];
    }
    else {
        return $self->{'_pi'};
    }
}

# use median for gamma-modeled rate categories
sub get_median { shift->{'_median'} }

sub set_rate {
    my ( $self, $q ) = @_;
    ref $q eq 'ARRAY' or throw 'BadArgs' => 'Not an array ref!';
    scalar @{$q} == 4 or throw 'BadArgs' => 'Q matrix must be 4 x 4';
    for my $row ( @{$q} ) {
        scalar @{$row} == 4 or throw 'BadArgs' => 'Q matrix must be 4 x 4';
    }
    $self->{'_rate'} = $q;
    return $self;
}

sub set_ncat {
    my $self = shift;
    $self->{'_ncat'} = shift;
    return $self;
}

sub set_catweights {
    my $self = shift;
    $self->{'_catweights'} = shift;
    return $self;
}

sub set_kappa {
    my $self = shift;
    $self->{'_kappa'} = shift;
    return $self;
}

sub set_alpha {
    my $self = shift;
    $self->{'_alpha'} = shift;
    return $self;
}

sub set_mu {
    my $self = shift;
    $self->{'_mu'} = shift;
    return $self;
}

sub set_pinvar {
    my $self   = shift;
    my $pinvar = shift;
    if ( $pinvar <= 0 || $pinvar >= 1 ) {
        throw 'BadArgs' => "Pinvar not between 0 and 1";
    }
    $self->{'_pinvar'} = $pinvar;
    return $self;
}

sub set_pi {
    my ( $self, $pi ) = @_;
    ref $pi eq 'ARRAY' or throw 'BadArgs' => "Not an array ref!";
    my $total = 0;
    $total += $_ for @{$pi};
    my $epsilon = 0.000001;
    abs(1 - $total) < $epsilon or throw 'BadArgs' => 'Frequencies must sum to one';
    $self->{'_pi'} = $pi;
    return $self;
}

sub set_median {
    my $self = shift;
    $self->{'_median'} = !!shift;
    return $self;
}

# get substitution model for DNA alignment and optional tree
sub modeltest {
	my ($self, %args) = @_;

	my $matrix = $args{'-matrix'};
	my $tree = $args{'-tree'};
	my $timeout = $args{'-timeout'} || -1;

	my $model;

	if ( looks_like_class 'Statistics::R' ) {

		# phangorn needs files as input
		my ($fasta_fh, $fasta) = tempfile();
		print $fasta_fh unparse('-phylo'=>$matrix, '-format'=>'fasta');
		close $fasta_fh;

		# instanciate R and lcheck if phangorn is installed
		my $R = Statistics::R->new;
		$R->run(q[options(device=NULL)]);
		$R->run(q[package <- require("phangorn")]);

		if ( ! $R->get(q[package]) eq "TRUE") {
			$logger->warn("R library phangorn must be installed to run modeltest");
			return $model;
		}
		
		# read data
		$R->run(qq[data <- read.FASTA("$fasta")]);
		
		# remove temp file 
		cleanup();
		
		# throw (and catch) signal when user timeout exceeded
		eval {
			local $SIG{ALRM} = sub { die("TimeOut of $timeout seconds for phangorn's modeltest exceeded"); };
			alarm($timeout);

			if ( $tree ) {
				# make copy of tree since it will be pruned
				my $current_tree = parse('-format'=>'newick', '-string'=>$tree->to_newick)->first;
				# prune out taxa from tree that are not present in the data
				my @taxon_names = map {$_->get_name} @{ $matrix->get_entities };
				$logger->debug('pruning input tree');
				$current_tree->keep_tips(\@taxon_names);
				$logger->debug('pruned input tree: ' . $current_tree->to_newick);

				if ( ! $current_tree or scalar( @{ $current_tree->get_terminals } ) < 3 ) {					
					$logger->warn('pruned tree has too few tip labels, simulating without tree');
					$R->run(q[test <- modelTest(phyDat(data))]);
				} 
				else {
					my $newick = $current_tree->to_newick;
					
					$R->run(qq[tree <- read.tree(text="$newick")]);
					# call modelTest
					$logger->debug("calling modelTest from R package phangorn");
					$R->run(q[test <- modelTest(phyDat(data), tree=tree)]);
				}
			}
			else {
				# modelTest will estimate tree
				$R->run(q[test <- modelTest(phyDat(data))]);
			}
			alarm(0);
		};

		# catch timeout and other possible errors from phangorn
		if ( $@ ) {
			$logger->warn($@);
			$R->stop;
			return 0;
		}

		# get model with lowest Aikaike information criterion
		$R->run(q[model <- test[which(test$AIC==min(test$AIC)),]$Model]);
		my $modeltype = $R->get(q[model]);
		$logger->info("estimated DNA evolution model $modeltype");

		# determine model parameters
		$R->run(q[env <- attr(test, "env")]);
		$R->run(q[fit <- eval(get(model, env), env)]);

		#  get base freqs
		my $pi = $R->get(q[fit$bf]);

		# get overall mutation rate
		my $mu = $R->get(q[fit$rate]);

		# get lower triangle of rate matrix (column order ACGT)
		# and fill whole matrix; set diagonal values to 1
		my $q = $R->get(q[fit$Q]);
		my $rate_matrix = [ [ 1,       $q->[0], $q->[1], $q->[3] ],
						    [ $q->[0], 1,       $q->[2], $q->[4] ],
						    [ $q->[1], $q->[2], 1,       $q->[5] ],
						    [ $q->[3], $q->[4], $q->[5], 1       ]
			];

		# create model with specific parameters dependent on primary model type
		if ( $modeltype =~ /JC/ ) {
			require Bio::Phylo::Models::Substitution::Dna::JC69;
			$model = Bio::Phylo::Models::Substitution::Dna::JC69->new();
		}
		elsif ( $modeltype =~ /F81/ ) {
			require Bio::Phylo::Models::Substitution::Dna::F81;
			$model = Bio::Phylo::Models::Substitution::Dna::F81->new('-pi' => $pi);
		}
		elsif ( $modeltype =~ /GTR/ ) {
			require Bio::Phylo::Models::Substitution::Dna::GTR;
			$model = Bio::Phylo::Models::Substitution::Dna::GTR->new('-pi' => $pi);
		}
		elsif ( $modeltype =~ /HKY/ ) {
			require Bio::Phylo::Models::Substitution::Dna::HKY85;
			# transition/transversion ratio kappa determined by transiton A->G/A->C in Q matrix
			my $kappa = $R->get(q[fit$Q[2]/fit$Q[1]]);
			$model = Bio::Phylo::Models::Substitution::Dna::HKY85->new('-kappa' => $kappa, '-pi' => $pi );
		}
		elsif ( $modeltype =~ /K80/ ) {
			require Bio::Phylo::Models::Substitution::Dna::K80;
			my $kappa = $R->get(q[fit$Q[2]]);
			$model = Bio::Phylo::Models::Substitution::Dna::K80->new(
				'-pi' => $pi,
				'-kappa' => $kappa );
		}
		# Model is unknown  (e.g. phangorn's SYM ?)
		else {
			$logger->debug("unknown model type, setting to generic DNA substitution model");
			$model = Bio::Phylo::Models::Substitution::Dna->new(
				'-pi' => $pi );
		}

		# set gamma parameters
		if ( $modeltype =~ /\+G/ ) {
			$logger->debug("setting gamma parameters for $modeltype model");
			# shape of gamma distribution
			my $alpha = $R->get(q[fit$shape]);
			$model->set_alpha($alpha);
			# number of categories for Gamma distribution
			my $ncat = $R->get(q[fit$k]);
			$model->set_ncat($ncat);
			# weights for rate categories
			my $catweights = $R->get(q[fit$w]);
			$model->set_catweights($catweights);
		}

		# set invariant parameters
		if ( $modeltype =~ /\+I/ ) {
			$logger->debug("setting invariant site parameters for $modeltype model");
			# get proportion of invariant sites
			my $pinvar = $R->get(q[fit$inv]);
			$model->set_pinvar($pinvar);
		}
		# set universal parameters
		$model->set_rate($rate_matrix);
		$model->set_mu($mu);
	}
	else {
		$logger->warn("Statistics::R must be installed to run modeltest");
	}

	return $model;
}

sub to_string {
    my $self = shift;
    my %args = looks_like_hash @_;
    if ( $args{'-format'} =~ m/paup/i ) {
        return $self->_to_paup_string(@_);
    }
    if ( $args{'-format'} =~ m/phyml/i ) {
        return $self->_to_phyml_string(@_);
    }
    if ( $args{'-format'} =~ m/mrbayes/i ) {
        return $self->_to_mrbayes_string(@_);
    }
    if ( $args{'-format'} =~ m/garli/i ) {
        return $self->_to_garli_string(@_);
    }
}

sub _to_garli_string {
    my $self   = shift;
    my $nst    = $self->get_nst;
    my $string = "ratematrix ${nst}\n";
    if ( my $pinvar = $self->get_pinvar ) {
        $string .= "invariantsites fixed\n";
    }
    if ( my $ncat = $self->get_ncat ) {
        $string .= "numratecats ${ncat}\n";
    }
    if ( my $alpha = $self->get_alpha ) {
        $string .= "ratehetmodel gamma\n";
    }
    return $string;
}

sub _to_mrbayes_string {
    my $self   = shift;
    my $string = 'lset ';
    $string .= ' nst=' . $self->get_nst;
    if ( $self->get_pinvar && $self->get_alpha ) {
        $string .= ' rates=invgamma';
        if ( $self->get_ncat ) {
            $string .= ' ngammacat=' . $self->get_ncat;
        }
    }
    elsif ( $self->get_pinvar ) {
        $string .= ' rates=propinv';
    }
    elsif ( $self->get_alpha ) {
        $string .= ' rates=gamma';
        if ( $self->get_ncat ) {
            $string .= ' ngammacat=' . $self->get_ncat;
        }
    }
    $string .= ";\n";
    if ( $self->get_kappa && $self->get_nst == 2 ) {
        $string .= 'prset tratiopr=fixed(' . $self->get_kappa . ");\n";
    }
    my @rates;
    push @rates, $self->get_rate( 'A' => 'C' );
    push @rates, $self->get_rate( 'A' => 'G' );
    push @rates, $self->get_rate( 'A' => 'T' );
    push @rates, $self->get_rate( 'C' => 'G' );
    push @rates, $self->get_rate( 'C' => 'T' );
    push @rates, $self->get_rate( 'G' => 'T' );
    $string .= 'prset revmatpr=fixed(' . join( ',', @rates ) . ");\n";

    if (   $self->get_pi('A')
        && $self->get_pi('C')
        && $self->get_pi('G')
        && $self->get_pi('T') )
    {
        my @freqs;
        push @freqs, $self->get_pi('A');
        push @freqs, $self->get_pi('C');
        push @freqs, $self->get_pi('G');
        push @freqs, $self->get_pi('T');
        $string .= 'prset statefreqpr=fixed(' . join( ',', @freqs ) . ");\n";
    }
    if ( $self->get_alpha ) {
        $string .= 'prset shapepr=fixed(' . $self->get_alpha . ");\n";
    }
    if ( $self->get_pinvar ) {
        $string .= 'prset pinvarpr=fixed(' . $self->get_pinvar . ");\n";
    }
}

sub _to_phyml_string {
    my $self = shift;
    my $m    = ref $self;
    $m =~ s/.+://;
    my $string = "--model $m";
    if (   $self->get_pi('A')
        && $self->get_pi('C')
        && $self->get_pi('G')
        && $self->get_pi('T') )
    {
        my @freqs;
        push @freqs, $self->get_pi('A');
        push @freqs, $self->get_pi('C');
        push @freqs, $self->get_pi('G');
        push @freqs, $self->get_pi('T');
        $string .= ' -f ' . join ' ', @freqs;
    }
    if ( $self->get_nst == 2 and defined( my $kappa = $self->get_kappa ) ) {
        $string .= ' --ts/tv ' . $kappa;
    }
    if ( $self->get_pinvar ) {
        $string .= ' --pinv ' . $self->get_pinvar;
    }
    if ( $self->get_ncat ) {
        $string .= ' --nclasses ' . $self->get_ncat;
        $string .= ' --use_median' if $self->get_median;
    }
    if ( $self->get_alpha ) {
        $string .= ' --alpha ' . $self->get_alpha;
    }
    return $string;
}

sub _to_paup_string {
    my $self   = shift;
    my $nst    = $self->get_nst;
    my $string = 'lset nst=' . $nst;
    if ( $nst == 2 and defined( my $kappa = $self->get_kappa ) ) {
        $string .= ' tratio=' . $kappa;
    }
    if ( $nst == 6 ) {
        my @rates;
        push @rates, $self->get_rate( 'A' => 'C' );
        push @rates, $self->get_rate( 'A' => 'G' );
        push @rates, $self->get_rate( 'A' => 'T' );
        push @rates, $self->get_rate( 'C' => 'G' );
        push @rates, $self->get_rate( 'C' => 'T' );
        $string .= ' rmatrix=(' . join( ' ', @rates ) . ')';
    }
    if ( $self->get_pi('A') && $self->get_pi('C') && $self->get_pi('G') ) {
        my @freqs;
        push @freqs, $self->get_pi('A');
        push @freqs, $self->get_pi('C');
        push @freqs, $self->get_pi('G');
        $string .= ' basefreq=(' . join( ' ', @freqs ) . ')';
    }
    if ( $self->get_alpha ) {
        $string .= ' rates=gamma shape=' . $self->get_alpha;
    }
    if ( $self->get_ncat ) {
        $string .= ' ncat=' . $self->get_ncat;
        $string .= ' reprate=' . ( $self->get_median ? 'median' : 'mean' );
    }
    if ( $self->get_pinvar ) {
        $string .= ' pinvar=' . $self->get_pinvar;
    }
    return $string . ';';
}

sub _type { _MODEL_ }

1;
