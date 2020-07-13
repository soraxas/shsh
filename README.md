# Shsh [![Releases](https://img.shields.io/github/release/soraxas/shsh.svg?label=&color=0366d6)](https://github.com/soraxas/shsh/releases/latest)

<p align="center">
   <img src="docs/images/shsh-logo.png">
</p>

A **sh**ell **s**cripts **h**andler (**shsh**) for managing shell scripts, functions, standalone binaries, and more.

[![CI](https://github.com/soraxas/shsh/workflows/CI/badge.svg)](https://github.com/soraxas/shsh/actions?query=workflow%3ACI)
[![Build Status](https://img.shields.io/travis/soraxas/shsh/master.svg?logo=travis)](https://travis-ci.org/soraxas/shsh)
[![Master Update](https://img.shields.io/github/last-commit/soraxas/shsh/master.svg)](https://github.com/soraxas/shsh/commits/master)
[![License](https://img.shields.io/github/license/soraxas/shsh.svg)](https://github.com/soraxas/shsh/blob/master/LICENSE)

## What it does

Shsh allows you to quickly install shell packages directly from github or other sites. Instead of looking for specific install instructions for each package and messing with your `$PATH`, shsh will create a central location for all packages and manage their executable, completions files, and man files for you. It is multi-threaded to speed up updating and setting up your packages.

Shsh is a POSIX-compatible script handler, as a former fork of [basher](https://github.com/basherpm/basher) but was made to works with even the most strict POSIX compliance shell like [dash](https://wiki.archlinux.org/index.php/Dash). The performance of shsh is enhanced by using `dash` and with a multi-threaded. The flexibility of shsh comes from **hooks** where you can run arbitrary scripts that persists across package updates.

## Manual Installation

1. Checkout shsh inside `$XDG_DATA_HOME`, e.g., at `~/.local/share/shsh`
   
   ```sh
    $ git clone https://github.com/soraxas/shsh ~/.local/share/shsh
   ```

2. Initialize shsh in your shell initialization
   
   ```sh
    export PATH="$HOME/.local/share/shsh/bin:$PATH"'
    eval "$(shsh init SHELL)"
    # SHELL: sh, bash, zsh, etc.
   ```
   
    **Fish**: Use the following commands instead:
   
   ```sh
    set -gx PATH ~/.local/share/shsh $PATH
    status --is-interactive; and shsh init fish | source
   ```

## Updating

Run the following command to and pull the latest changes in shsh:

```sh
$ shsh self-upgrade
```

## Usage

### Installing packages from Github

```sh
$ shsh install sstephenson/bats
```

This will install [bats](https://github.com/sstephenson/bats) and add `bin/bats` to `$PATH`.

### Installing packages from other sites

```sh
$ shsh install bitbucket.org/user/repo_name
```

This will install `repo_name` from https://bitbucket.org/user/repo_name

### Using ssh instead of https

If you want to do local development on installed packages and you have ssh
access to the site, use `--ssh` to override the protocol:

```sh
$ shsh install --ssh juanibiapina/gg
```

### Installing a local package

If you develop a package locally and want to try it through shsh,
use the `link` command:

```sh
$ shsh link directory my_namespace/my_package
```

The `link` command will install the dependencies of the local package.
You can prevent that with the `--no-deps` option:

```sh
$ shsh link --no-deps directory my_namespace/my_package
```

### Sourcing files from a package into current shell

Basher provides an `include` function that allows sourcing files into the
current shell. After installing a package, you can run:

```
include username/repo lib/file.sh
```

This will source a file `lib/file.sh` under the package `username/repo`.

### Command summary

- `shsh commands` - List commands
- `shsh help <command>` - Display help for a command
- `shsh uninstall <package>` - Uninstall a package
- `shsh list` - List installed packages
- `shsh outdated` - List packages which are not in the latest version
- `shsh upgrade <package>` - Upgrade a package to the latest version

### Configuration options

To change the behavior of shsh, you can set the following variables either
globally or before each command:

- If `$XDG_DATA_HOME` is set, `$SHSH_ROOT` will be set as `$XDG_DATA_HOME/shsh` (commonly that will be at `~/.local/share/shsh`). It is used to store cellar for the cloned packages. If `$XDG_DATA_HOME` is not set, `$SHSH_ROOT` will be default as `$HOME/.local/share/shsh`.
- `SHSH_FULL_CLONE=true` - Clones the full repo history instead of only the last commit (useful for package development)
- `SHSH_PREFIX` - set the installation and package checkout prefix (default is `$SHSH_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`.  This allows you to manage "global packages", distinct from individual user packages.

## Packages

Packages are simply repos (username/repo). You may also specify a site
(site/username/repo).

Any files inside a bin directory are added to the path. If there is no bin
directory, any executable files in the package root are added to the path.

Any man pages (files ended in `\.[0-9]`) inside a `man` directory are added
to the man path.

Optionally, a repo might contain a `package.sh` file which specifies binaries,
dependencies and completions in the following format:

```sh
BINS=folder/file1:folder/file2.sh
DEPS=user1/repo1:user2/repo2
BASH_COMPLETIONS=completions/package
ZSH_COMPLETIONS=completions/_package
```

BINS specified in this fashion have higher precedence then the inference rules
above.

## Credits

- [basher](https://github.com/basherpm/basher) for the wonderful framework

- [fisher](https://github.com/jorgebucaran/fisher) for the idea of multi-threaded approach

- [vim-plug](https://github.com/junegunn/vim-plug) for the inspiration of hooks
