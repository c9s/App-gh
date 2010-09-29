package App::gh::Command::Recent;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use JSON;
use XML::Atom::Feed;
use URI;
use Text::Wrap;
use IO::Pager;


sub options {
    ( "c|color" => "color" )
}

sub run {
    my ($self) = shift;
    my $config = parse_config $ENV{HOME} . "/.gitconfig";
    my $token = $config->{github}->{token};
    my $user  = $config->{github}->{user};
    my $feed_uri = "https://github.com/$user.private.atom?token=$token";
    my $feed = XML::Atom::Feed->new(URI->new( $feed_uri ));

    local  $STDOUT = new IO::Pager       *STDOUT;

    $Text::Wrap::columns = 90;

    for my $entry ( $feed->entries ) {
        my $html = $entry->content->body;
        $html =~ s{<a href="(.*?)".*?>(.*?)</a>}{$2 : $1 }g;

        use HTML::Strip;
        my $h = HTML::Strip->new(  emit_spaces => 1 );
        my $text = $h->parse( $html );
        $h->eof;
        $text =~ s{\s+|\n+}{ }smg;
        $text =~ s{(?=committed)}{\n\n}g;
        # $text =~ s{(committed.*?http\S+)}{$1\n        }g;

        my $title = $entry->title;
        if( $self->{color} ) {
            print "\e[1;32m" , $title , "\e[0m\n";
        }
        else {
            print $title , "\n";
        }
        print wrap( "  ", "  ", $text ) , "\n\n";
    }

}


1;
