#!/usr/bin/perl
use strict;
use warnings;
use XML::Twig;
use Getopt::Long;
use Data::Dumper;
use Bio::Phylo::Factory;
use Bio::Phylo::Util::Logger qw[:levels];
use Bio::Phylo::Util::Exceptions qw[throw];
use Bio::Phylo::Util::CONSTANT qw[:namespaces];
use Archive::Zip qw[:ERROR_CODES :CONSTANTS];

# process command line arguments
my $verbosity = WARN;
my $infile;
GetOptions(
	'verbose+' => \$verbosity,
	'infile=s' => \$infile,
);

# instantiate helper objects
my $fac = Bio::Phylo::Factory->new;
my $log = Bio::Phylo::Util::Logger->new(
	'-class' => 'main',
	'-level' => $verbosity,
);

# example call to _parse
my $taxa = _parse($infile);
my $proj = $fac->create_project;
$proj->insert($taxa);
print $proj->to_xml;

# read the zip
sub _parse {
	my $infile = shift;
	
	# test reading
	my $zip = Archive::Zip->new;
	if ( $zip->read($infile) != AZ_OK ) {
		throw 'FileError' => "$infile can't be read as ZIP file";	
	}
	
	# extract to string, parse in memory, validate type
	my $xml = XML::Twig->new;
	$xml->parse( _read_zip_member( $zip => 'meta.xml' ) );
	my $core = $xml->root->first_child('core');
	if ( $core->att('rowType') ne _NS_DWC_ . 'Occurrence' ) {
		throw 'FileError' => "$infile does not contain occurrences as core data";
	}
	
	# start building return value
	my $taxa = $fac->create_taxa(
		'-namespaces' => {
			'dwc'     => _NS_DWC_,
			'dcterms' => _NS_DCTERMS_,
			'gbif'    => _NS_GBIF_,	
		}
	);
					
	# iterate over the file locations
	for my $file ( map { $_->text } $core->first_child('files')->children('location') ) {
	
		# process an occurrences file
		$log->info("going to read file $file");
		my @header;
		my $record = 1;
		my $fdel   = $core->att('fieldsTerminatedBy');
		my $ldel   = $core->att('linesTerminatedBy');		
		LINE: for my $line ( split /$ldel/, _read_zip_member( $zip => $file ) ) {			
			my @fields = split /$fdel/, $line;			
			if ( not @header and $core->att('ignoreHeaderLines') == 1 ) {
				@header = _process_header( \@fields, $core, $taxa );
				next LINE;
			}
			$log->info("processing record " . $record++);
			_process_record( \@fields, \@header, $taxa );
		}								
	}
	return $taxa;
}

sub _process_record {
	my ( $fields, $header, $taxa ) = @_;

	# process the line
	my $occ = $fac->create_meta( '-triple' => { 'dwc:Occurrence' => undef } );
	FIELD: for my $i ( 0 .. $#{ $fields } ) {
		next FIELD if $fields->[$i] =~ /^$/;
		
		# create the meta object										
		my $pre = $header->[$i]->{'prefix'};
		my $ns  = $header->[$i]->{'namespace'};
		my $p   = $pre . ':' . $header->[$i]->{'predicate'};
		$occ->add_meta( $fac->create_meta( '-triple' => { $p => $fields->[$i] } ) );
		
		# fetch or create the taxon object
		if ( $p eq 'dwc:scientificName' ) {
			my $n = $fields->[$i];
			my $t = $taxa->get_by_name($n);
			if ( not $t ) {
				$log->info("creating taxon $n");
				$t = $fac->create_taxon( '-name' => $n );
				$taxa->insert($t);
			}
			$t->add_meta($occ);					
		}
	}
}

sub _process_header {
	my ( $fields, $core, $taxa ) = @_;
	my @header = @$fields;
	my $nsi = 1;
	$log->info("processing ".scalar(@header)." header columns");					
	
	# process the header fields
	for my $field ( $core->children('field') ) {
								
		# split the term in namespace and predicate
		my $term = $field->att('term');
		if ( $term =~ m/^(.+\/)([^\/]+)$/ ) {
			my ( $namespace, $predicate ) = ( $1, $2 );
			
			# generate namespace prefix
			my $p = $taxa->get_prefix_for_namespace($namespace);
			if ( not $p ) {
				$p = 'ns' . $nsi++;
				$taxa->set_namespaces( $p => $namespace );
				$log->info("created prefix $p for namespace $namespace");
			}
			
			# store namespace, predicate and prefix
			my $i = $field->att('index');
			$header[$i] = {
				'namespace' => $namespace,
				'predicate' => $predicate,
				'prefix'    => $p,
			};							
		}
	}
	return @header;
}

sub _read_zip_member {
	my ( $zip, $member_name ) = @_;
	
	# instantiate the named member object
	my $member = $zip->memberNamed( $member_name );
	$member->desiredCompressionMethod( COMPRESSION_STORED );
	
	# rewind to the start of the member
	my $status = $member->rewindData();
	if ( $status != AZ_OK ) {
		throw 'FileError' => "Can't rewind $member_name: $status";
	}
	
	# read buffered
	my $contents;
	while ( ! $member->readIsDone() ) {
		my ( $buffer_ref, $status ) = $member->readChunk();
		if ( $status != AZ_OK && $status != AZ_STREAM_END ) {
			throw 'FileError' => "Can't read chunk from $member_name: $status";
		}
		$contents .= $$buffer_ref
	}
	$member->endRead();
	return $contents;
}