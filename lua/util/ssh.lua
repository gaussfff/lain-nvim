-- Shortcut for oil's ssh adapter, so remote paths do not have to be typed
-- as full oil-ssh:// URLs.

local M = {}

--- Host names known to this machine, from /etc/hosts and the ssh config.
---
--- Only names you can actually connect to: ssh config patterns (iag-*) and
--- negations (!iag-prod-ansible) describe rules, not hosts, so they are left
--- out of completion.
---@return string[]
function M.hosts()
    local seen, hosts = {}, {}

    local function add(name)
        local usable = name ~= ""
            and name ~= "localhost"
            and not name:find("[*?]")
            and not name:match("^!")
        if usable and not seen[name] then
            seen[name] = true
            hosts[#hosts + 1] = name
        end
    end

    for _, line in ipairs(vim.fn.readfile("/etc/hosts")) do
        if not line:match("^%s*#") then
            -- Skip the address, keep every alias on the line.
            local names = line:gsub("^%s*%S+%s*", "")
            for name in names:gmatch("[^%s#]+") do
                if not name:match("^ip6%-") and not name:match("^broadcasthost$") then
                    add(name)
                end
            end
        end
    end

    local ssh_config = vim.fn.expand("~/.ssh/config")
    if vim.fn.filereadable(ssh_config) == 1 then
        for _, line in ipairs(vim.fn.readfile(ssh_config)) do
            local names = line:match("^%s*[Hh]ost%s+(.+)$")
            if names then
                for name in names:gmatch("%S+") do
                    if name ~= "*" then
                        add(name)
                    end
                end
            end
        end
    end

    table.sort(hosts)
    return hosts
end

--- Open a remote path through oil.
---
--- A path ending in "/" lists a directory; anything else opens the file
--- itself, fetched over scp and written back on :w.
---@param host string
---@param path string|nil defaults to the filesystem root
function M.open(host, path)
    path = path or "/"
    if not path:match("^/") then
        path = "/" .. path
    end
    vim.cmd.edit(vim.fn.fnameescape("oil-ssh://" .. host .. path))
end

return M
