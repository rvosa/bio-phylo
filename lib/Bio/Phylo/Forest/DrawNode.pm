package Bio::Phylo::Forest::DrawNode;
use strict;
use base 'Bio::Phylo::Forest::Node';
{

    # @fields array necessary for object destruction
    my @fields = \(
        my (
            %x,                 %y,               %radius,
            %tip_radius,        %node_colour,     %node_outline_colour,
            %node_shape,        %node_image,      %branch_color,
            %branch_shape,      %branch_width,    %branch_style,
            %collapsed,         %collapsed_width, %font_face,
            %font_size,         %font_style,      %font_color,      
            %text_horiz_offset, %text_vert_offset, %rotation
        )
    );

=head1 NAME

Bio::Phylo::Forest::DrawNode - Tree node with extra methods for tree drawing

=head1 SYNOPSIS

 # see Bio::Phylo::Forest::Node

=head1 DESCRIPTION

This module defines a node object and its methods. The node is fairly
syntactically rich in terms of navigation, and additional getters are provided to
further ease navigation from node to node. Typical first daughter -> next sister
traversal and recursion is possible, but there are also shrinkwrapped methods
that return for example all terminal descendants of the focal node, or all
internals, etc.

Node objects are inserted into tree objects, although technically the tree
object is only a container holding all the nodes together. Unless there are
orphans all nodes can be reached without recourse to the tree object.

In addition, this subclass of the default node object L<Bio::Phylo::Forest::Node>
has getters and setters for drawing trees and nodes, e.g. X/Y coordinates, font
and text attributes, etc.

=head1 METHODS

=head2 MUTATORS

=over

=item set_collapsed()

 Type    : Mutator
 Title   : set_collapsed
 Usage   : $node->set_collapsed(1);
 Function: Sets whether the node's descendants are shown as collapsed into a triangle
 Returns : $self
 Args    : true or false value

=cut

    sub set_collapsed {
        my ( $self, $collapsed ) = @_;
        my $id = $self->get_id;
        $collapsed{$id} = $collapsed;
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
        return $self;
    }

=item set_x()

 Type    : Mutator
 Title   : set_x
 Usage   : $node->set_x($x);
 Function: Sets x
 Returns : $self
 Args    : x

=cut

    sub set_x {
        my ( $self, $x ) = @_;
        #my $id = $self->get_id;
        #$x{$id} = $x;
        $self->set_meta_object( 'map:x' => $x );
        return $self;
    }

=item set_y()

 Type    : Mutator
 Title   : set_y
 Usage   : $node->set_y($y);
 Function: Sets y
 Returns : $self
 Args    : y

=cut

    sub set_y {
        my ( $self, $y ) = @_;
        #my $id = $self->get_id;
        #$y{$id} = $y;
        $self->set_meta_object( 'map:y' => $y );
        return $self;
    }

=item set_radius()

 Type    : Mutator
 Title   : set_radius
 Usage   : $node->set_radius($radius);
 Function: Sets radius
 Returns : $self
 Args    : radius

=cut

    sub set_radius {
        my ( $self, $radius ) = @_;
        my $id = $self->get_id;
        $radius{$id} = $radius;
        return $self;
    }
    *set_node_radius = \&set_radius;

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
        return $self;
    }

=item set_node_colour()

 Type    : Mutator
 Title   : set_node_colour
 Usage   : $node->set_node_colour($node_colour);
 Function: Sets node_colour
 Returns : $self
 Args    : node_colour

=cut

    sub set_node_colour {
        my ( $self, $node_colour ) = @_;
        my $id = $self->get_id;
        $node_colour{$id} = $node_colour;
        return $self;
    }
    *set_node_color = \&set_node_colour;

=item set_node_outline_colour()

 Type    : Mutator
 Title   : set_node_outline_colour
 Usage   : $node->set_node_outline_colour($node_outline_colour);
 Function: Sets node outline colour
 Returns : $self
 Args    : node_colour

=cut

    sub set_node_outline_colour {
        my ( $self, $node_colour ) = @_;
        my $id = $self->get_id;
        $node_outline_colour{$id} = $node_colour;
        return $self;
    }

=item set_node_shape()

 Type    : Mutator
 Title   : set_node_shape
 Usage   : $node->set_node_shape($node_shape);
 Function: Sets node_shape
 Returns : $self
 Args    : node_shape

=cut

    sub set_node_shape {
        my ( $self, $node_shape ) = @_;
        my $id = $self->get_id;
        $node_shape{$id} = $node_shape;
        return $self;
    }

=item set_node_image()

 Type    : Mutator
 Title   : set_node_image
 Usage   : $node->set_node_image($node_image);
 Function: Sets node_image
 Returns : $self
 Args    : node_image

=cut

    sub set_node_image {
        my ( $self, $node_image ) = @_;
        my $id = $self->get_id;
        $node_image{$id} = $node_image;
        return $self;
    }

=item set_branch_color()

 Type    : Mutator
 Title   : set_branch_color
 Usage   : $node->set_branch_color($branch_color);
 Function: Sets branch_color
 Returns : $self
 Args    : branch_color

=cut

    sub set_branch_color {
        my ( $self, $branch_color ) = @_;
        my $id = $self->get_id;
        $branch_color{$id} = $branch_color;
        return $self;
    }
    *set_branch_colour = \&set_branch_color;

=item set_branch_shape()

 Type    : Mutator
 Title   : set_branch_shape
 Usage   : $node->set_branch_shape($branch_shape);
 Function: Sets branch_shape
 Returns : $self
 Args    : branch_shape

=cut

    sub set_branch_shape {
        my ( $self, $branch_shape ) = @_;
        my $id = $self->get_id;
        $branch_shape{$id} = $branch_shape;
        return $self;
    }

=item set_branch_width()

 Type    : Mutator
 Title   : set_branch_width
 Usage   : $node->set_branch_width($branch_width);
 Function: Sets branch width
 Returns : $self
 Args    : branch_width

=cut

    sub set_branch_width {
        my ( $self, $branch_width ) = @_;
        my $id = $self->get_id;
        $branch_width{$id} = $branch_width;
        return $self;
    }

=item set_branch_style()

 Type    : Mutator
 Title   : set_branch_style
 Usage   : $node->set_branch_style($branch_style);
 Function: Sets branch style
 Returns : $self
 Args    : branch_style

=cut

    sub set_branch_style {
        my ( $self, $branch_style ) = @_;
        my $id = $self->get_id;
        $branch_style{$id} = $branch_style;
        return $self;
    }

=item set_font_face()

 Type    : Mutator
 Title   : set_font_face
 Usage   : $node->set_font_face($font_face);
 Function: Sets font_face
 Returns : $self
 Args    : font_face

=cut

    sub set_font_face {
        my ( $self, $font_face ) = @_;
        my $id = $self->get_id;
        $font_face{$id} = $font_face;
        return $self;
    }

=item set_font_size()

 Type    : Mutator
 Title   : set_font_size
 Usage   : $node->set_font_size($font_size);
 Function: Sets font_size
 Returns : $self
 Args    : font_size

=cut

    sub set_font_size {
        my ( $self, $font_size ) = @_;
        my $id = $self->get_id;
        $font_size{$id} = $font_size;
        return $self;
    }

=item set_font_style()

 Type    : Mutator
 Title   : set_font_style
 Usage   : $node->set_font_style($font_style);
 Function: Sets font_style
 Returns : $self
 Args    : font_style

=cut

    sub set_font_style {
        my ( $self, $font_style ) = @_;
        my $id = $self->get_id;
        $font_style{$id} = $font_style;
        return $self;
    }

=item set_font_colour()

 Type    : Mutator
 Title   : set_font_colour
 Usage   : $node->set_font_colour($color);
 Function: Sets font_colour
 Returns : font_colour
 Args    : A color, which, depending on the underlying tree drawer, can either
           be expressed as a word ('red'), a hex code ('#00CC00') or an rgb
           statement ('rgb(0,255,0)')

=cut
    
    sub set_font_colour {
        my ($self, $colour) = @_;
        my $id = $self->get_id;
        $font_color{$id} = $colour;
        return $self;
    }
    *set_font_color = \&set_font_colour;

=item set_text_horiz_offset()

 Type    : Mutator
 Title   : set_text_horiz_offset
 Usage   : $node->set_text_horiz_offset($text_horiz_offset);
 Function: Sets text_horiz_offset
 Returns : $self
 Args    : text_horiz_offset

=cut

    sub set_text_horiz_offset {
        my ( $self, $text_horiz_offset ) = @_;
        my $id = $self->get_id;
        $text_horiz_offset{$id} = $text_horiz_offset;
        return $self;
    }

=item set_text_vert_offset()

 Type    : Mutator
 Title   : set_text_vert_offset
 Usage   : $node->set_text_vert_offset($text_vert_offset);
 Function: Sets text_vert_offset
 Returns : $self
 Args    : text_vert_offset

=cut

    sub set_text_vert_offset {
        my ( $self, $text_vert_offset ) = @_;
        my $id = $self->get_id;
        $text_vert_offset{$id} = $text_vert_offset;
        return $self;
    }

=item set_rotation()

 Type    : Mutator
 Title   : set_rotation
 Usage   : $node->set_rotation($rotation);
 Function: Sets rotation
 Returns : $self
 Args    : rotation

=cut

    sub set_rotation {
        my ( $self, $rotation ) = @_;
        my $id = $self->get_id;
        $rotation{$id} = $rotation;
        return $self;
    }

=back

=head2 ACCESSORS

=over

=item get_collapsed()

 Type    : Mutator
 Title   : get_collapsed
 Usage   : something() if $node->get_collapsed();
 Function: Gets whether the node's descendants are shown as collapsed into a triangle
 Returns : true or false value
 Args    : NONE

=cut

    sub get_collapsed {
        my $self = shift;
        my $id   = $self->get_id;
        return $collapsed{$id};
    }

=item get_first_daughter()

Gets invocant's first daughter.

 Type    : Accessor
 Title   : get_first_daughter
 Usage   : my $f_daughter = $node->get_first_daughter;
 Function: Retrieves a node's leftmost daughter.
 Returns : Bio::Phylo::Forest::Node
 Args    : NONE

=cut

    sub get_first_daughter {
        my $self = shift;
        if ( $self->get_collapsed ) {
            return;
        }
        else {
            return $self->SUPER::get_first_daughter;
        }
    }

=item get_last_daughter()

Gets invocant's last daughter.

 Type    : Accessor
 Title   : get_last_daughter
 Usage   : my $l_daughter = $node->get_last_daughter;
 Function: Retrieves a node's rightmost daughter.
 Returns : Bio::Phylo::Forest::Node
 Args    : NONE

=cut

    sub get_last_daughter {
        my $self = shift;
        if ( $self->get_collapsed ) {
            return;
        }
        else {
            return $self->SUPER::get_last_daughter;
        }
    }

=item get_children()

Gets invocant's immediate children.

 Type    : Query
 Title   : get_children
 Usage   : my @children = @{ $node->get_children };
 Function: Returns an array reference of immediate
           descendants, ordered from left to right.
 Returns : Array reference of
           Bio::Phylo::Forest::Node objects.
 Args    : NONE

=cut

    sub get_children {
        my $self = shift;
        if ( $self->get_collapsed ) {
            return [];
        }
        else {
            return $self->SUPER::get_children;
        }
    }

=item get_x()

 Type    : Accessor
 Title   : get_x
 Usage   : my $x = $node->get_x();
 Function: Gets x
 Returns : x
 Args    : NONE

=cut

    sub get_x {
        #my $self = shift;
        #my $id   = $self->get_id;
        #return $x{$id};
        shift->get_meta_object('map:x');
    }

=item get_y()

 Type    : Accessor
 Title   : get_y
 Usage   : my $y = $node->get_y();
 Function: Gets y
 Returns : y
 Args    : NONE

=cut

    sub get_y {
        #my $self = shift;
        #my $id   = $self->get_id;
        #return $y{$id};
        shift->get_meta_object('map:y');
    }

=item get_radius()

 Type    : Accessor
 Title   : get_radius
 Usage   : my $radius = $node->get_radius();
 Function: Gets radius
 Returns : radius
 Args    : NONE

=cut

    sub get_radius {
        my $self = shift;
        my $id   = $self->get_id;
        return $radius{$id};
    }

=item get_node_colour()

 Type    : Accessor
 Title   : get_node_colour
 Usage   : my $node_colour = $node->get_node_colour();
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

=item get_node_outline_colour()

 Type    : Accessor
 Title   : get_node_outline_colour
 Usage   : my $node_outline_colour = $node->get_node_outline_colour();
 Function: Gets node outline colour
 Returns : node_colour
 Args    : NONE

=cut

    sub get_node_outline_colour {
        my $self = shift;
        my $id   = $self->get_id;
        return $node_outline_colour{$id};
    }

=item get_node_shape()

 Type    : Accessor
 Title   : get_node_shape
 Usage   : my $node_shape = $node->get_node_shape();
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
 Usage   : my $node_image = $node->get_node_image();
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
 Usage   : my $branch_color = $node->get_branch_color();
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
 Usage   : my $branch_shape = $node->get_branch_shape();
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
 Usage   : my $branch_width = $node->get_branch_width();
 Function: Gets branch_width
 Returns : branch_width
 Args    : NONE

=cut

    sub get_branch_width {
        my $self = shift;
        if ( my $node = shift ) {
            return $node->get_branch_width;
        }
        else {
            my $id = $self->get_id;
            return $branch_width{$id};
        }
    }

=item get_branch_style()

 Type    : Accessor
 Title   : get_branch_style
 Usage   : my $branch_style = $node->get_branch_style();
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
 Usage   : my $font_face = $node->get_font_face();
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
 Usage   : my $font_size = $node->get_font_size();
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
 Usage   : my $font_style = $node->get_font_style();
 Function: Gets font_style
 Returns : font_style
 Args    : NONE

=cut

    sub get_font_style {
        my $self = shift;
        my $id   = $self->get_id;
        return $font_style{$id};
    }

=item get_font_colour()

 Type    : Accessor
 Title   : get_font_colour
 Usage   : my $color = $node->get_font_colour();
 Function: Gets font_colour
 Returns : font_colour
 Args    : NONE

=cut
    
    sub get_font_colour {
        my $self = shift;
        my $id = $self->get_id;
        return $font_color{$id};
    }
    *get_font_color = \&get_font_colour;

=item get_text_horiz_offset()

 Type    : Accessor
 Title   : get_text_horiz_offset
 Usage   : my $text_horiz_offset = $node->get_text_horiz_offset();
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
 Usage   : my $text_vert_offset = $node->get_text_vert_offset();
 Function: Gets text_vert_offset
 Returns : text_vert_offset
 Args    : NONE

=cut

    sub get_text_vert_offset {
        my $self = shift;
        my $id   = $self->get_id;
        return $text_vert_offset{$id};
    }

=item get_rotation()

 Type    : Accessor
 Title   : get_rotation
 Usage   : my $rotation = $node->get_rotation();
 Function: Gets rotation
 Returns : rotation
 Args    : NONE

=cut

    sub get_rotation {
        my $self = shift;
        my $id   = $self->get_id;
        return $rotation{$id};
    }

=back

=head2 SERIALIZERS

=over

=item to_json()

Serializes object to JSON string

 Type    : Serializer
 Title   : to_json()
 Usage   : print $obj->to_json();
 Function: Serializes object to JSON string
 Returns : String 
 Args    : None
 Comments:

=cut

    sub to_json {
        my $node = shift;
        my %args = (
            'get_x'                 => 'x',
            'get_y'                 => 'y',
            'get_radius'            => 'radius',
            'get_node_colour'       => 'node_colour',
            'get_node_shape'        => 'node_shape',
            'get_node_image'        => 'image',
            'get_branch_color'      => 'branch_color',
            'get_branch_shape'      => 'branch_shape',
            'get_branch_width'      => 'width',
            'get_branch_style'      => 'style',
            'get_font_face'         => 'font_face',
            'get_font_size'         => 'font_size',
            'get_font_style'        => 'font_style',
            'get_link'              => 'link',
            'get_text_horiz_offset' => 'horiz_offset',
            'get_text_vert_offset'  => 'vert_offset',
        );
        return $node->SUPER::to_json(%args);
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

=item L<Bio::Phylo::Forest::Node>

This object inherits from L<Bio::Phylo::Forest::Node>, so methods
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
