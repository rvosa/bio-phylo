package Bio::Phylo::Forest::DrawTree;
use strict;
use base 'Bio::Phylo::Forest::Tree';
use Bio::Phylo::Forest::DrawNode;
use Bio::Phylo::Util::CONSTANT 'looks_like_hash';
{

    # @fields array necessary for object destruction
    my @fields = \(
        my (
            %width,             %height,         %node_radius,
            %tip_radius,        %node_colour,    %node_shape,
            %node_image,        %branch_color,   %branch_shape,
            %branch_width,      %branch_style,   %collapsed_width,
            %font_face,         %font_size,      %font_style,
            %margin,            %margin_top,     %margin_bottom,
            %margin_left,       %margin_right,   %padding,
            %padding_top,       %padding_bottom, %padding_left,
            %padding_right,     %mode,           %shape,
            %text_horiz_offset, %text_vert_offset,
        )
    );

=head1 NAME

Bio::Phylo::Forest::DrawTree - Tree with extra methods for tree drawing

=head1 SYNOPSIS

 # see Bio::Phylo::Forest::Tree

=head1 DESCRIPTION

The object models a phylogenetic tree, a container of Bio::Phylo::For-
est::Node objects. The tree object inherits from Bio::Phylo::Listable,
so look there for more methods.

In addition, this subclass of the default tree object L<Bio::Phylo::Forest::Tree>
has getters and setters for drawing trees, e.g. font and text attributes, etc.

=head1 METHODS

=head2 CONSTRUCTORS

=over

=item new()

Tree constructor.

 Type    : Constructor
 Title   : new
 Usage   : my $tree = Bio::Phylo::Forest::DrawTree->new;
 Function: Instantiates a Bio::Phylo::Forest::DrawTree object.
 Returns : A Bio::Phylo::Forest::DrawTree object.
 Args    : No required arguments.

=cut

    sub new {
        my $class = shift;
        my %args  = looks_like_hash @_;
        if ( not $args{'-tree'} ) {
            return $class->SUPER::new(@_);
        }
        else {
            my $tree = $args{'-tree'};
            my $self = $tree->clone;
            bless $self, $class;
            $self->visit( sub { bless shift, 'Bio::Phylo::Forest::DrawNode' } );
            delete $args{'-tree'};
            for my $key ( keys %args ) {
                my $method = $key;
                $method =~ s/^-/set_/;
                $self->$method( $args{$key} );
            }
            return $self;
        }
    }

=back

=head2 MUTATORS

=over

=item set_width()

 Type    : Mutator
 Title   : set_width
 Usage   : $tree->set_width($width);
 Function: Sets width
 Returns : $self
 Args    : width

=cut

    sub set_width {
        my ( $self, $width ) = @_;
        my $id = $self->get_id;
        $width{$id} = $width;
        $self->_redraw;
        return $self;
    }

=item set_height()

 Type    : Mutator
 Title   : set_height
 Usage   : $tree->set_height($height);
 Function: Sets height
 Returns : $self
 Args    : height

=cut

    sub set_height {
        my ( $self, $height ) = @_;
        my $id = $self->get_id;
        $height{$id} = $height;
        $self->_redraw;
        return $self;
    }

=item set_node_radius()

 Type    : Mutator
 Title   : set_node_radius
 Usage   : $tree->set_node_radius($node_radius);
 Function: Sets node_radius
 Returns : $self
 Args    : node_radius

=cut

    sub set_node_radius {
        my ( $self, $node_radius ) = @_;
        my $id = $self->get_id;
        $node_radius{$id} = $node_radius;
        $self->_apply_to_nodes( 'set_radius', $node_radius );
        return $self;
    }

=item set_tip_radius()

 Type    : Mutator
 Title   : set_tip_node_radius
 Usage   : $tree->set_tip_radius($node_radius);
 Function: Sets tip radius
 Returns : $self
 Args    : tip radius

=cut

    sub set_tip_radius {
        my ( $self, $r ) = @_;
        my $id = $self->get_id;
        $tip_radius{$id} = $r;
        $self->_apply_to_nodes( 'set_tip_radius', $r );
        return $self;
    }

=item set_node_colour()

 Type    : Mutator
 Title   : set_node_colour
 Usage   : $tree->set_node_colour($node_colour);
 Function: Sets node_colour
 Returns : $self
 Args    : node_colour

=cut

    sub set_node_colour {
        my ( $self, $node_colour ) = @_;
        my $id = $self->get_id;
        $node_colour{$id} = $node_colour;
        $self->_apply_to_nodes( 'set_node_colour', $node_colour );
        return $self;
    }
    *set_node_color = \&set_node_colour;

=item set_node_shape()

 Type    : Mutator
 Title   : set_node_shape
 Usage   : $tree->set_node_shape($node_shape);
 Function: Sets node_shape
 Returns : $self
 Args    : node_shape

=cut

    sub set_node_shape {
        my ( $self, $node_shape ) = @_;
        my $id = $self->get_id;
        $node_shape{$id} = $node_shape;
        $self->_apply_to_nodes( 'set_node_shape', $node_shape );
        return $self;
    }

=item set_node_image()

 Type    : Mutator
 Title   : set_node_image
 Usage   : $tree->set_node_image($node_image);
 Function: Sets node_image
 Returns : $self
 Args    : node_image

=cut

    sub set_node_image {
        my ( $self, $node_image ) = @_;
        my $id = $self->get_id;
        $node_image{$id} = $node_image;
        $self->_apply_to_nodes( 'set_node_image', $node_image );
        return $self;
    }

=item set_collapsed_clade_width()

Sets collapsed clade width.

 Type    : Mutator
 Title   : set_collapsed_clade_width
 Usage   : $tree->set_collapsed_clade_width(6);
 Function: sets the width of collapsed clade triangles relative to uncollapsed tips
 Returns :
 Args    : Positive number

=cut

    sub set_collapsed_clade_width {
        my ( $self, $width ) = @_;
        my $id = $self->get_id;
        $collapsed_width{$id} = $width;
        $self->_apply_to_nodes( 'set_collapsed_clade_width', $width );
        return $self;
    }

=item set_branch_color()

 Type    : Mutator
 Title   : set_branch_color
 Usage   : $tree->set_branch_color($branch_color);
 Function: Sets branch_color
 Returns : $self
 Args    : branch_color

=cut

    sub set_branch_color {
        my ( $self, $branch_color ) = @_;
        my $id = $self->get_id;
        $branch_color{$id} = $branch_color;
        $self->_apply_to_nodes( 'set_branch_color', $branch_color );
        return $self;
    }
    *set_branch_colour = \&set_branch_colour;

=item set_branch_shape()

 Type    : Mutator
 Title   : set_branch_shape
 Usage   : $tree->set_branch_shape($branch_shape);
 Function: Sets branch_shape
 Returns : $self
 Args    : branch_shape

=cut

    sub set_branch_shape {
        my ( $self, $branch_shape ) = @_;
        my $id = $self->get_id;
        $branch_shape{$id} = $branch_shape;
        $self->_apply_to_nodes( 'set_branch_shape', $branch_shape );
        return $self;
    }

=item set_branch_width()

 Type    : Mutator
 Title   : set_branch_width
 Usage   : $tree->set_branch_width($branch_width);
 Function: Sets branch width
 Returns : $self
 Args    : branch_width

=cut

    sub set_branch_width {
        my ( $self, $branch_width ) = @_;
        my $id = $self->get_id;
        $branch_width{$id} = $branch_width;
        $self->_apply_to_nodes( 'set_branch_width', $branch_width );
        return $self;
    }

=item set_branch_style()

 Type    : Mutator
 Title   : set_branch_style
 Usage   : $tree->set_branch_style($branch_style);
 Function: Sets branch style
 Returns : $self
 Args    : branch_style

=cut

    sub set_branch_style {
        my ( $self, $branch_style ) = @_;
        my $id = $self->get_id;
        $branch_style{$id} = $branch_style;
        $self->_apply_to_nodes( 'set_branch_style', $branch_style );
        return $self;
    }

=item set_font_face()

 Type    : Mutator
 Title   : set_font_face
 Usage   : $tree->set_font_face($font_face);
 Function: Sets font_face
 Returns : $self
 Args    : font face, Verdana, Arial, Serif

=cut

    sub set_font_face {
        my ( $self, $font_face ) = @_;
        my $id = $self->get_id;
        $font_face{$id} = $font_face;
        $self->_apply_to_nodes( 'set_font_face', $font_face );
        return $self;
    }

=item set_font_size()

 Type    : Mutator
 Title   : set_font_size
 Usage   : $tree->set_font_size($font_size);
 Function: Sets font_size
 Returns : $self
 Args    : Font size in pixels

=cut

    sub set_font_size {
        my ( $self, $font_size ) = @_;
        my $id = $self->get_id;
        $font_size{$id} = $font_size;
        $self->_apply_to_nodes( 'set_font_size', $font_size );
        return $self;
    }

=item set_font_style()

 Type    : Mutator
 Title   : set_font_style
 Usage   : $tree->set_font_style($font_style);
 Function: Sets font_style
 Returns : $self
 Args    : Font style, e.g. Italic

=cut

    sub set_font_style {
        my ( $self, $font_style ) = @_;
        my $id = $self->get_id;
        $font_style{$id} = $font_style;
        $self->_apply_to_nodes( 'set_font_style', $font_style );
        return $self;
    }

=item set_margin()

 Type    : Mutator
 Title   : set_margin
 Usage   : $tree->set_margin($margin);
 Function: Sets margin
 Returns : $self
 Args    : margin

=cut

    sub set_margin {
        my ( $self, $margin ) = @_;
        my $id = $self->get_id;
        $margin{$id} = $margin;
        for my $setter (qw(top bottom left right)) {
            my $method = 'set_margin_' . $setter;
            $self->$method($margin);
        }
        $self->_redraw;
        return $self;
    }

=item set_margin_top()

 Type    : Mutator
 Title   : set_margin_top
 Usage   : $tree->set_margin_top($margin_top);
 Function: Sets margin_top
 Returns : $self
 Args    : margin_top

=cut

    sub set_margin_top {
        my ( $self, $margin_top ) = @_;
        my $id = $self->get_id;
        $margin_top{$id} = $margin_top;
        $self->_redraw;
        return $self;
    }

=item set_margin_bottom()

 Type    : Mutator
 Title   : set_margin_bottom
 Usage   : $tree->set_margin_bottom($margin_bottom);
 Function: Sets margin_bottom
 Returns : $self
 Args    : margin_bottom

=cut

    sub set_margin_bottom {
        my ( $self, $margin_bottom ) = @_;
        my $id = $self->get_id;
        $margin_bottom{$id} = $margin_bottom;
        $self->_redraw;
        return $self;
    }

=item set_margin_left()

 Type    : Mutator
 Title   : set_margin_left
 Usage   : $tree->set_margin_left($margin_left);
 Function: Sets margin_left
 Returns : $self
 Args    : margin_left

=cut

    sub set_margin_left {
        my ( $self, $margin_left ) = @_;
        my $id = $self->get_id;
        $margin_left{$id} = $margin_left;
        $self->_redraw;
        return $self;
    }

=item set_margin_right()

 Type    : Mutator
 Title   : set_margin_right
 Usage   : $tree->set_margin_right($margin_right);
 Function: Sets margin_right
 Returns : $self
 Args    : margin_right

=cut

    sub set_margin_right {
        my ( $self, $margin_right ) = @_;
        my $id = $self->get_id;
        $margin_right{$id} = $margin_right;
        $self->_redraw;
        return $self;
    }

=item set_padding()

 Type    : Mutator
 Title   : set_padding
 Usage   : $tree->set_padding($padding);
 Function: Sets padding
 Returns : $self
 Args    : padding

=cut

    sub set_padding {
        my ( $self, $padding ) = @_;
        my $id = $self->get_id;
        $padding{$id} = $padding;
        for my $setter (qw(top bottom left right)) {
            my $method = 'set_padding_' . $setter;
            $self->$method($padding);
        }
        $self->_redraw;
        return $self;
    }

=item set_padding_top()

 Type    : Mutator
 Title   : set_padding_top
 Usage   : $tree->set_padding_top($padding_top);
 Function: Sets padding_top
 Returns : $self
 Args    : padding_top

=cut

    sub set_padding_top {
        my ( $self, $padding_top ) = @_;
        my $id = $self->get_id;
        $padding_top{$id} = $padding_top;
        $self->_redraw;
        return $self;
    }

=item set_padding_bottom()

 Type    : Mutator
 Title   : set_padding_bottom
 Usage   : $tree->set_padding_bottom($padding_bottom);
 Function: Sets padding_bottom
 Returns : $self
 Args    : padding_bottom

=cut

    sub set_padding_bottom {
        my ( $self, $padding_bottom ) = @_;
        my $id = $self->get_id;
        $padding_bottom{$id} = $padding_bottom;
        $self->_redraw;
        return $self;
    }

=item set_padding_left()

 Type    : Mutator
 Title   : set_padding_left
 Usage   : $tree->set_padding_left($padding_left);
 Function: Sets padding_left
 Returns : $self
 Args    : padding_left

=cut

    sub set_padding_left {
        my ( $self, $padding_left ) = @_;
        my $id = $self->get_id;
        $padding_left{$id} = $padding_left;
        $self->_redraw;
        return $self;
    }

=item set_padding_right()

 Type    : Mutator
 Title   : set_padding_right
 Usage   : $tree->set_padding_right($padding_right);
 Function: Sets padding_right
 Returns : $self
 Args    : padding_right

=cut

    sub set_padding_right {
        my ( $self, $padding_right ) = @_;
        my $id = $self->get_id;
        $padding_right{$id} = $padding_right;
        $self->_redraw;
        return $self;
    }

=item set_mode()

 Type    : Mutator
 Title   : set_mode
 Usage   : $tree->set_mode($mode);
 Function: Sets mode
 Returns : $self
 Args    : mode, e.g. 'CLADO' or 'PHYLO'

=cut

    sub set_mode {
        my ( $self, $mode ) = @_;
        my $id = $self->get_id;
        $mode{$id} = $mode;
        $self->_redraw;
        return $self;
    }

=item set_shape()

 Type    : Mutator
 Title   : set_shape
 Usage   : $tree->set_shape($shape);
 Function: Sets shape
 Returns : $self
 Args    : shape, e.g. 'RECT', 'CURVY', 'DIAG'

=cut

    sub set_shape {
        my ( $self, $shape ) = @_;
        my $id = $self->get_id;
        $shape{$id} = $shape;
        return $self;
    }

=item set_text_horiz_offset()

 Type    : Mutator
 Title   : set_text_horiz_offset
 Usage   : $tree->set_text_horiz_offset($text_horiz_offset);
 Function: Sets text_horiz_offset
 Returns : $self
 Args    : text_horiz_offset

=cut

    sub set_text_horiz_offset {
        my ( $self, $text_horiz_offset ) = @_;
        my $id = $self->get_id;
        $text_horiz_offset{$id} = $text_horiz_offset;
        $self->_apply_to_nodes( 'set_text_horiz_offset', $text_horiz_offset );
        return $self;
    }

=item set_text_vert_offset()

 Type    : Mutator
 Title   : set_text_vert_offset
 Usage   : $tree->set_text_vert_offset($text_vert_offset);
 Function: Sets text_vert_offset
 Returns : $self
 Args    : text_vert_offset

=cut

    sub set_text_vert_offset {
        my ( $self, $text_vert_offset ) = @_;
        my $id = $self->get_id;
        $text_vert_offset{$id} = $text_vert_offset;
        $self->_apply_to_nodes( 'set_text_vert_offset', $text_vert_offset );
        return $self;
    }

=back

=head2 ACCESSORS

=over

=item get_width()

 Type    : Accessor
 Title   : get_width
 Usage   : my $width = $tree->get_width();
 Function: Gets width
 Returns : width
 Args    : NONE

=cut

    sub get_width {
        my $self = shift;
        my $id   = $self->get_id;
        return $width{$id};
    }

=item get_height()

 Type    : Accessor
 Title   : get_height
 Usage   : my $height = $tree->get_height();
 Function: Gets height
 Returns : height
 Args    : NONE

=cut

    sub get_height {
        my $self = shift;
        my $id   = $self->get_id;
        return $height{$id};
    }

=item get_node_radius()

 Type    : Accessor
 Title   : get_node_radius
 Usage   : my $node_radius = $tree->get_node_radius();
 Function: Gets node_radius
 Returns : node_radius
 Args    : NONE

=cut

    sub get_node_radius {
        my $self = shift;
        my $id   = $self->get_id;
        return $node_radius{$id};
    }

=item get_node_colour()

 Type    : Accessor
 Title   : get_node_colour
 Usage   : my $node_colour = $tree->get_node_colour();
 Function: Gets node_colour
 Returns : node_colour
 Args    : NONE

=cut

    sub get_node_colour {
        my $self = shift;
        my $id   = $self->get_id;
        return $node_colour{$id};
    }
    *get_node_color = \&get_node_colour;

=item get_node_shape()

 Type    : Accessor
 Title   : get_node_shape
 Usage   : my $node_shape = $tree->get_node_shape();
 Function: Gets node_shape
 Returns : node_shape
 Args    : NONE

=cut

    sub get_node_shape {
        my $self = shift;
        my $id   = $self->get_id;
        return $node_shape{$id};
    }

=item get_node_image()

 Type    : Accessor
 Title   : get_node_image
 Usage   : my $node_image = $tree->get_node_image();
 Function: Gets node_image
 Returns : node_image
 Args    : NONE

=cut

    sub get_node_image {
        my $self = shift;
        my $id   = $self->get_id;
        return $node_image{$id};
    }

=item get_collapsed_clade_width()

Gets collapsed clade width.

 Type    : Mutator
 Title   : get_collapsed_clade_width
 Usage   : $w = $tree->get_collapsed_clade_width();
 Function: gets the width of collapsed clade triangles relative to uncollapsed tips
 Returns : Positive number
 Args    : None

=cut

    sub get_collapsed_clade_width {
        my $self = shift;
        my $id   = $self->get_id;
        return $collapsed_width{$id};
    }

=item get_branch_color()

 Type    : Accessor
 Title   : get_branch_color
 Usage   : my $branch_color = $tree->get_branch_color();
 Function: Gets branch_color
 Returns : branch_color
 Args    : NONE

=cut

    sub get_branch_color {
        my $self = shift;
        my $id   = $self->get_id;
        return $branch_color{$id};
    }
    *get_branch_colour = \&get_branch_color;

=item get_branch_shape()

 Type    : Accessor
 Title   : get_branch_shape
 Usage   : my $branch_shape = $tree->get_branch_shape();
 Function: Gets branch_shape
 Returns : branch_shape
 Args    : NONE

=cut

    sub get_branch_shape {
        my $self = shift;
        my $id   = $self->get_id;
        return $branch_shape{$id};
    }

=item get_branch_width()

 Type    : Accessor
 Title   : get_branch_width
 Usage   : my $branch_width = $tree->get_branch_width();
 Function: Gets branch_width
 Returns : branch_width
 Args    : NONE

=cut

    sub get_branch_width {
        my $self = shift;
        my $id   = $self->get_id;
        return $branch_width{$id};
    }

=item get_branch_style()

 Type    : Accessor
 Title   : get_branch_style
 Usage   : my $branch_style = $tree->get_branch_style();
 Function: Gets branch_style
 Returns : branch_style
 Args    : NONE

=cut

    sub get_branch_style {
        my $self = shift;
        my $id   = $self->get_id;
        return $branch_style{$id};
    }

=item get_font_face()

 Type    : Accessor
 Title   : get_font_face
 Usage   : my $font_face = $tree->get_font_face();
 Function: Gets font_face
 Returns : font_face
 Args    : NONE

=cut

    sub get_font_face {
        my $self = shift;
        my $id   = $self->get_id;
        return $font_face{$id};
    }

=item get_font_size()

 Type    : Accessor
 Title   : get_font_size
 Usage   : my $font_size = $tree->get_font_size();
 Function: Gets font_size
 Returns : font_size
 Args    : NONE

=cut

    sub get_font_size {
        my $self = shift;
        my $id   = $self->get_id;
        return $font_size{$id};
    }

=item get_font_style()

 Type    : Accessor
 Title   : get_font_style
 Usage   : my $font_style = $tree->get_font_style();
 Function: Gets font_style
 Returns : font_style
 Args    : NONE

=cut

    sub get_font_style {
        my $self = shift;
        my $id   = $self->get_id;
        return $font_style{$id};
    }

=item get_margin()

 Type    : Accessor
 Title   : get_margin
 Usage   : my $margin = $tree->get_margin();
 Function: Gets margin
 Returns : margin
 Args    : NONE

=cut

    sub get_margin {
        my $self = shift;
        my $id   = $self->get_id;
        return $margin{$id};
    }

=item get_margin_top()

 Type    : Accessor
 Title   : get_margin_top
 Usage   : my $margin_top = $tree->get_margin_top();
 Function: Gets margin_top
 Returns : margin_top
 Args    : NONE

=cut

    sub get_margin_top {
        my $self = shift;
        my $id   = $self->get_id;
        return $margin_top{$id};
    }

=item get_margin_bottom()

 Type    : Accessor
 Title   : get_margin_bottom
 Usage   : my $margin_bottom = $tree->get_margin_bottom();
 Function: Gets margin_bottom
 Returns : margin_bottom
 Args    : NONE

=cut

    sub get_margin_bottom {
        my $self = shift;
        my $id   = $self->get_id;
        return $margin_bottom{$id};
    }

=item get_margin_left()

 Type    : Accessor
 Title   : get_margin_left
 Usage   : my $margin_left = $tree->get_margin_left();
 Function: Gets margin_left
 Returns : margin_left
 Args    : NONE

=cut

    sub get_margin_left {
        my $self = shift;
        my $id   = $self->get_id;
        return $margin_left{$id};
    }

=item get_margin_right()

 Type    : Accessor
 Title   : get_margin_right
 Usage   : my $margin_right = $tree->get_margin_right();
 Function: Gets margin_right
 Returns : margin_right
 Args    : NONE

=cut

    sub get_margin_right {
        my $self = shift;
        my $id   = $self->get_id;
        return $margin_right{$id};
    }

=item get_padding()

 Type    : Accessor
 Title   : get_padding
 Usage   : my $padding = $tree->get_padding();
 Function: Gets padding
 Returns : padding
 Args    : NONE

=cut

    sub get_padding {
        my $self = shift;
        my $id   = $self->get_id;
        return $padding{$id};
    }

=item get_padding_top()

 Type    : Accessor
 Title   : get_padding_top
 Usage   : my $padding_top = $tree->get_padding_top();
 Function: Gets padding_top
 Returns : padding_top
 Args    : NONE

=cut

    sub get_padding_top {
        my $self = shift;
        my $id   = $self->get_id;
        return $padding_top{$id};
    }

=item get_padding_bottom()

 Type    : Accessor
 Title   : get_padding_bottom
 Usage   : my $padding_bottom = $tree->get_padding_bottom();
 Function: Gets padding_bottom
 Returns : padding_bottom
 Args    : NONE

=cut

    sub get_padding_bottom {
        my $self = shift;
        my $id   = $self->get_id;
        return $padding_bottom{$id};
    }

=item get_padding_left()

 Type    : Accessor
 Title   : get_padding_left
 Usage   : my $padding_left = $tree->get_padding_left();
 Function: Gets padding_left
 Returns : padding_left
 Args    : NONE

=cut

    sub get_padding_left {
        my $self = shift;
        my $id   = $self->get_id;
        return $padding_left{$id};
    }

=item get_padding_right()

 Type    : Accessor
 Title   : get_padding_right
 Usage   : my $padding_right = $tree->get_padding_right();
 Function: Gets padding_right
 Returns : padding_right
 Args    : NONE

=cut

    sub get_padding_right {
        my $self = shift;
        my $id   = $self->get_id;
        return $padding_right{$id};
    }

=item get_mode()

 Type    : Accessor
 Title   : get_mode
 Usage   : my $mode = $tree->get_mode();
 Function: Gets mode
 Returns : mode
 Args    : NONE

=cut

    sub get_mode {
        my $self = shift;
        my $id   = $self->get_id;
        if ( $self->is_cladogram ) {
            $mode{$id} = 'CLADO';
        }
        return $mode{$id};
    }

=item get_shape()

 Type    : Accessor
 Title   : get_shape
 Usage   : my $shape = $tree->get_shape();
 Function: Gets shape
 Returns : shape
 Args    : NONE

=cut

    sub get_shape {
        my $self = shift;
        my $id   = $self->get_id;
        return $shape{$id};
    }

=item get_text_horiz_offset()

 Type    : Accessor
 Title   : get_text_horiz_offset
 Usage   : my $text_horiz_offset = $tree->get_text_horiz_offset();
 Function: Gets text_horiz_offset
 Returns : text_horiz_offset
 Args    : NONE

=cut

    sub get_text_horiz_offset {
        my $self = shift;
        my $id   = $self->get_id;
        return $text_horiz_offset{$id};
    }

=item get_text_vert_offset()

 Type    : Accessor
 Title   : get_text_vert_offset
 Usage   : my $text_vert_offset = $tree->get_text_vert_offset();
 Function: Gets text_vert_offset
 Returns : text_vert_offset
 Args    : NONE

=cut

    sub get_text_vert_offset {
        my $self = shift;
        my $id   = $self->get_id;
        return $text_vert_offset{$id};
    }

=begin comment

This method re-computes the node coordinates

=end comment

=cut

    sub _redraw {
        my $self = shift;
        my ( $width, $height ) = ( $self->get_width, $self->get_height );
        my $tips_seen  = 0;
        my $total_tips = $self->calc_number_of_terminals();
        my $tallest    = $self->get_root->calc_max_path_to_tips;
        my $maxnodes   = $self->get_root->calc_max_nodes_to_tips;
        my $is_clado   = $self->get_mode =~ m/^c/i;
        $self->visit_depth_first(
            '-post' => sub {
                my $node = shift;
                my ( $x, $y );
                if ( $node->is_terminal ) {
                    $tips_seen++;
                    $y = ( $height / $total_tips ) * $tips_seen;
                    $x =
                        $is_clado
                      ? $width
                      : ( $width / $tallest ) * $node->calc_path_to_root;
                }
                else {
                    my @children = @{ $node->get_children };
                    $y += $_->get_y for @children;
                    $y /= scalar @children;
                    $x =
                        $is_clado
                      ? $width -
                      ( ( $width / $maxnodes ) * $node->calc_max_nodes_to_tips )
                      : ( $width / $tallest ) * $node->calc_path_to_root;
                }
                $node->set_y($y);
                $node->set_x($x);
            }
        );
    }

=begin comment

This method applies settings for nodes globally.

=end comment

=cut

    sub _apply_to_nodes {
        my ( $self, $method, $value ) = @_;
        $self->visit( sub { shift->$method($value) } );
    }

=begin comment

 Type    : Internal method
 Title   : _cleanup
 Usage   : $trees->_cleanup;
 Function: Called during object destruction, for cleanup of instance data
 Returns : 
 Args    :

=end comment

=cut

    sub _cleanup {
        my $self = shift;
        my $id   = $self->get_id;
        for my $field (@fields) {
            delete $field->{$id};
        }
    }

=back

=cut

    # podinherit_insert_token

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::Forest::Tree>

This object inherits from L<Bio::Phylo::Forest::Tree>, so methods
defined there are also applicable here.

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

}
1;
