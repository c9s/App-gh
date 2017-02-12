package App::gh::Role::Format;

use MooseX::Role::Parameterized;

use JSON qw/ to_json /;
use Moose::Util::TypeConstraints qw/ enum /;
use IO::Interactive qw/ is_interactive /;
use Module::Runtime qw/ use_module /;
use Term::ANSIColor qw/ colored /;

parameter formats => (
    isa => 'ArrayRef',
    is       => 'ro',
    required => 1,
);

role {
    my $p = shift;

    has format => (
        traits => [ 'AppOption' ],
        cmd_type => 'option',
        is => 'ro',
        isa => enum( $p->formats ),
        default => $p->formats->[0],
        documentation => 'printing format',
    );

    requires "print_$_" for grep { $_ ne 'json' } @{ $p->formats };

    method print_json => sub {
        print to_json( $_[1], { pretty => 1, canonical => 1, allow_blessed => 1 } );
    };

    method print_formatted => sub {
        my $self = shift;
        my $method = 'print_' . $self->format;
        $self->$method(@_);
    };

    has handlebars => (
        is => 'ro',
        lazy => 1,
        default => sub {
            use_module( 'Text::Handlebars' )->new(
                helpers => {
                    color => sub {
                        my( $context, $color, $options ) = @_;
                        my $output = $options->{fn}->($context)||'';
                        return is_interactive() ?  colored( [ $color ], $output ) : $output;
                    },
                    pad => sub {
                        my( $context, $padding, $options ) = @_;
                        return sprintf "%${padding}s", $options->{fn}->($context);
                    },
                }
            );
        },
        handles => [ 'render_string' ],
    );


};



1;

__END__
