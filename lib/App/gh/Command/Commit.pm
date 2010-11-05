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

=head1 NAME

App::gh::Command::Commit - quick commit process (show status, diff, then commitCloneall)

=head1 DESCRIPTION

gh commit command provides a normal commit process. (show status, diff, then commit in few
strokes)

=head1 USAGE


    $ gh commit

=cut


sub options {
    (
        'e|editor' => 'with_editor',
    )
}

sub run {
    my ($self) = @_;

    die "Nothing to commit" unless qx(git diff);

    print "=========== Current Change Status ===========\n";
    system( qq(git status) );

    print "\n";
    print "=========== GH Commit Interface ===========\n";
    print "diff(d). status(s). status with untracked files (ss).\n";
    print "commit(c). quit(q).\n";

    my $term = Term::ReadLine->new('Simple');
    my $prompt = "Diff(d), Status(s/ss), Commit(c), Quit(q): ";

    my $OUT = $term->OUT || \*STDOUT;
    my $res; 
    while ( defined ($res = $term->readline($prompt)) ) {
        chomp($res);

        $res =~ s{^\s*(\S*)\s*$}{$1};

        if ( $res =~ /^d/ ) {
            system( qq(git diff --color=auto) );
        }
        elsif( $res =~ /^ss$/ ) {
            system( qq(git status -unormal) );
        }
        elsif( $res =~ /^s$/ ) {
            system( qq(git status -uno) );
        }
        elsif( $res =~ /^c$/ ) {
            # read commit messages
            print "Please enter commit messages below (empty line to finish):\n";
            my @lines = qw();
            my $line;
            my $cnt = 0;
            while( defined ($line = $term->readline(">> ")) ) {
                chomp $line;
                $cnt++ unless $line;
                last if $cnt > 1;
                push @lines , $line;
            }

            last unless grep { $_ } @lines;  # skip commit if those lines are empty.

            # create a tempfile and put messages into the temp file.
            use File::Temp qw(tempfile);
            my ($fh, $filename) = tempfile( ".gh_commit_XXXX" , SUFFIX => '.msg');

            # put messages into history.
            $term->addhistory( join "\n" , @lines );

            print $fh join "\n",  @lines;

            system( "git commit -a -F " . $filename ) == 0 or 
                die "Commit failed. \nCommit message is saved to $filename.\n"
                   ."You can use 'git commit -F $filename' to commit again";

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
