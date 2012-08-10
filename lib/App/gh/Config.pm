package App::gh::Config;
use warnings;
use strict;
use File::HomeDir ();
use File::Spec;
use File::Basename qw(dirname);




my %_parse_memoize;
# XXX: use Config::Tiny to parse ini format config.
sub parse {
    my ( $class, $file ) = @_;

    # Return cached result.
    $file = File::Spec->rel2abs($file);
    return $_parse_memoize{$file} if exists $_parse_memoize{$file};

    my %config;
    for my $line (split "\n", qx(git config --list -f '$file')) {
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

    # Cache result not to invoke 'git' command frequently.
    $_parse_memoize{$file} = \%config;
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
# XXX: abandoned, since we are using Net::GitHub V3
sub github_token { return $_[0]->global()->{github}->{token}; }

sub github_password { return $_[0]->global()->{github}->{password}; }

# Auth with OAuth
sub github_access_token { return $_[0]->global()->{github}->{access_token}; }

sub github_id { return $_[0]->global()->{github}->{user}; }

sub global {
    my $class = shift;
    my $path = File::Spec->join(File::HomeDir->my_home, '.gitconfig');
    return unless -e $path;
    return $class->parse( $path );
}

1;
