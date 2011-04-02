package Bio::Phylo::Util::Logger;
use strict;
use base 'Exporter';
use File::Spec;

#use Filter::Simple;
use Bio::Phylo::Util::CONSTANT qw'looks_like_hash looks_like_instance';
use Bio::Phylo::Util::Exceptions 'throw';
use Config;
our ( $volume, $class_dir, $file, $VERBOSE, $AUTOLOAD, $TRACEBACK, @EXPORT_OK,
    %EXPORT_TAGS );

BEGIN {
    @EXPORT_OK = qw(DEBUG INFO WARN ERROR FATAL);
    %EXPORT_TAGS = ( 'levels' => [@EXPORT_OK] );
    my $class_file = __FILE__;
    ( $volume, $class_dir, $file ) = File::Spec->splitpath($class_file);

    # By default, the logger formats its messages to show where the logging
    # method (i.e. debug, info, warn, error or fatal) was called, (e.g in
    # the synopsis the $logger->info method was called in Bio/Phylo.pm on
    # line 280). However, in some cases you may want to have the message be
    # formatted to originate earlier in the call stack. An example of
    # this is in Bio::Phylo::Util::Exceptions, which calls $logger->error
    # automatically every time an exception is thrown. This behaviour would
    # not be very useful if the resulting message is shown to originate from
    # within the "throw" method - so instead it seems to originate from
    # where the exception was thrown, i.e. one frame up in the call stack.
    # This behaviour can be achieved by changing the value of the
    # $Bio::Phylo::Util::Logger::TRACEBACK variable. For each increment in
    # that variable, the logger moves one frame up in the call stack.
    $TRACEBACK = 0;
    $class_dir =~ s/Bio.Phylo.Util.?$//;

#	printf STDERR "[ %s starting, will use PREFIX=%s where applicable ]\n", __PACKAGE__, $class_dir;
}
{
    my $self;
    my %VERBOSE;
    my @listeners;
    my ( $fatal, $error, $warn, $info, $debug ) = ( 0 .. 4 );
    $VERBOSE = $warn;
    for my $method (qw(fatal error warn info debug)) {
        eval <<"CODE_TEMPLATE";
	sub $method {
		my ( \$self, \$msg ) = \@_;
		my ( \$package, \$file1up, \$line1up, \$subroutine ) = caller( \$TRACEBACK + 1 );
		my ( \$pack0up, \$filename, \$line, \$sub0up )       = caller( \$TRACEBACK + 0 );
		my \$verbosity;
		if ( exists \$VERBOSE{\$subroutine} ) {
 			\$verbosity = \$VERBOSE{\$subroutine};
 		}
 		elsif ( exists \$VERBOSE{\$pack0up} ) {
 			\$verbosity = \$VERBOSE{\$pack0up};
 		}
 		else {
 			\$verbosity = \$VERBOSE;
 		}		
		if ( \$verbosity >= \$${method} ) {			
			my \$log_string;
			if ( substr(\$filename,0,length(\$class_dir)) eq \$class_dir ) {
				\$log_string = sprintf( "%s %s [\\\$PREFIX/%s, %s] - %s\\n",
				uc("$method"), \$subroutine, substr(\$filename,length(\$class_dir)), \$line, \$msg );
			}
			else {
				\$log_string = sprintf( "%s %s [%s, %s] - %s\\n",
				uc("$method"), \$subroutine, \$filename, \$line, \$msg );			
			}
			print STDERR \$log_string;
			\$_->( \$log_string, uc("$method"), \$subroutine, \$filename, \$line, \$msg ) for \@listeners;
		}
		return \$self;	
	}	
CODE_TEMPLATE
    }

    sub new {
        my $package = shift;

        # singleton object
        if ( not $self ) {
            $self = \$package;
            bless $self, $package;
        }

        # process args
        $self->VERBOSE(@_) if @_;

        # done
        return $self;
    }

    sub set_listeners {
        my ( $self, @args ) = @_;
        for my $arg (@args) {
            if ( looks_like_instance $arg, 'CODE' ) {
                push @listeners, $arg;
            }
            else {
                throw 'BadArgs' => "$arg not a CODE reference";
            }
        }
        return $self;
    }

    sub PREFIX {
        my ( $self, $prefix ) = @_;
        $class_dir = $prefix if $prefix;
        return $class_dir;
    }

    sub VERBOSE {
        my $self = shift;
        if (@_) {
            my %opt = looks_like_hash @_;
            if ( defined $opt{'-level'} ) {

                # check validity
                if ( $opt{'-level'} > $debug xor $opt{'-level'} < $fatal ) {
                    throw 'OutOfBounds' =>
"'-level' can be between $fatal and $debug, not $opt{'-level'}";
                }
                if ( $opt{'-class'} ) {
                    $VERBOSE{ $opt{'-class'} } = $opt{'-level'};
                    $self->info(
"Changed verbosity for class $opt{'-class'} to $opt{'-level'}"
                    );
                }
                elsif ( $opt{'-method'} ) {
                    $VERBOSE{ $opt{'-method'} } = $opt{'-level'};
                    $self->info(
"Changed verbosity for method $opt{'-method'} to $opt{'-level'}"
                    );
                }
                else {
                    $VERBOSE = $opt{'-level'};
                    $self->info("Changed global verbosity to $VERBOSE");
                }
            }
        }
        return $VERBOSE;
    }

    sub DESTROY {
    }    # empty destructor so we don't go up inheritance tree at the end
         # log levels
    sub FATAL () { 0 }
    sub ERROR () { 1 }
    sub WARN ()  { 2 }
    sub INFO ()  { 3 }
    sub DEBUG () { 4 }

    # source filtering to get rid of all logger calls.
    # This doesn't seem to improve performance by much
    # and the regexes might not work if there are
    # parentheses inside the logging string so this is
    # highly experimental. Also, it requires modules
    # to "use" Bio::Phylo::Util::Logger explicitly instead
    # of calling get_logger up the inheritance tree. All
    # in all this is pretty useless and buggy at this point
    # so let's just comment this out.
    # 	FILTER {
    # 		my $debug_regex = '$logger->debug(';
    # 		my $info_regex  = '$logger->info(';
    # 		my $warn_regex  = '$logger->warn(';
    # 		my $error_regex = '$logger->error(';
    # 		my $fatal_regex = '$logger->fatal(';
    #
    # 		s/\Q$debug_regex\E[^\)]+?\);//g unless $ENV{'BIO_PHYLO_LOGGING'};
    # 		s/\Q$info_regex\E[^\)]+?\);//g  unless $ENV{'BIO_PHYLO_LOGGING'};
    # 		s/\Q$warn_regex\E[^\)]+?\);//g  unless $ENV{'BIO_PHYLO_LOGGING'};
    # 		s/\Q$error_regex\E[^\)]+?\);//g unless $ENV{'BIO_PHYLO_LOGGING'};
    # 		s/\Q$fatal_regex\E[^\)]+?\);//g unless $ENV{'BIO_PHYLO_LOGGING'};
    #
    # 	};
}
1;

=head1 NAME

Bio::Phylo::Util::Logger - Logger of internal messages of several severity
levels 

=head1 SYNOPSIS

 use strict;
 use Bio::Phylo::Util::Logger ':levels'; # import level constants
 use Bio::Phylo::IO 'parse';
 use Bio::Phylo::Factory; 
 
 # Set the verbosity level of the tree class.
 # "DEBUG" is the most verbose level. All log messages
 # emanating from the tree class will be 
 # transmitted. For this to work the level constants
 # have to have been imported!
 use Bio::Phylo::Forest::Tree 'verbose' => DEBUG; # note: DEBUG is not quoted!
 
 # Create a file handle for logger to write to.
 # This is not necessary, by default the logger
 # writes to STDERR, but sometimes you will want
 # to write to a file, as per this example.
 open my $fh, '>', 'parsing.log' or die $!;
 
 # Create a logger object.
 my $fac = Bio::Phylo::Factory->new;
 my $logger = $fac->create_logger;
 
 # Set the verbosity level of the set_name
 # method in the base class. Messages coming
 # from this method will be transmitted.
 $logger->VERBOSE( 
     '-level'  => DEBUG, # note, not quoted, this is a constant!
     '-method' => 'Bio::Phylo::set_name', # quoted, otherwise bareword error!
 );
 
 # 'Listeners' are subroutine references that
 # are executed when a message is transmitted.
 # The first argument passed to these subroutines
 # is the log message. This particular listener
 # will write the message to the 'parsing.log'
 # file, if the $fh file handle is still open.
 $logger->set_listeners(
     sub {
         my ($msg) = @_;
         if ( $fh->opened ) {
             print $fh $msg;
         }
     }
 );

 # Now parse a tree, and see what is logged.
 my $tree = parse( 
     '-format' => 'newick', 
     '-string' => do { local $/; <DATA> },
 )->first;

 # Cleanly close the log handle.
 close $fh;
 
 __DATA__
 ((((A,B),C),D),E);

The example above will write something like the following to the log file:

 INFO Bio::Phylo::Forest::Tree::new [$PREFIX/Bio/Phylo/Forest/Tree.pm, 99] - constructor called for 'Bio::Phylo::Forest::Tree'
 INFO Bio::Phylo::set_name [$PREFIX/Bio/Phylo.pm, 281] - setting name 'A'
 INFO Bio::Phylo::set_name [$PREFIX/Bio/Phylo.pm, 281] - setting name 'B'
 INFO Bio::Phylo::set_name [$PREFIX/Bio/Phylo.pm, 281] - setting name 'C'
 INFO Bio::Phylo::set_name [$PREFIX/Bio/Phylo.pm, 281] - setting name 'D'
 INFO Bio::Phylo::set_name [$PREFIX/Bio/Phylo.pm, 281] - setting name 'E'

=head1 DESCRIPTION

This class defines a logger, a utility object for logging messages.
The other objects in Bio::Phylo use this logger to give detailed feedback
about what they are doing at per-class, per-method, user-configurable log levels
(DEBUG, INFO, WARN, ERROR and FATAL). These log levels are constants that are
optionally exported by this class by passing the ':levels' argument to your
'use' statement, like so:

 use Bio::Phylo::Util::Logger ':levels';

If for some reason you don't want this behaviour (i.e. because there is
something else by these same names in your namespace) you must use the fully
qualified names for these levels, i.e. Bio::Phylo::Util::Logger::DEBUG and
so on.

The least verbose is level FATAL, in which case only 'fatal' messages are shown. 
The most verbose level, DEBUG, shows debugging messages, including from internal 
methods (i.e. ones that start with underscores, and special 'ALLCAPS' perl 
methods like DESTROY or TIEARRAY). For example, to monitor what the root class 
is doing, you would say:

 $logger->( -class => 'Bio::Phylo', -level => DEBUG )

To define global verbosity you can omit the -class argument. To set verbosity
at a more granular level, you can use the -method argument, which takes a 
fully qualified method name such as 'Bio::Phylo::set_name', such that messages
originating from within that method's body get a different verbosity level.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new()

Constructor for Logger.

 Type    : Constructor
 Title   : new
 Usage   : my $logger = Bio::Phylo::Util::Logger->new;
 Function: Instantiates a logger
 Returns : a Bio::Phylo::Util::Logger object
 Args    : -verbose => Bio::Phylo::Util::Logger::INFO (DEBUG/INFO/WARN/ERROR/FATAL)
 	   -package => a package for which to set verbosity (optional)	

=back

=head2 VERBOSITY LEVELS

=over

=item FATAL

Rarely happens, usually an exception is thrown instead.

=item ERROR

If this happens, something is seriously wrong that needs to be addressed.

=item WARN

If this happens, something is seriously wrong that needs to be addressed.

=item INFO

If something weird is happening, turn up verbosity to this level as it might
explain some of the assumptions the code is making.

=item DEBUG

This is very verbose, probably only useful if you write core Bio::Phylo code.

=back

=head2 LOGGING METHODS

=over

=item log()

Prints argument debugging message, depending on verbosity.

 Type    : logging method
 Title   : log
 Usage   : $logger->log( "WARN", "warning message" );
 Function: prints logging message, depending on verbosity
 Returns : invocant
 Args    : message log level, logging message

=item debug()

Prints argument debugging message, depending on verbosity.

 Type    : logging method
 Title   : debug
 Usage   : $logger->debug( "debugging message" );
 Function: prints debugging message, depending on verbosity
 Returns : invocant
 Args    : logging message

=item info()

Prints argument informational message, depending on verbosity.

 Type    : logging method
 Title   : info
 Usage   : $logger->info( "info message" );
 Function: prints info message, depending on verbosity
 Returns : invocant
 Args    : logging message

=item warn()

Prints argument warning message, depending on verbosity.

 Type    : logging method
 Title   : warn
 Usage   : $logger->warn( "warning message" );
 Function: prints warning message, depending on verbosity
 Returns : invocant
 Args    : logging message

=item error()

Prints argument error message, depending on verbosity.

 Type    : logging method
 Title   : error
 Usage   : $logger->error( "error message" );
 Function: prints error message, depending on verbosity
 Returns : invocant
 Args    : logging message

=item fatal()

Prints argument fatal message, depending on verbosity.

 Type    : logging method
 Title   : fatal
 Usage   : $logger->fatal( "fatal message" );
 Function: prints fatal message, depending on verbosity
 Returns : invocant
 Args    : logging message

=item set_listeners()

Adds listeners to send log messages to.

 Type    : Mutator
 Title   : set_listeners()
 Usage   : $logger->set_listeners( sub { warn shift } )
 Function: Sets additional listeners to log to (e.g. a file)
 Returns : invocant
 Args    : One or more code references
 Comments: On execution of the listeners, the @_ arguments are:
           $log_string, # the formatted log string
           $level,      # log level, i.e DEBUG, INFO, WARN, ERROR or FATAL
           $subroutine, # the calling subroutine
           $filename,   # filename where log method was called
           $line,       # line where log method was called
           $msg         # the unformatted message

=item PREFIX()

Getter and setter of path prefix to strip from source file paths in messages.
By default, messages will have a field such as C<[$PREFIX/Bio/Phylo.pm, 280]>,
which indicates the message was sent from line 280 in file Bio/Phylo.pm inside
path $PREFIX. This is done so that your log won't be cluttered with 
unnecessarily long paths. To find out what C<$PREFIX> is set to, call the 
PREFIX() method on the logger, and to change it provide a path argument 
relative to which the paths to source files will be constructed.

 Type    : Mutator/Accessor
 Title   : PREFIX()
 Usage   : $logger->PREFIX( '/path/to/bio/phylo' )
 Function: Sets/gets $PREFIX
 Returns : Verbose level
 Args    : Optional: a path
 Comments:

=item VERBOSE()

Setter for the verbose level. This comes in five levels: 

	FATAL = only fatal messages (though, when something fatal happens, you'll most 
	likely get an exception object), 
	
	ERROR = errors (hopefully recoverable), 
	
	WARN = warnings (recoverable), 
	
	INFO = info (useful diagnostics), 
	
	DEBUG = debug (almost every method call)

Without additional arguments, i.e. by just calling VERBOSE( -level => $level ),
you set the global verbosity level. By default this is 2. By increasing this
level, the number of messages quickly becomes too great to make sense out of.
To focus on a particular class, you can add the -class => 'Some::Class' 
(where 'Some::Class' stands for any of the class names in the Bio::Phylo 
release) argument, which means that messages originating from that class will 
have a different (presumably higher) verbosity level than the global level. 
By adding the -method => 'Fully::Qualified::method_name' (say, 
'Bio::Phylo::set_name'), you can change the verbosity of a specific method. When
evaluating whether or not to transmit a message, the method-specific verbosity
level takes precedence over the class-specific level, which takes precedence
over the global level.

 Type    : Mutator
 Title   : VERBOSE()
 Usage   : $logger->VERBOSE( -level => $level )
 Function: Sets/gets verbose level
 Returns : Verbose level
 Args    : -level   => 4 # or lower
 
           # optional, or any other class 
           -class   => 'Bio::Phylo' 
           
           # optional, fully qualified method name
           -method' => 'Bio::Phylo::set_name' 

=back

=head1 SEE ALSO

Also see the manual: L<Bio::Phylo::Manual> and L<http://rutgervos.blogspot.com>.

=head1 CITATION

If you use Bio::Phylo in published research, please cite it:

B<Rutger A Vos>, B<Jason Caravas>, B<Klaas Hartmann>, B<Mark A Jensen>
and B<Chase Miller>, 2011. Bio::Phylo - phyloinformatic analysis using Perl.
I<BMC Bioinformatics> B<12>:63.
L<http://dx.doi.org/10.1186/1471-2105-12-63>

=head1 REVISION

 $Id: Logger.pm 1660 2011-04-02 18:29:40Z rvos $

=cut
