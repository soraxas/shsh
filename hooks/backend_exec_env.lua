local file = require("file")
local helper = require("lib.shsh")

function PLUGIN:BackendExecEnv(ctx)
    helper.assert_unix()

    local install_path = ctx.install_path
    local env_vars = {
        { key = "PATH", value = file.join_path(install_path, "bin") },
        { key = "MANPATH", value = file.join_path(install_path, "man") },
        { key = "FPATH", value = file.join_path(install_path, "completions", "zsh", "compsys") },
    }

    return { env_vars = env_vars }
end
