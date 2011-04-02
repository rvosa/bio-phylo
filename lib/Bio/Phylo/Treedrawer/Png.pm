package Bio::Phylo::Treedrawer::Png;
use strict;
use base 'Bio::Phylo::Treedrawer::Abstract';
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::CONSTANT 'looks_like_hash';
use Bio::Phylo::Util::Dependency qw'GD::Simple GD::Polyline GD::Polygon GD';
use Bio::Phylo::Util::Logger;
my $logger = Bio::Phylo::Util::Logger->new;
my $PI     = '3.14159265358979323846';
my %colors;
my $whiteHex = 'FFFFFF';

=head1 NAME

Bio::Phylo::Treedrawer::Png - Graphics format writer used by treedrawer, no
serviceable parts inside

=head1 DESCRIPTION

This module creates a png file from a Bio::Phylo::Forest::DrawTree
object. It is called by the L<Bio::Phylo::Treedrawer> object, so look there to
learn how to create tree drawings.


=begin comment

 Type    : Constructor
 Title   : _new
 Usage   : my $pdf = Bio::Phylo::Treedrawer::Png->_new(%args);
 Function: Initializes a Bio::Phylo::Treedrawer::Png object.
 Alias   :
 Returns : A Bio::Phylo::Treedrawer::Png object.
 Args    : none.

=end comment

=cut

sub _hex2rgb ($) {
    my $hex = shift;
    my ( $r, $g, $b ) = ( 0, 0, 0 );
    if ( $hex =~ m/^(..)(..)(..)$/ ) {
        $r = hex($1);
        $g = hex($2);
        $b = hex($3);
    }
    return $r, $g, $b;
}

sub _new {
    my $class = shift;
    my %opt   = looks_like_hash @_;
    my $img   = GD::Simple->new(
        $opt{'-drawer'}->get_width,
        $opt{'-drawer'}->get_height,
    );
    my $white = $img->colorAllocate( 255, 255, 255 );
    $img->transparent($white);
    $img->interlaced('true');
    my $self = $class->SUPER::_new( %opt, '-api' => $img );
    return bless $self, $class;
}

=begin comment

# finish drawing

=end comment

=cut

sub _finish {
    $logger->debug("finishing drawing");
    my $self = shift;
    $self->_api->png;
}

=begin comment

# -x1 => $x1,
# -x2 => $x2,
# -y1 => $y1,
# -y2 => $y2,
# -width => $width,
# -color => $color

=end comment

=cut

sub _draw_curve {
    $logger->debug("drawing curved branch");
    my $self = shift;
    my %args = @_;
    my @keys = qw(-x1 -y1 -x2 -y2 -width -color -api);
    my ( $x1, $y1, $x3, $y3, $linewidth, $color, $api ) = @args{@keys};
    my ( $x2, $y2 ) = ( $x1, $y3 );
    my $poly = GD::Polyline->new();
    my $img = $api || $self->_api;
    $img->setThickness( $linewidth || 1 );
    $poly->addPt( $x1, $y1 );
    $poly->addPt( $x1, ( $y1 + $y3 ) / 2 );
    $poly->addPt( ( $x1 + $x3 ) / 2, $y3 );
    $poly->addPt( $x3, $y3 );
    $img->polydraw( $poly->toSpline(), $img->colorAllocate( _hex2rgb $color) );
}

=begin comment

# required:
# -x1 => $x1,
# -y1 => $y1,
# -x2 => $x2,
# -y2 => $y2,
# -x3 => $x3,
# -y3 => $y3,

# optional:
# -fill   => $fill,
# -stroke => $stroke,
# -width  => $width,
# -url    => $url,
# -api    => $api,

=end comment

=cut

sub _draw_triangle {
    my $self = shift;
    $logger->debug("drawing triangle @_");
    my %args = @_;
    my @keys = qw(-x1 -y1 -x2 -y2 -x3 -y3 -fill -stroke -width -url -api);
    my ( $x1, $y1, $x2, $y2, $x3, $y3, $fill, $stroke, $width, $url, $api ) =
      @args{@keys};
    if ($url) {
        $logger->warn( ref($self) . " can't embed links" );
    }
    my $img = $api || $self->_api;

    # create polygone
    my $poly = GD::Polygon->new();
    $poly->addPt( $x1, $y1 );
    $poly->addPt( $x2, $y2 );
    $poly->addPt( $x3, $y3 );
    $poly->addPt( $x1, $y1 );

    # set line thickness
    $img->setThickness( $width || 1 );

    # create stroke color
    my $strokeColorObj = $img->colorAllocate( _hex2rgb $stroke);

    # create fill color
    my $fillColorObj = $img->colorAllocate( _hex2rgb( $fill || $whiteHex ) );

    # draw polygon
    $img->polydraw( $poly, $strokeColorObj );

    # fill polygon
    $img->fill(
        ( ( $x1 + $x2 + $x3 ) / 3 ),
        ( ( $y1 + $y2 + $y3 ) / 3 ),
        $fillColorObj
    );
}

=begin comment

# -x1 => $x1,
# -x2 => $x2,
# -y1 => $y1,
# -y2 => $y2,
# -width => $width,
# -color => $color

=end comment

=cut

sub _draw_line {
    $logger->debug("drawing line");
    my $self = shift;
    my %args = @_;
    my @keys = qw(-x1 -y1 -x2 -y2 -width -color);
    my ( $x1, $y1, $x2, $y2, $width, $color ) = @args{@keys};
    my $img            = $self->_api;
    my $strokeColorObj = $img->colorAllocate( _hex2rgb $color);
    $img->setThickness( $width || 1 );
    $img->moveTo( $x1, $y1 );
    $img->lineTo( $x2, $y2 );
}

=begin comment

# -x1 => $x1,
# -x2 => $x2,
# -y1 => $y1,
# -y2 => $y2,
# -width => $width,
# -color => $color

=end comment

=cut

sub _draw_multi {
    $logger->debug("drawing multi line");
    my $self = shift;
    my %args = @_;
    my @keys = qw(-x1 -y1 -x2 -y2 -width -color);
    my ( $x1, $y1, $x3, $y3, $linewidth, $color ) = @args{@keys};
    my ( $x2, $y2 ) = ( $x1, $y3 );
    my $poly = GD::Polyline->new();
    $poly->addPt( $x1, $y1 );
    $poly->addPt( $x2, $y2 );
    $poly->addPt( $x3, $y3 );
    $self->_api->setThickness( $linewidth || 1 );
    my $colorObj = $self->_api->colorAllocate( _hex2rgb $color);
    $self->_api->polydraw( $poly, $colorObj );
}

=begin comment

# required:
# -x => $x,
# -y => $y,
# -text => $text,
#
# optional:
# -url  => $url,

=end comment

=cut

sub _draw_text {
    $logger->debug("drawing text");
    my $self = shift;
    my %args = @_;
    my ( $x, $y, $text, $url, $size ) = @args{qw(-x -y -text -url -size)};
    if ($url) {
        $logger->warn( ref($self) . " can't embed links" );
    }
    $self->_api->moveTo( $x, $y );
    $self->_api->fontsize( $size || 12 );
    $self->_api->string($text);
}

=begin comment

# -x => $x,
# -y => $y,
# -width  => $width,
# -stroke => $color,
# -radius => $radius,
# -fill   => $file,
# -api    => $api,
# -url    => $url,

=end comment

=cut

sub _draw_circle {
    $logger->debug("drawing circle");
    my $self = shift;
    my %args = @_;
    my @keys = qw(-x -y -width -stroke -radius -fill -api -url);
    my ( $x, $y, $width, $stroke, $radius, $fill, $api, $url ) = @args{@keys};
    my $height = $self->_drawer->get_height;
    if ($url) {
        $logger->warn( ref($self) . " can't embed links" );
    }
    my $img = $api || $self->_api;
    $img->fgcolor( $img->colorAllocate( _hex2rgb $stroke) );
    $img->bgcolor( $img->colorAllocate( _hex2rgb( $fill || $whiteHex ) ) );
    $img->moveTo( $x, $y );
    $img->ellipse( $radius, $radius );
}

=head1 SEE ALSO

=over

=item L<Bio::Phylo::Treedrawer>

The pdf treedrawer is called by the L<Bio::Phylo::Treedrawer> object. Look there
to learn how to create tree drawings.

=item L<Bio::Phylo::Manual>

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=back

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Png.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
1;
