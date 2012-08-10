package App::gh::Command::Update;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils qw(
    info 
    error
    build_git_remote_command
    git_current_branch
);

=head1 NAME

App::gh::Command::Update - remote update --prune

=head1 DESCRIPTION

Simply run git remote update --prune , git pull --all , then push back to
writable remotes.

=cut

sub run {
    my $self = shift;
    my @remotes = @_;

    unless ( -d ".git" ) {
        die "Not a repository";
    }

    info "Running remote update with prune";
    my @cmds = build_git_remote_command('update',{ prune => 1 });
    system(@cmds) == 0 
        or die error "system @cmds failed: $?";

    my $diff = qx(git diff);
    chomp($diff);
    die error("Can not update, you have uncommitted changes.") if $diff;

    my $current_head = git_current_branch;
    if( @remotes ) {
        for my $remote (@remotes) {
            info "Pull and rebase from $remote/$current_head...";
            qx{git pull --rebase $remote $current_head};
        }
    }
    else {
        my @lines = split /\n/,qx{ git remote -v | grep '(fetch)'};
        for my $line ( @lines ) {
            my ( $remote, $uri, $type) = ($line =~ m{^(\w+)\s+(\S+)\s+\((\w+)\)} );
            info "Pull and rebase from $remote ...";
            qx{git pull --rebase $remote $current_head};

            # if( $uri =~ /^git\@github\.com/ ) {
            #     info "Pushing changes to $remote : $uri";
            #     qx{ git push  $remote };
            # }
        }
    }
    info "Done";
}

1;
