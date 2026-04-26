local cmd = require("cmd")
local file = require("file")
local helper = require("lib.shsh")

function PLUGIN:BackendInstall(ctx)
    helper.assert_unix()

    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path
    local shsh_root = helper.shsh_root()
    local shsh_bin = helper.shsh_bin()

    cmd.exec("mkdir -p " .. helper.shell_quote(install_path))

    local install_cmd = helper.shell_quote(shsh_bin)
        .. " install "
        .. helper.shell_quote(helper.install_spec(tool, version))

    cmd.exec(install_cmd, {
        cwd = shsh_root,
        env = {
            SHSH_ROOT = shsh_root,
            SHSH_PREFIX = install_path,
            SHSH_PACKAGES_PATH = file.join_path(install_path, "packages"),
            SHSH_INSTALL_BIN = file.join_path(install_path, "bin"),
            SHSH_INSTALL_MAN = file.join_path(install_path, "man"),
            SHSHRC = "",
            PATH = file.join_path(shsh_root, "libexec") .. ":" .. (os.getenv("PATH") or ""),
        },
    })

    return {}
end
