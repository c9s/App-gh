package App::gh::Command::Commit;
use warnings;
use strict;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;
use File::Temp;
use Term::ReadLine;

sub run {
    my ($self) = @_;

    die "Nothing to commit" unless qx(git diff);

    system( qq(git status) );

    # print qx(git diff --color=auto);
    my $term = Term::ReadLine->new('Simple');
    my $prompt = "Diff(d), Status(s), Commit(c), Quit(q): ";

    my $OUT = $term->OUT || \*STDOUT;
    my $res; 
    while ( defined ($res = $term->readline($prompt)) ) {
        chomp($res);
        if ( $res =~ /^d/ ) {
            system( qq(git diff --color=always) );
        }
        elsif( $res =~ /^s/ ) {
            system( qq(git status) );
        }
        elsif( $res =~ /^c/ ) {
            # read commit messages

            print "Please enter commit messages below (empty line to finish):\n";
            my @lines = qw();
            my $line;
            while( defined ($line = $term->readline(">> ")) ) {
                last unless $line;
                chomp $line;
                push @lines , $line;
            }

            last unless @lines;

            use File::Temp qw(tempfile);
            my ($fh, $filename) = tempfile( ".gh_commit_XXXX" , SUFFIX => '.msg');

            $term->addhistory( join "\n" , @lines );

            print $fh join "\n",  @lines;
            system( "git commit -a -F " . $filename ) == 0 or 
                die "Commit message saved to $filename.\n";

            unlink( $filename );
            last;
        }
        elsif( $res =~ /^q/ ) {
            print "Skipped\n";
            last;
        }
    }

}

1;
