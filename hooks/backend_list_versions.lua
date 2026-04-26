local cmd = require("cmd")
local helper = require("lib.shsh")

function PLUGIN:BackendListVersions(ctx)
    helper.assert_unix()

    local tool = ctx.tool
    local repo_url = helper.repo_url(tool)
    local output = cmd.exec("git ls-remote --tags --refs " .. helper.shell_quote(repo_url))

    local seen = {}
    local versions = {}

    for line in output:gmatch("[^\n]+") do
        local tag = line:match("refs/tags/(%S+)$")
        if tag ~= nil then
            tag = helper.normalize_tag(tag)
            if tag ~= "" and not seen[tag] then
                seen[tag] = true
                table.insert(versions, tag)
            end
        end
    end

    table.sort(versions)
    table.insert(versions, "latest")
    return { versions = versions }
end
