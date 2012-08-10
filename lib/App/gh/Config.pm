package App::gh::Config;
use warnings;
use strict;
use File::HomeDir ();
use File::Spec;
use File::Basename qw(dirname);




# XXX: use Config::Tiny to parse ini format config.
# TODO: Use cache not to invoke 'git' command frequently?
sub parse {
    my ( $class, $file ) = @_;

    my %config;
    for my $line (split "\n", qx(git config --list -f $file)) {
        # $line = foo.bar.baz=value
        if (my ($key, $value) = ($line =~ m/^([^=]+)=(.*)/)) {
            my $h = \%config;
            if ($key eq 'include.path') {
                my $path = File::Spec->file_name_is_absolute($value) ? $value : File::Spec->rel2abs($value, dirname($file));
                %config = (%config, %{ $class->parse($path) });
                # Uncomment this to get rid of "include.path" in %config
                #next;
            }
            my @keys = split /\./, $key;
            next unless @keys;
            # Create empty hashref.
            # %config = (foo => {bar => ($h = {})})
            for (@keys[0..$#keys-1]) {
                $h->{$_} = {} unless exists $h->{$_};
                $h = $h->{$_};
            }
            # $config{foo}{bar}{baz} = $value;
            $h->{$keys[-1]} = $value;
        }
    }

    return \%config;
}


sub current {
    my $class = shift;
    my $path = File::Spec->join(".git","config");
    return unless -e $path;

    # TODO: prevent error
    return $class->parse( $path );
}


# when command trying to read config, we should let it die, and provide another
# method to check github id and token.
sub github_token {
    my $class = shift;
    my $config;
    $config = $class->global();
    return $config->{github}->{token};
}

sub github_id {
    my $class = shift;
    my $config;
    $config = $class->global();
    return $config->{github}->{user};
}

sub global {
    my $class = shift;
    my $path = File::Spec->join(File::HomeDir->my_home, '.gitconfig');
    return unless -e $path;
    return $class->parse( $path );
}

1;
