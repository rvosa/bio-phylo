package Bio::Phylo::Util::CONSTANT;
use strict;
use base 'Exporter';
use Scalar::Util 'blessed';
use Bio::Phylo::Util::Exceptions 'throw';

BEGIN {
    our ( @EXPORT_OK, %EXPORT_TAGS );
    @EXPORT_OK = qw(
      _NONE_
      _NODE_
      _TREE_
      _FOREST_
      _TAXON_
      _TAXA_
      _CHAR_
      _DATUM_
      _MATRIX_
      _MATRICES_
      _SEQUENCE_
      _ALIGNMENT_
      _CHARSTATE_
      _CHARSTATESEQ_
      _MATRIXROW_
      _PROJECT_
      _ANNOTATION_
      _DICTIONARY_
      _DOMCREATOR_
      _META_
      _DESCRIPTION_
      _RESOURCE_
      _HTTP_SC_SEE_ALSO_
      _DOCUMENT_
      _ELEMENT_
      _CHARACTERS_
      _CHARACTER_
      _SET_
      _MODEL_
      _OPERATION_
      looks_like_number
      looks_like_object
      looks_like_hash
      looks_like_class
      looks_like_instance
      looks_like_implementor
      _NS_OWL_
      _NS_DC_
      _NS_DCTERMS_
      _NS_NEXML_
      _NS_RDF_
      _NS_RDFS_
      _NS_XSI_
      _NS_XSD_
      _NS_XML_
      _NS_TOL_
      _NS_CDAO_
      _NEXML_VERSION_
      _PI_
    );
    %EXPORT_TAGS = (
        'all'         => [@EXPORT_OK],
        'objecttypes' => [
            qw(
              _NONE_
              _NODE_
              _TREE_
              _FOREST_
              _TAXON_
              _TAXA_
              _CHAR_
              _DATUM_
              _MATRIX_
              _MATRICES_
              _SEQUENCE_
              _ALIGNMENT_
              _CHARSTATE_
              _CHARSTATESEQ_
              _MATRIXROW_
              _PROJECT_
              _ANNOTATION_
              _DICTIONARY_
              _DOMCREATOR_
              _META_
              _DESCRIPTION_
              _RESOURCE_
              _HTTP_SC_SEE_ALSO_
              _DOCUMENT_
              _ELEMENT_
              _CHARACTERS_
              _CHARACTER_
              _SET_
              _MODEL_
              _OPERATION_
              )
        ],
        'functions' => [
            qw(
              looks_like_number
              looks_like_object
              looks_like_hash
              looks_like_class
              looks_like_instance
              looks_like_implementor
              )
        ],
        'namespaces' => [
            qw(
              _NS_OWL_
              _NS_DC_
              _NS_DCTERMS_
              _NS_NEXML_
              _NS_RDF_
              _NS_RDFS_
              _NS_XSI_
              _NS_XSD_
              _NS_XML_
              _NS_TOL_
              _NS_CDAO_
              )
        ]
    );
}

# according to perlsub:
# "Functions with a prototype of () are potential candidates for inlining.
# If the result after optimization and constant folding is either a constant
# or a lexically-scoped scalar which has no other references, then it will
# be used in place of function calls made without & or do."
sub _NS_OWL_ ()     { 'http://www.w3.org/2002/07/owl#' }
sub _NS_DC_ ()      { 'http://purl.org/dc/elements/1.1/' }
sub _NS_DCTERMS_ () { 'http://purl.org/dc/terms/' }
sub _NS_NEXML_ ()   { 'http://www.nexml.org/2009' }
sub _NS_RDF_ ()     { 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' }
sub _NS_RDFS_ ()    { 'http://www.w3.org/2000/01/rdf-schema#' }
sub _NS_XSI_ ()     { 'http://www.w3.org/2001/XMLSchema-instance' }
sub _NS_XSD_ ()     { 'http://www.w3.org/2001/XMLSchema#' }
sub _NS_XML_ ()     { 'http://www.w3.org/XML/1998/namespace' }
sub _NS_TOL_ ()     { 'http://tolweb.org/tree/home.pages/downloadtree.html#' }
sub _NS_CDAO_ ()    { 'http://www.evolutionaryontology.org/cdao/1.0/cdao.owl#' }

sub _NEXML_VERSION_ () { '0.9' }
sub _NONE_ ()          { 1 }
sub _NODE_ ()          { 2 }
sub _TREE_ ()          { 3 }
sub _FOREST_ ()        { 4 }
sub _TAXON_ ()         { 5 }
sub _TAXA_ ()          { 6 }
sub _DATUM_ ()         { 7 }
sub _MATRIX_ ()        { 8 }
sub _MATRICES_ ()      { 9 }
sub _SEQUENCE_ ()      { 10 }
sub _ALIGNMENT_ ()     { 11 }
sub _CHAR_ ()          { 12 }
sub _PROJECT_ ()       { 9 }
sub _CHARSTATE_ ()     { 13 }
sub _CHARSTATESEQ_ ()  { 14 }
sub _MATRIXROW_ ()     { 15 }
sub _ANNOTATION_ ()    { 16 }
sub _DICTIONARY_ ()    { 17 }
sub _DOMCREATOR_ ()    { 18 }
sub _META_ ()          { 19 }
sub _DESCRIPTION_ ()   { 20 }
sub _RESOURCE_ ()      { 21 }
sub _DOCUMENT_ ()      { 22 }
sub _ELEMENT_ ()       { 23 }
sub _CHARACTERS_ ()    { 24 }
sub _CHARACTER_ ()     { 25 }
sub _SET_ ()           { 26 }
sub _MODEL_ ()         { 27 }
sub _OPERATION_ ()     { 28 }

# for PhyloWS
sub _HTTP_SC_SEE_ALSO_ () { '303 See Other' }

# for tree drawing
sub _PI_ () { 4 * atan2(1,1) }

# this is a drop in replacement for Scalar::Util's function
my $looks_like_number;
{
    eval { Scalar::Util::looks_like_number(0) };
    if ($@) {
        my $LOOKS_LIKE_NUMBER_RE =
          qr/^([-+]?\d+(\.\d+)?([eE][-+]\d+)?|Inf|NaN)$/;
        $looks_like_number = sub {
            my $num = shift;
            if ( defined $num and $num =~ $LOOKS_LIKE_NUMBER_RE ) {
                return 1;
            }
            else {
                return;
            }
          }
    }
    else {
        $looks_like_number = \&Scalar::Util::looks_like_number;
    }
    undef($@);
}
sub looks_like_number($) { return $looks_like_number->(shift) }

sub looks_like_object($$) {
    my ( $object, $constant ) = @_;
    my $type;
    eval { $type = $object->_type };
    if ( $@ or $type != $constant ) {
        throw 'ObjectMismatch' => 'Invalid object!';
    }
    else {
        return 1;
    }
}

sub looks_like_implementor($$) {
    return UNIVERSAL::can( $_[0], $_[1] );
}

sub looks_like_instance($$) {
    my ( $object, $class ) = @_;
    if ( ref $object ) {
        if ( blessed $object ) {
            return $object->isa($class);
        }
        else {
            return ref $object eq $class;
        }
    }
    else {
        return;
    }
}

sub looks_like_hash(@) {
    if ( scalar(@_) % 2 ) {
        throw 'OddHash' => 'Odd number of elements in hash assignment';
    }
    else {
        return @_;
    }
}

sub looks_like_class($) {
    my $class = shift;
    my $path  = $class;
    $path =~ s|::|/|g;
    $path .= '.pm';
    if ( not exists $INC{$path} ) {
        eval { require $path };
        if ($@) {
            throw 'ExtensionError' => $@;
        }
    }
    return $class;
}
1;
__END__

=head1 NAME

Bio::Phylo::Util::CONSTANT - Global constants and utility functions

=head1 DESCRIPTION

This package defines globals used in the Bio::Phylo libraries. The constants
are called internally by the other packages, they have no direct usage. In
addition, several useful subroutines are optionally exported, which are
described below.

=head1 SUBROUTINES

The following subroutines are utility functions that can be imported using:

 use Bio::Phylo::Util::CONSTANT ':functions';

The subroutines use prototypes for more concise syntax, e.g.:

 looks_like_number $num;
 looks_like_object $obj, $const;
 looks_like_hash @_;
 looks_like_class $class;

These subroutines are used for argument processing inside method calls.

=over

=item looks_like_instance()

Tests if argument 1 looks like an instance of argument 2

 Type    : Utility function
 Title   : looks_like_instance
 Usage   : do 'something' if looks_like_instance $var, $class;
 Function: Tests whether $var looks like an instance of $class.
 Returns : TRUE or undef
 Args    : $var = a variable to test, a $class to test against.
           $class can also be anything returned by ref($var), e.g.
           'HASH', 'CODE', etc.

=item looks_like_implementor()

Tests if argument 1 implements argument 2

 Type    : Utility function
 Title   : looks_like_implementor
 Usage   : do 'something' if looks_like_implementor $var, $method;
 Function: Tests whether $var implements $method
 Returns : return value of UNIVERSAL::can or undef
 Args    : $var = a variable to test, a $method to test against.

=item looks_like_number()

Tests if argument looks like a number.

 Type    : Utility function
 Title   : looks_like_number
 Usage   : do 'something' if looks_like_number $var;
 Function: Tests whether $var looks like a number.
 Returns : TRUE or undef
 Args    : $var = a variable to test

=item looks_like_object()

Tests if argument looks like an object of specified type constant.

 Type    : Utility function
 Title   : looks_like_object
 Usage   : do 'something' if looks_like_object $obj, $const;
 Function: Tests whether $obj looks like an object.
 Returns : TRUE or throws ObjectMismatch
 Args    : $obj   = an object to test
 		   $const = a constant as defined in this package

=item looks_like_hash()

Tests if argument looks like a hash.

 Type    : Utility function
 Title   : looks_like_hash
 Usage   : do 'something' if looks_like_hash @_;
 Function: Tests whether argument looks like a hash.
 Returns : hash (same order as arg) or throws OddHash
 Args    : An array of hopefully even key/value pairs

=item looks_like_class()

Tests if argument looks like a loadable class name.

 Type    : Utility function
 Title   : looks_like_class
 Usage   : do 'something' if looks_like_class $class;
 Function: Tests whether argument looks like a class.
 Returns : $class or throws ExtensionError
 Args    : A hopefully loadable class name

=back

=head1 SEE ALSO

=over

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>



=cut

