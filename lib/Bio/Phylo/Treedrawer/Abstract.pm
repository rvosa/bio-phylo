package Bio::Phylo::Treedrawer::Abstract;
use strict;
use Bio::Phylo::Util::Exceptions 'throw';
use Bio::Phylo::Util::Logger ':levels';

my $logger = Bio::Phylo::Util::Logger->new;
our $DEFAULT_FONT = 'Arial';
our @FONT_DIR;

=head1 NAME

Bio::Phylo::Treedrawer::Abstract - Abstract graphics writer used by treedrawer, no
serviceable parts inside

=head1 DESCRIPTION

This module is an abstract super class for the various graphics formats that 
Bio::Phylo supports. There is no direct usage of this class. Consult 
L<Bio::Phylo::Treedrawer> for documentation on how to draw trees.

=cut

sub _new {
    my $class = shift;
    my %args  = @_;
    my $self  = {
        'TREE'   => $args{'-tree'},
        'DRAWER' => $args{'-drawer'},
        'API'    => $args{'-api'},
    };
    return bless $self, $class;
}
sub _api    { shift->{'API'} }
sub _drawer { shift->{'DRAWER'} }
sub _tree   { shift->{'TREE'} }

=begin comment

 Type    : Internal method.
 Title   : _draw
 Usage   : $svg->_draw;
 Function: Main drawing method.
 Returns :
 Args    : None.

=end comment

=cut

sub _draw {
    my $self = shift;
    my $td   = $self->_drawer;
    $self->_tree->visit_depth_first(
        '-post' => sub {
            my $node        = shift;
            my $x           = $node->get_x;
            my $y           = $node->get_y;            
            my $is_terminal = $node->is_terminal;
            my $r = $is_terminal ? $td->get_tip_radius : $td->get_node_radius;
            $self->_draw_branch($node);
            if ( $node->get_collapsed ) {
                $self->_draw_collapsed($node);
            }
            else {
                if ( my $name = $node->get_name ) {
                    $name =~ s/_/ /g;
                    $name =~ s/^'(.*)'$/$1/;
                    $name =~ s/^"(.*)"$/$1/;
                    $self->_draw_text(
                        '-x'           => int( $x + $td->get_text_horiz_offset ),
                        '-y'           => int( $y + $td->get_text_vert_offset ),
                        '-text'        => $name,
                        '-rotation'    => [ $node->get_rotation, $x, $y ],
                        '-font_face'   => $node->get_font_face,
                        '-font_size'   => $node->get_font_size,
                        '-font_style'  => $node->get_font_style,
                        '-font_colour' => $node->get_font_colour,
                        'class'        => $is_terminal ? 'taxon_text' : 'node_text',
                    );
                }
            }
            $self->_draw_circle(
                '-radius' => $r,
                '-x'      => $x,
                '-y'      => $y,
                '-width'  => $node->get_branch_width,
                '-stroke' => $node->get_node_outline_colour,
                '-fill'   => $node->get_node_colour,
                '-url'    => $node->get_link,
            );
        }
    );
    $self->_draw_scale;
    $self->_draw_pies;
    $self->_draw_legend;
    return $self->_finish;
}

sub _draw_pies {
    my $self = shift;
    $logger->warn( ref($self) . " can't draw pies" );
}

sub _draw_legend {
    my $self = shift;
    $logger->warn( ref($self) . " can't draw a legend" );
}

sub _finish {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " won't complete its drawing";
}

sub _draw_text {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw text";
}

sub _draw_line {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw line";
}

sub _draw_arc {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw arc";    
}

sub _draw_curve {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw curve";
}

sub _draw_multi {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw multi line";
}

sub _draw_triangle {
    my $self = shift;
    throw 'NotImplemented' => ref($self) . " can't draw triangle";
}

sub _draw_collapsed {
    $logger->info("drawing collapsed node");
    my ( $self, $node ) = @_;
    my $td = $self->_drawer;
    $node->set_collapsed(0);

    # get the height of the tallest node inside the collapsed clade, for
    # cladograms this is 1, for phylograms it's the
    # sum of the branch lengths
    my $tallest = 0;
    my $clado = $td->get_mode =~ m/clado/i;
    if ( $clado ) {
        $tallest = 1;
    }
    else {
        $node->visit_depth_first(
            '-pre' => sub {
                my $n = shift;
                my $height = $n->get_parent->get_generic('height') + $n->get_branch_length;
                $n->set_generic( 'height' => $height );
                $tallest = $height if $height > $tallest;
            }
        );
    }
    
    if ( $clado ) {
        my ( $x1, $y1 ) = ( $node->get_x, $node->get_y );
        my $x2      = $node->get_x;
        my $padding = $td->get_padding;
        my $cladew  = $td->get_collapsed_clade_width($node);
        $self->_draw_triangle(
            '-x1'     => $node->get_x - $tallest * $td->_get_scalex,
            '-y1'     => $y1,
            '-x2'     => $x2,
            '-y2'     => $y1 + $cladew / 2.7 * $td->_get_scaley - $padding,
            '-x3'     => $x2,
            '-y3'     => $y1 - $cladew / 2.7 * $td->_get_scaley + $padding,
            '-fill'   => $node->get_node_colour,
            '-stroke' => $node->get_node_outline_colour,
            '-width'  => $td->get_branch_width($node),
            '-url'    => $node->get_link,
            'id'      => 'collapsed' . $node->get_id,
            'class'   => 'collapsed',
        );
        if ( my $name = $node->get_name ) {
            $name =~ s/_/ /g;
            $name =~ s/^'(.*)'$/$1/;
            $name =~ s/^"(.*)"$/$1/;
            $self->_draw_text(
                '-x'    => int( $x2 + $td->get_text_horiz_offset ),
                '-y'    => int( $y1 + $td->get_text_vert_offset ),
                '-text' => $name,
                'id'    => 'collapsed_text' . $node->get_id,
                'class' => 'collapsed_text',
                '-font_face'   => $node->get_font_face,
                '-font_size'   => $node->get_font_size,
                '-font_style'  => $node->get_font_style,
                '-font_colour' => $node->get_font_colour,                
            );
        }        
    }
    else {
        my ( $x1, $y1 ) = ( $node->get_x, $node->get_y );
        my $x2      = ( $tallest * $td->_get_scalex + $node->get_x );
        my $padding = $td->get_padding;
        my $cladew  = $td->get_collapsed_clade_width($node);
        $self->_draw_triangle(
            '-x1'     => $x1,
            '-y1'     => $y1,
            '-x2'     => $x2,
            '-y2'     => $y1 + $cladew / 2 * $td->_get_scaley - $padding,
            '-x3'     => $x2,
            '-y3'     => $y1 - $cladew / 2 * $td->_get_scaley + $padding,
            '-fill'   => $node->get_node_colour,
            '-stroke' => $node->get_node_outline_colour,
            '-width'  => $td->get_branch_width($node),
            '-url'    => $node->get_link,
            'id'      => 'collapsed' . $node->get_id,
            'class'   => 'collapsed',
        );
        if ( my $name = $node->get_name ) {
            $name =~ s/_/ /g;
            $name =~ s/^'(.*)'$/$1/;
            $name =~ s/^"(.*)"$/$1/;
            $self->_draw_text(
                '-x'    => int( $x2 + $td->get_text_horiz_offset ),
                '-y'    => int( $y1 + $td->get_text_vert_offset ),
                '-text' => $name,
                'id'    => 'collapsed_text' . $node->get_id,
                'class' => 'collapsed_text',
            );
        }
    }
    $node->set_collapsed(1);
}

=begin comment

 Type    : Internal method.
 Title   : _draw_scale
 Usage   : $svg->_draw_scale();
 Function: Draws scale for phylograms
 Returns :
 Args    : None

=end comment

=cut

sub _draw_scale {
    my $self    = shift;
    my $drawer  = $self->_drawer;
    my $tree    = $self->_tree;
    my $root    = $tree->get_root;
    my $rootx   = $root->get_x;
    my $height  = $drawer->get_height;
    my $options = $drawer->get_scale_options;
    if ($options) {
        my ( $major, $minor ) = ( $options->{'-major'}, $options->{'-minor'} );
        my $width = $options->{'-width'};
        if ( $width =~ m/^(\d+)%$/ ) {
            $width = ( $1 / 100 ) * ( $tree->get_tallest_tip->get_x - $rootx );
        }
        if ( my $units = $options->{'-units'} ) {
            # now we need to calculate how much each branch length unit (e.g.
            # substitutions) is in pixels. The $width then becomes the length
            # of one branch length unit in pixels times $units
            my $tt = $tree->get_tallest_tip;
            my $ttx = $tt->get_x;
            my $ptr = $tt->calc_path_to_root;
            my $unit_in_pixels = ( $ttx - $rootx ) / $ptr;
            $width = $units * $unit_in_pixels;
        }
        if ( $major =~ m/^(\d+)%$/ ) {
            $major = ( $1 / 100 ) * $width;
        }
        if ( $minor =~ m/^(\d+)%$/ ) {
            $minor = ( $1 / 100 ) * $width;
        }
        my $major_text  = 0;
        my $major_scale = ( $major / $width ) * $root->calc_max_path_to_tips;
        $self->_draw_line(
            '-x1'   => $rootx,
            '-y1'   => ( $height - 5 ),
            '-x2'   => $rootx + $width,
            '-y2'   => ( $height - 5 ),
            'class' => 'scale_bar',
        );
        $self->_draw_text(
            '-x'    => ( $rootx + $width + $drawer->get_text_horiz_offset ),
            '-y'    => ( $height - 5 ),
            '-text' => $options->{'-label'} || ' ',
            'class' => 'scale_label',
        );
        for ( my $i = $rootx ; $i <= ( $rootx + $width ) ; $i += $major ) {
            $self->_draw_line(
                '-x1'   => $i,
                '-y1'   => ( $height - 5 ),
                '-x2'   => $i,
                '-y2'   => ( $height - 25 ),
                'class' => 'scale_major',
            );
            $self->_draw_text(
                '-x'    => $i,
                '-y'    => ( $height - 35 ),
                '-text' => $major_text,
                'class' => 'major_label',
            );
            $major_text += $major_scale;
        }
        for ( my $i = $rootx ; $i <= ( $rootx + $width ) ; $i += $minor ) {
            next if not $i % $major;
            $self->_draw_line(
                '-x1'   => $i,
                '-y1'   => ( $height - 5 ),
                '-x2'   => $i,
                '-y2'   => ( $height - 15 ),
                'class' => 'scale_minor',
            );
        }
    }
}

=begin comment

 Type    : Internal method.
 Title   : _draw_branch
 Usage   : $svg->_draw_branch($node);
 Function: Draws internode between $node and $node->get_parent, if any
 Returns :
 Args    : 

=end comment

=cut

sub _draw_branch {
    my ( $self, $node ) = @_;
    $logger->info( "Drawing branch for " . $node->get_internal_name );
    if ( my $parent = $node->get_parent ) {
        my ( $x1, $x2 ) = ( int $parent->get_x, int $node->get_x );
        my ( $y1, $y2 ) = ( int $parent->get_y, int $node->get_y );
        my $shape = $self->_drawer->get_shape;
        my $drawer = '_draw_curve';
        if ( $shape =~ m/CURVY/i ) {
            $drawer = '_draw_curve';
        }
        elsif ( $shape =~ m/RECT/i ) {
            $drawer = '_draw_multi';
        }
        elsif ( $shape =~ m/DIAG/i ) {
            $drawer = '_draw_line';
        }
        elsif ( $shape =~ m/UNROOTED/i ) {
            $drawer = '_draw_line';
        }
        elsif ( $shape =~ m/RADIAL/i ) {
            return $self->_draw_radial_branch($node);
        }
        return $self->$drawer(
            '-x1'    => $x1,
            '-y1'    => $y1,
            '-x2'    => $x2,
            '-y2'    => $y2,
            '-width' => $self->_drawer->get_branch_width($node),
            '-color' => $node->get_branch_color
        );
    }
}

=begin comment

 Type    : Internal method.
 Title   : _draw_radial_branch
 Usage   : $svg->_draw_radial_branch($node);
 Function: Draws radial internode between $node and $node->get_parent, if any
 Returns :
 Args    : 

=end comment

=cut

sub _draw_radial_branch {
    my ( $self, $node ) = @_;
    
    if ( my $parent = $node->get_parent ) {
        my $td = $self->_drawer;
        my $center_x = $td->get_width / 2;
        my $center_y = $td->get_height / 2;
        my $width    = $td->get_branch_width($node);
    
        # first the straight piece up to the arc
        my ( $x1, $y1 ) = ( $node->get_x, $node->get_y );
        my $rotation = $node->get_rotation;        
        my $parent_radius = $parent->get_generic('radius');
        my ( $x2, $y2 ) = $td->polar_to_cartesian( $parent_radius, $rotation );
        $x2 += $center_x;
        $y2 += $center_y;
        $self->_draw_line(
            '-x1'      => $x1,
            '-y1'      => $y1,
            '-x2'      => $x2,
            '-y2'      => $y2,
            '-width'   => $width,
            '-color'   => $node->get_branch_color,
            '-linecap' => 'square'
        );
                    
        # then the arc
        my ( $x3, $y3 ) = ( $parent->get_x, $parent->get_y );
        if ( $parent->get_rotation < $rotation ) {
            ( $x2, $x3 ) = ( $x3, $x2 );
            ( $y2, $y3 ) = ( $y3, $y2 );
        }
        $self->_draw_arc(
            '-x1'      => $x2,
            '-y1'      => $y2,
            '-x2'      => $x3,
            '-y2'      => $y3,
            '-radius'  => $parent_radius,
            '-width'   => $width,
            '-color'   => $node->get_branch_color,
            '-linecap' => 'square'
        )
    }
}

sub _font_path {
    my $self = shift;
    my $font = shift || $DEFAULT_FONT;
    if ( $^O =~ /darwin/ ) {
        push @FONT_DIR, '/System/Library/Fonts', '/Library/Fonts';
    }
    elsif ( $^O =~ /linux/ ) {
        push @FONT_DIR, '/usr/share/fonts';
    }
    elsif ( $^O =~ /MSWin/ ) {
        push @FONT_DIR, $ENV{'WINDIR'} . '\Fonts';
    }
    else {
        $logger->warn("Don't know where fonts are on $^O");
    }
    for my $dir ( @FONT_DIR ) {
        if ( -e "${dir}/${font}.ttf" ) {
            return "${dir}/${font}.ttf";
        }
    }
    $logger->warn("Couldn't find font $font");
}

=head1 SEE ALSO

There is a mailing list at L<https://groups.google.com/forum/#!forum/bio-phylo> 
for any user or developer questions and discussions.

=over

=item L<Bio::Phylo::Treedrawer>

Treedrawer subclasses are called by the L<Bio::Phylo::Treedrawer> object. Look
there to learn how to create tree drawings.

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

1;
