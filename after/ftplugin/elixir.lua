-- gd for Elixir: ask the language server first, and when it has nothing —
-- which is what happens for Elixir and OTP themselves — resolve the source
-- from the local installation. See lua/util/elixir_source.lua.

--- Module and function under the cursor, e.g. "GenServer" and "abcast".
---@return string|nil module
---@return string|nil func
local function symbol_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- Widen to the whole dotted expression around the cursor.
    local from, to = col, col
    local function part_of_symbol(c)
        return c and c:match("[%w_.?!]") ~= nil
    end
    while part_of_symbol(line:sub(from - 1, from - 1)) do
        from = from - 1
    end
    while part_of_symbol(line:sub(to + 1, to + 1)) do
        to = to + 1
    end

    local symbol = line:sub(from, to)
    local module, func = symbol:match("^([A-Z][%w_.]*)%.([%l_][%w_?!]*)$")
    if module then
        return module, func
    end
    if symbol:match("^[A-Z][%w_.]*$") then
        return symbol, nil
    end
    return nil, nil
end

vim.keymap.set("n", "gd", function()
    local before = vim.api.nvim_buf_get_name(0)
    local pos = vim.api.nvim_win_get_cursor(0)

    vim.lsp.buf.definition()

    -- The request is async, so check a moment later whether it moved us.
    vim.defer_fn(function()
        local moved = vim.api.nvim_buf_get_name(0) ~= before
            or vim.api.nvim_win_get_cursor(0)[1] ~= pos[1]
        if moved then
            return
        end
        local module, func = symbol_under_cursor()
        if not module then
            return
        end
        local es = require("util.elixir_source")
        if not es.open(module, func) then
            vim.notify(es.missing_message(module), vim.log.levels.WARN)
        end
    end, 400)
end, { buffer = true, desc = "Go to definition (falls back to Elixir sources)" })
