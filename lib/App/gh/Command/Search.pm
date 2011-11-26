package App::gh::Command::Search;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use App::gh;
use Term::ANSIColor;
use Text::Wrap;
use v5.10;

=head1 NAME

App::gh::Command::Search - search repositories

=head1 USAGE

    $ gh search perl6

=cut

sub options {
    ( 'l|long' => 'long' )
}

sub run {
    my ($self,$keyword) = @_;

    local $|;
    say "Fetching list...";

    my $result = App::gh->api->search($keyword);
    if( $self->{long} ) {
        for my $entry ( @{ $result->{repositories} } ) {
            print color 'white bold';
            say "*   $entry->{owner}/$entry->{name}";
            print color 'reset';
            say "    W/F:      $entry->{watchers}/$entry->{forks}";
            say "    Url:      " .  $entry->{url} if $entry->{url};
            say "    Homepage: " .  $entry->{homepage} if $entry->{homepage};
            say "\n" . wrap( '    ', '    ', $entry->{description} ) . "\n";
        }
    } else {
        my @ary = ();
        for my $repo ( @{ $result->{repositories} } ) {
            my $name = sprintf "%s/%s", $repo->{username} , $repo->{name};
            my $desc = $repo->{description};
            push @ary, [ $name , $desc ];
        }
        # print short list
        print_list @ary;
    }
}

1;
__END__

Entry structure

    {
        'size' => 120,
        'watchers' => 228,
        'created_at' => '2010/09/18 05:38:07 -0700',
        'url' => 'https://github.com/Marak/webservice.js',
        'followers' => 228,
        'open_issues' => 16,
        'owner' => 'Marak',
        'has_downloads' => $VAR1->{'repositories'}[0]{'has_issues'},
        'has_issues' => $VAR1->{'repositories'}[0]{'has_issues'},
        'language' => 'JavaScript',
        'pushed' => '2011/09/29 15:22:44 -0700',
        'name' => 'webservice.js',
        'private' => $VAR1->{'repositories'}[0]{'has_downloads'},
        'score' => '0.48941568',
        'has_wiki' => $VAR1->{'repositories'}[0]{'has_issues'},
        'description' => ' turn node.js modules into RESTFul web-services',
        'pushed_at' => '2011/09/29 15:22:44 -0700',
        'username' => 'Marak',
        'forks' => 21,
        'created' => '2010/09/18 05:38:07 -0700',
        'homepage' => 'http://blog.nodejitsu.com/create-nodejs-web-services-in-one-line',
        'fork' => $VAR1->{'repositories'}[0]{'has_downloads'},
        'type' => 'repo'
    },

