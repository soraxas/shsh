# Shsh [![Releases](https://img.shields.io/github/release/soraxas/shsh.svg?label=&color=0366d6)](https://github.com/soraxas/shsh/releases/latest)

<p align="center">
   <img src="docs/images/shsh-logo.png">
</p>

A **sh**ell **s**cripts **h**andler (**shsh**) for managing shell scripts, functions, standalone binaries, completion files, and more.

[![CI](https://github.com/soraxas/shsh/workflows/CI/badge.svg)](https://github.com/soraxas/shsh/actions?query=workflow%3ACI)
[![ShellCheck](https://github.com/soraxas/shsh/workflows/ShellCheck/badge.svg)](https://github.com/soraxas/shsh/actions?query=workflow%3AShellCheck)
[![Build Status](https://img.shields.io/travis/soraxas/shsh/master.svg?logo=travis)](https://travis-ci.org/soraxas/shsh)
[![AUR Version](https://img.shields.io/aur/version/shsh.svg)](https://aur.archlinux.org/packages/shsh)
[![AUR-git Version](https://img.shields.io/aur/version/shsh-git.svg?label=aur-git)](https://aur.archlinux.org/packages/shsh-git)
[![Master Update](https://img.shields.io/github/last-commit/soraxas/shsh/master.svg)](https://github.com/soraxas/shsh/commits/master)
[![License](https://img.shields.io/github/license/soraxas/shsh.svg)](https://github.com/soraxas/shsh/blob/master/LICENSE)

## What it does

Shsh allows you to quickly install shell packages directly from github or other sites. Instead of looking for specific install instructions for each package and messing with your `$PATH`, shsh will create a central location for all packages and manage their executable, completions files, and man files for you. It is multi-threaded to speed up updating and setting up your packages.

Shsh is a POSIX-compatible script handler, as a former fork of [basher](https://github.com/basherpm/basher) but was made to works with even the most strict POSIX compliance shell like [dash](https://wiki.archlinux.org/index.php/Dash). The performance of shsh is enhanced by using `dash` and with our use of multi-threaded approach. The flexibility of shsh comes from **hooks** where you can run arbitrary scripts that persists across package updates.

## Quick Start

### Automatic Installation

Automatically bootstrap and install `shsh` (which would also modify your shell's init script)
```sh
curl -s https://raw.githubusercontent.com/soraxas/shsh/master/bootstrap/install.sh | sh
```

### Recipes

[Ranger](https://github.com/ranger/ranger): A powerful terminal file manger
 ```sh
shsh install ranger/ranger -v REMOVE_EXTENSION=true -v BINS=ranger.py -h pre='sed -i "1d;2i#!/usr/bin/python3 -O" ranger.py'
```

## Installation

1. **Manual:** Checkout shsh inside `$XDG_DATA_HOME`, e.g., at `~/.local/share/shsh`

   ```sh
    # clone shsh and add shsh to $PATH variable
    $ git clone https://github.com/soraxas/shsh ~/.local/share/shsh
    $ export PATH="$HOME/.local/share/shsh/bin:$PATH"
    # Optional: link shsh's own completion files and man pages to cellar
    $ cd ~/.local/share/shsh && make self-linking
   ```

    **Or with AUR (Arch):** Install `shsh` or `shsh-git` pacakage in AUR, e.g.

   ```sh
    $ yay -S shsh
   ```

2. Initialise shsh in your shell init file, e.g.

   ```sh
    # in ~/.bashrc, ~/.zshrc, etc.
    eval "$(shsh init SHELL)"
    # SHELL: sh, bash, zsh, fish
   ```

    **Fish**: Use the following commands instead:

   ```fish
    $ shsh init fish | source
   ```

## Updating

Run the following command to and pull the latest changes in shsh **(Manual method only)**:

```sh
$ shsh self-upgrade
```

## Usage

### Examples

- **Installing remote packages**

  ```sh
  $ shsh install sstephenson/bats
  ```

  By default, `shsh` will install package from Github.
  This will install [bats](https://github.com/sstephenson/bats) and add `bin/bats` to `$PATH`.

  - Installing packages from other sites

    ```sh
    $ shsh install bitbucket.org/user/repo_name
    ```

    This will install `repo_name` from https://bitbucket.org/user/repo_name

  - Using ssh instead of https

    If you want to do local development on installed packages and you have ssh
    access to the site, use `--ssh` to override the protocol:

    ```sh
    $ shsh install --ssh juanibiapina/gg
    ```

- **Installing a local package**

  ```sh
  $ shsh link directory my_namespace/my_package
  ```

  The `link` command allows you to directly link it to shsh (similar to `pip install -e .`) and any modification to your directory will have an immediate effect.


  - The `link` command will install the dependencies of the local package.
  You can prevent that with the `--no-deps` option:

    ```sh
    $ shsh link --no-deps directory my_namespace/my_package
    ```

- **Installing a github release directly (e.g. pre-compiled binary)**

  ```sh
  $ shsh install --gh-release ajeetdsouza/zoxide FISH_COMPLETIONS=completions/zoxide.fish
  ```

  The ` --gh-release` flag indicates that you want to directly download and link the binary within github release.

    - You can also pin a release version with:

      ```sh
      $ shsh install --gh-release junegunn/fzf@0.38.0
      ```

      which would download from releases with the `0.38.0` tag.

    - If `shsh` is unable to pick the correct asset for you (e.g., the release contains multiple files and it can't determines which to download), you can also specify the asset to download by

      ```sh
      $ shsh install vslavik/diff-pdf --gh-release=diff-pdf-0.5.tar.gz
      ```

      which would sort the asset by prioritising asset with the substring `diff-pdf-0.5.tar.gz`.

  **NOTE:** Downloading gh-release has an optional dependency on `jq` (to parse json). If your system does not has `jq`, `shsh` can also attempt to automatically bootstrap `jq` by itself.


- **Sourcing files from a package into current shell**

  Basher provides an `include` function that allows sourcing files into the
  current shell. After installing a package, you can run:

  ```
  include username/repo lib/file.sh
  ```

  This will source a file `lib/file.sh` under the package `username/repo`.

### Command summary

- `shsh install <package>` - Installs a package from github, custom site, or any arbitrary recipes.
- `shsh uninstall <package>` - Uninstall a package
- `shsh link <directory>` - Installs a local directory as a shsh package
- `shsh help <command>` - Display help for a command
- `shsh list` - List installed packages
- `shsh outdated` - List packages which are not in the latest version
- `shsh upgrade <package>` - Upgrade a package to the latest version

### Configuration options

To change the behavior of shsh, you can set the following variables either
globally or before each command:

- If `$XDG_DATA_HOME` is set, `$SHSH_ROOT` will be set as `$XDG_DATA_HOME/shsh`; if not set, `$HOME/.local/share/shsh` is the default.
 . It is used to store cellar for the cloned packages.
- `SHSH_FULL_CLONE=true` - Clones the full repo history instead of only the last commit (useful for package development)
- `SHSH_PREFIX` - set the installation and package checkout prefix (default is `$SHSH_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`.  This allows you to manage "global packages", distinct from individual user packages.

## Packages handling

- Packages are simply repos `username/repo`. You may also specify a site
`site/username/repo`.

- Any files inside a `bin` directory are added to `$PATH`. If there is no `bin`
directory, any executable files in the package root are added to `$PATH`.

- Any man pages (files ended in `\.[0-9]`) inside a `man` directory are added
to the man path.

- Optionally, a repo might contain a `package.sh` file which specifies binaries,
dependencies and completions in the following format:

  ```sh
  BINS=folder/file1:folder/file2.sh
  DEPS=user1/repo1:user2/repo2
  BASH_COMPLETIONS=completions/package
  ZSH_COMPLETIONS=completions/_package
  ```

  BINS specified in this fashion have higher precedence then the inference rules
  above.

## Recipes for installing packages (in `shshrc`)

The following are a list of recipes that uses `shsh` plus some lightweight hooks to bootstrap installing script/binaries on a new system. I personally has the following contents in my `~/.config/shshrc` file.

I had defined some handy functions in the `shshrc` file:

```shell
has_cmd() {
  command -v "$1" >/dev/null
}
is_hostname() {
  [ $(cat /etc/hostname) = "$1" ]
}
is_wsl() {
  cat /proc/version | grep -q '[Mm]icrosoft'
}
```

### Examples

- The powerful [delta](https://github.com/dandavison/delta) for viewing diff or git-diff output:

  ```shell
  # if we have cargo, we can build delta directly
  has_cmd cargo && \
    shsh install dandavison/delta -h pre=make -v BINS=target/release/delta
  ```

- High-level git workflow with [git-town](https://github.com/git-town/git-town)

  ```shell
  has_cmd go && \
      shsh install git-town/git-town -h pre='go build && ./git-town completions fish > git-town.fish' -v FISH_COMPLETIONS=git-town.fish
  ```

- Install scripts only on some certain machine

  ```shell
  # for running bash tests
  is_hostname Arch && \
    shsh install bats-core/bats-core
  ```

- Make sure files has executable bits in **gist**

  ```shell
  # for opening reverse port
  shsh install gist.github.com/soraxas/0ef22338ad01e470cd62595d2e5623dd soraxas/open-rev-ports -h a+x
  ```

- Running post hook for `wsl-open` in **wsl**

  ```shell
  # script to simulate xdg-open in wsl
  is_wsl && \
    shsh install 4U6U57/wsl-open -h post='echo "*; wsl-open '"'"'%s'"'"'" > ~/.mailcap'
  ```

- Scripts for installing pre-compiled binary for **wsl**

  ```shell
  is_wsl && \
    shsh install --plain wsl-tools/win32yank -v _ARCH=x64 -v _VERSION=v0.0.4 -h pre='curl -sLo out.zip https://github.com/equalsraf/win32yank/releases/download/$_VERSION/win32yank-$_ARCH.zip && unzip out.zip' -h +x=win32yank.exe
  ```

## Credits

- [basher](https://github.com/basherpm/basher) for the wonderful framework

- [fisher](https://github.com/jorgebucaran/fisher) for the idea of multi-threaded approach

- [vim-plug](https://github.com/junegunn/vim-plug) for the inspiration of hooks
