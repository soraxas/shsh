function __fish_shsh_needs_command
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 -a $cmd[1] = shsh ]
        return 0
    end
    return 1
end

function __fish_shsh_using_command
    set cmd (commandline -opc)
    set -e cmd[1]
    # insufficent argunment
    [ (count $cmd) -lt (count $argv) ]
    and return 1

    # already has more than sufficient argunment
    [ (count $cmd) -gt (count $argv) ]
    and return 1

    for i in (seq 1 (count $argv))
        [ $argv[$i] = $cmd[$i] ]
        or return 1
    end

    return 0
end

function __fish_shsh_get_package_with_desc
    # get package with the verbose flag, where url will be display as package's description
    # remove the useless ".git" endings
    shsh list --details | string replace -fr '(^\S+)\s+[(](.*)[)]' '$1\t$2' \
        | string replace --all -r '(http[s]?://|[.]git$)' ''
end

# only have commands completions
#complete -f -c shsh -n '__fish_shsh_needs_command' -a '(shsh commands)'

# commands completions plus description
set -l shsh_cmds_with_desc (shsh help | awk -F '[[:space:]][[:space:]]+' '/^Some useful/,/^See/ {
  if ($2 != "") {
    print $2"\t"$3
  }
}' | string collect | string escape)
complete -f -c shsh -n __fish_shsh_needs_command -a "$shsh_cmds_with_desc"

for cmd in (shsh commands)
    if string match -q $cmd uninstall upgrade package-path refresh get
        complete -f -c shsh -n "__fish_shsh_using_command $cmd" -a '(__fish_shsh_get_package_with_desc)'
    else
        complete -f -c shsh -n "__fish_shsh_using_command $cmd" -a "(shsh completions $cmd)"
    end
end

# add flag to all commands
complete -f -c shsh -l help -d "show help message of a subcommand"
complete -f -c shsh -l verbose -d "verbose on some commands, e.g. (un)linking"

# specific flags for different commands
complete -f -c shsh -n __fish_shsh_needs_command -l version -d "Show version number"
complete -f -c shsh -n "__fish_shsh_using_command get" -s f -l full -d 'show the full entry in $SHSHRC'
complete -f -c shsh -n "__fish_shsh_using_command list" -s d -l details -d "display more details of packages"
complete -f -c shsh -n "__fish_shsh_using_command upgrade" -s a -l all -d "performs on all packages"
complete -f -c shsh -n "__fish_shsh_using_command upgrade" -s f -l force -d "force upgrade a package even if up-to-date"
complete -f -c shsh -n "__fish_shsh_using_command upgrade" -l nohooks -d "do not execute saved hooks in SHSHRC"
complete -f -c shsh -n "__fish_shsh_using_command refresh" -s a -l all -d "performs on all packages"
complete -f -c shsh -n "__fish_shsh_using_command cleanup" -s d -l dry -d "perform a dry run"

complete -f -c shsh -n "__fish_shsh_using_command install" -s h -l hook -d "add hook to the package"
complete -f -c shsh -n "__fish_shsh_using_command install" -s v -l variable -d "set a variable during installation"
complete -f -c shsh -n "__fish_shsh_using_command install" -s f -l force -d "force the installation even if the package exists"
complete -f -c shsh -n "__fish_shsh_using_command install" -l nocleanup -d "do not perform cleanup"
complete -f -c shsh -n "__fish_shsh_using_command install" -l noconfirm -d "do not conform and perform sane default"
complete -f -c shsh -n "__fish_shsh_using_command install" -l ssh -d "use ssh protocal instead of https"
complete -f -c shsh -n "__fish_shsh_using_command install" -l plain -d "build a plain package from the ground up"
complete -f -c shsh -n "__fish_shsh_using_command install" -l gh-release -d "download binary from github release assets"

complete -f -c shsh -n "__fish_shsh_using_command uninstall" -l quiet -d "be quiet even if package does not exists"
complete -f -c shsh -n "__fish_shsh_using_command uninstall" -l use-rc -d "uninstall all packages not present in SHSHRC"
complete -f -c shsh -n "__fish_shsh_using_command uninstall" -l noconfirm -d "do not prompt to confirm"

complete -f -c shsh -n "__fish_shsh_using_command junest link" -a "(shsh junest linkable -d)"
complete -f -c shsh -n "__fish_shsh_using_command junest unlink" -a "(shsh junest linked -d)"
complete -f -c shsh -n "__fish_shsh_using_command junest linkable" -a "(shsh junest packages --details)"
complete -f -c shsh -n "__fish_shsh_using_command junest lookup" -a "(shsh junest linkable --details)"
