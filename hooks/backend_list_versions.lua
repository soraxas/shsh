local cmd = require("cmd")
local file = require("file")
local helper = require("lib.shsh")

-- How long a cached tag list is trusted before re-checking upstream. Matches
-- mise's own default `fetch_remote_versions_cache` TTL. mise re-invokes this
-- hook on every new shell session for `latest`-pinned tools (it does not
-- cache "latest" resolution itself), so without this the tool pays a live
-- `git ls-remote` on every new shell.
local CACHE_TTL_SECONDS = 3600

local function cache_path(tool)
    local dir = helper.shsh_root() .. "/.cache/backend-versions"
    return dir .. "/" .. tool:gsub("[/:]", "-") .. ".versions"
end

-- Parses cached content into a version list. An empty string is a valid,
-- legitimate cache entry (a repo with no tags at all) and must return an
-- empty table here, not nil -- nil is reserved for "no cache entry exists".
local function parse_cache(content)
    local versions = {}
    if content == nil then
        return versions
    end
    for line in content:gmatch("[^\n]+") do
        table.insert(versions, line)
    end
    return versions
end

local function read_fresh_cache(path)
    local stat = file.stat(path)
    if stat == nil or stat.modified == nil then
        return nil
    end
    local age = os.time() - stat.modified
    if age < 0 or age >= CACHE_TTL_SECONDS then
        return nil
    end
    local ok, content = pcall(file.read, path)
    if not ok then
        return nil
    end
    return parse_cache(content)
end

-- Used as a last resort when a live git ls-remote fails (e.g. no network),
-- regardless of age, so a transient outage doesn't make the tool disappear.
local function read_stale_cache(path)
    local ok, content = pcall(file.read, path)
    if not ok then
        return nil
    end
    return parse_cache(content)
end

local function write_cache(path, versions)
    local dir = path:match("^(.*)/[^/]+$")
    cmd.exec("mkdir -p " .. helper.shell_quote(dir))
    local content = table.concat(versions, "\n")
    cmd.exec("printf '%s' " .. helper.shell_quote(content) .. " > " .. helper.shell_quote(path))
end

local function fetch_versions(tool)
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
    return versions
end

function PLUGIN:BackendListVersions(ctx)
    helper.assert_unix()

    local tool = ctx.tool
    local path = cache_path(tool)

    local versions = read_fresh_cache(path)
    if versions == nil then
        local ok, result = pcall(fetch_versions, tool)
        if ok then
            versions = result
            write_cache(path, versions)
        else
            versions = read_stale_cache(path)
            if versions == nil then
                error(result)
            end
        end
    end

    table.insert(versions, "latest")
    return { versions = versions }
end
