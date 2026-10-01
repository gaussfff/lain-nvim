-- Finds the source file of an Elixir stdlib module.
--
-- A compiled .beam records the path of the machine that built it, which never
-- exists locally, so language servers answer "No locations found" for anything
-- in Elixir or OTP itself. The recorded path still carries the exact layout
-- inside the Elixir tree, so re-rooting it onto a local checkout works.
--
-- Requires an Elixir installation that ships sources. Homebrew's does not;
-- the official releases used by mise and asdf do.

local M = {}

local cache = {}

--- Version of the Elixir that is actually on PATH, e.g. "1.20.3".
---@return string|nil
local function running_version()
    local out = vim.system({ "elixir", "--version" }, { text = true }):wait()
    if out.code ~= 0 then
        return nil
    end
    return (out.stdout or ""):match("Elixir%s+([%d%.]+)")
end

--- Installations that may carry .ex sources.
---
--- Trees whose directory name matches the running Elixir come first, so an
--- upgrade never leaves you reading the previous version's source.
---@return string[]
local function source_roots()
    local exact, others = {}, {}
    local version = running_version()

    local function consider(dir)
        if vim.fn.isdirectory(dir .. "/lib/elixir/lib") ~= 1 then
            return
        end
        local name = vim.fn.fnamemodify(dir, ":t")
        if version and name:sub(1, #version) == version then
            exact[#exact + 1] = dir
        else
            others[#others + 1] = dir
        end
    end

    if vim.env.ELIXIR_SOURCE_PATH then
        consider(vim.env.ELIXIR_SOURCE_PATH)
    end
    for _, glob in ipairs({
        "~/.local/share/mise/installs/elixir/*",
        "~/.asdf/installs/elixir/*",
    }) do
        -- expand() handles both ~ and the wildcard and returns a list.
        for _, dir in ipairs(vim.fn.expand(glob, false, true)) do
            consider(dir)
        end
    end

    return vim.list_extend(exact, others)
end

--- Path the module was compiled from, as recorded in its .beam.
---@param module string
---@return string|nil
local function recorded_path(module)
    local script = table.concat({
        "[m | _] = System.argv()",
        "mod = Module.concat([m])",
        "with p when is_list(p) <- :code.which(mod),",
        "     {:ok, {_, [compile_info: i]}} <- :beam_lib.chunks(p, [:compile_info]),",
        "     s when not is_nil(s) <- Keyword.get(i, :source),",
        "  do: IO.puts(to_string(s))",
    }, "\n")

    local out = vim.system({ "elixir", "-e", script, module }, { text = true }):wait()
    if out.code ~= 0 then
        return nil
    end
    local path = vim.trim(out.stdout or "")
    return path ~= "" and path or nil
end

--- Re-root a recorded path onto a local tree by matching its longest suffix.
---@param recorded string
---@return string|nil
local function relocate(recorded)
    local parts = vim.split(recorded, "/", { plain = true })
    for _, root in ipairs(source_roots()) do
        for i = 1, #parts do
            local candidate = root .. "/" .. table.concat(parts, "/", i)
            if vim.fn.filereadable(candidate) == 1 then
                return candidate
            end
        end
    end
    return nil
end

--- Local source file of a stdlib module, or nil when it cannot be found.
---@param module string
---@return string|nil
function M.find(module)
    if cache[module] ~= nil then
        return cache[module] or nil
    end
    local recorded = recorded_path(module)
    local resolved = recorded and relocate(recorded) or nil
    cache[module] = resolved or false
    return resolved
end

--- Open the module's source, putting the cursor on the given function.
---@param module string
---@param func string|nil
---@return boolean opened
function M.open(module, func)
    local path = M.find(module)
    if not path then
        return false
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
    if func then
        M.jump_to(func)
    end
    return true
end

--- Put the cursor on the definition of `func` in the current buffer.
---
--- Documentation blocks contain code examples that look exactly like real
--- definitions, so the match with the smallest indentation wins: definitions
--- sit at module level, examples are nested deeper inside a heredoc.
---@param func string
function M.jump_to(func)
    local pattern = "^(%s*)def[a-z]*%s+" .. vim.pesc(func) .. "[%s(,]"
    local best_line, best_indent
    for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local indent = line:match(pattern)
        if indent and (not best_indent or #indent < best_indent) then
            best_line, best_indent = i, #indent
        end
    end
    if best_line then
        vim.api.nvim_win_set_cursor(0, { best_line, best_indent })
        vim.cmd("normal! zz")
    end
end

--- Explains why a module could not be resolved, and what to do about it.
---@param module string
---@return string
function M.missing_message(module)
    local version = running_version()
    if not version then
        return ("Cannot resolve %s: elixir is not on PATH."):format(module)
    end
    return table.concat({
        ("No sources for Elixir %s, so %s cannot be opened."):format(version, module),
        "Homebrew ships no .ex files; install a build that does:",
        ("  mise install elixir@%s"):format(version),
        "It does not need to be activated, it is only used as a source tree.",
    }, "\n")
end

return M
