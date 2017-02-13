
* Remove Git.pm from dependency. use Git::Repository instead.

* GitHub Pages support
    http://pages.github.com/

* `key`  - list keys
* `key remove`
* `key add`
* `vis public`
* `vis private`

* Collaborators

    http://develop.github.com/p/repo.html
    repos/show/:user/:repo/collaborators

    repos/collaborators/:user/:repo/add/:collaborator
    repos/collaborators/:user/:repo/remove/:collaborator

    repos/pushable

* Contributor

    repos/show/:user/:repo/contributors

* Refes

    repos/show/:user/:repo/tags

* Fetch command

    # fetch gugod's fork
    gh fetch gugod


lib/App/gh/Command/
├── All.pm
├── Clone.pm
├── Commit.pm
├── Drop.pm
├── Fork.pm
├── Help.pm
├── Import.pm
├── Info.pm
├── Issue
│   ├── Comment.pm
│   ├── Edit.pm
│   ├── List.pm
│   └── Show.pm
├── Issue.pm
├── List.pm
├── Network.pm
├── Page.pm
├── Pull.pm
├── Pullreq
│   ├── List.pm
│   ├── Send.pm
│   └── Show.pm
├── Pullreq.pm
├── Push.pm
├── Recent.pm
├── Search.pm
├── Setup.pm
├── Update.pm
└── Upload.pm

2 directories, 27 files
