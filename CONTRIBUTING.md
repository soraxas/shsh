# Contributing

## Commits

Write a [good commit message][commit].

## Tests

To run the tests, install bats:

~~~ sh
$ shsh install sstephenson/bats
~~~

update submodules:

~~~ sh
$ git submodule update --init
~~~

and then run:

~~~ sh
$ make
~~~

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
