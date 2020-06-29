function __fish_shsh_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'shsh' ]
    return 0
  end
  return 1
end

function __fish_shsh_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

function __fish_shsh_get_package_with_desc
  # get package with the verbose flag, where url will be display as package's description
  # remove the useless ".git" endings
  shsh list -v | awk 'match($0, /(^\S+).*\s+[(]https?:[/]{2}(.*)[)]/, m) {print m[1]"\t"m[2];}' \
  | string replace -r --all ".git\$" ""
end

# only have commands completions
#complete -f -c shsh -n '__fish_shsh_needs_command' -a '(shsh commands)'

# commands completions plus description
set -l shsh_cmds_with_desc (shsh help | awk -F '[[:space:]][[:space:]]+' '/^Some useful/,/^See/ {
  if ($2 != "") {
    print $2"\t"$3
  }
}' | string collect | string escape)
complete -f -c shsh -n '__fish_shsh_needs_command' -a "$shsh_cmds_with_desc"

for cmd in (shsh commands)
  if string match -q $cmd 'uninstall' 'upgrade' 'package-path' 'refresh'
    complete -f -c shsh -n "__fish_shsh_using_command $cmd" -a '(__fish_shsh_get_package_with_desc)'
  else
    complete -f -c shsh -n "__fish_shsh_using_command $cmd" -a "(shsh completions $cmd)"
  end
end

# add help flag to all commands
complete -x -c shsh -l help -d "show help message of a subcommand"