local cmd = require("cmd")
local file = require("file")

local M = {}

local function trim(s)
	return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.assert_unix()
	if string.lower(RUNTIME.osType or "") == "windows" then
		error("shsh backend is only supported on Unix-like systems")
	end
end

function M.shell_quote(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

function M.validate_tool(tool)
	tool = trim(tool)
	if tool == "" then
		error("Tool name cannot be empty")
	end

	local parts = {}
	for part in tool:gmatch("[^/]+") do
		table.insert(parts, part)
	end

	if #parts ~= 2 and #parts ~= 3 then
		error("Tool name must be owner/repo or site/owner/repo")
	end

	for _, part in ipairs(parts) do
		if part == "" or part:match("%s") then
			error("Tool name contains invalid whitespace")
		end
	end

	return parts
end

function M.repo_url(tool)
	local parts = M.validate_tool(tool)
	if #parts == 2 then
		return "https://github.com/" .. parts[1] .. "/" .. parts[2] .. ".git"
	end

	return "https://" .. parts[1] .. "/" .. parts[2] .. "/" .. parts[3] .. ".git"
end

function M.normalize_tag(tag)
	return trim(tag):gsub("%^%{%}$", "")
end

function M.real_plugin_dir()
	return trim(cmd.exec("pwd -P", { cwd = RUNTIME.pluginDirPath }))
end

function M.shsh_root()
	local plugin_dir = M.real_plugin_dir()
	return trim(cmd.exec("pwd -P", { cwd = plugin_dir }))
end

function M.shsh_bin()
	return file.join_path(M.shsh_root(), "bin", "shsh")
end

function M.install_spec(tool, version)
	if version == nil or version == "" or version == "latest" then
		return tool
	end

	return tool .. "@" .. version
end

return M
