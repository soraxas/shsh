# mise-shsh

`mise-shsh` is a native mise **backend plugin** for [shsh](https://github.com/soraxas/shsh).

It makes `shsh` packages addressable as mise tools:

```sh
mise plugin link shsh /path/to/shsh/mise-shsh
mise use shsh:owner/repo
```

That behaves like:

```sh
shsh install okok/yes
```

except the install target is the mise-managed `install_path` for that tool/version. Whatever `shsh` links into its prefix is what mise exposes.

## How it works

- The backend name is `shsh`
- The tool name is the shsh package, e.g. `owner/repo`
- The backend delegates installation to the in-tree `shsh` source
- `ctx.install_path` becomes the shsh prefix for that tool install
- `shshrc` writes are disabled so installs stay isolated from user config

This means:

- linked binaries land in `ctx.install_path/bin`
- linked manpages land in `ctx.install_path/man`
- linked completions land in `ctx.install_path/completions`

The backend currently exposes:

- `PATH += <install_path>/bin`
- `MANPATH += <install_path>/man`
- `FPATH += <install_path>/completions/zsh/compsys`

## Versions

`mise ls-remote shsh:owner/repo` returns upstream git tags plus a synthetic `latest` entry.

- `@latest` means the default branch HEAD, matching `shsh install owner/repo`
- `@<tag>` means `shsh install owner/repo@<tag>`

## Examples

```sh
mise use shsh:bats-core/bats-core
mise exec shsh:bats-core/bats-core@latest -- bats --version

mise install shsh:soraxas/shsh@v3.0.2
mise exec shsh:soraxas/shsh@v3.0.2 -- shsh --version
```

## Notes

- This backend is developed in-tree and shells out to the parent `shsh` source checkout.
- It targets Unix-like systems.

## Testing

```sh
cd mise-shsh
./test/test.sh
```
