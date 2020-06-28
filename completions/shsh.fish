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

complete -f -c shsh -n '__fish_shsh_needs_command' -a '(shsh commands)'
for cmd in (shsh commands)
  complete -f -c shsh -n "__fish_shsh_using_command $cmd" -a "(shsh completions $cmd)"
end
