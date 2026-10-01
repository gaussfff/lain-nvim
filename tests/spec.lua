-- Runtime checks for the config. Run through tests/run.sh, not directly.

local M = {}

local COLORS = {
    reset = "\27[0m",
    dim = "\27[90m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    bold = "\27[1m",
}

local passed, failed, skipped = 0, 0, 0

local function out(s)
    io.stderr:write(s)
end

local function header(title)
    out(("\n%s%s%s\n"):format(COLORS.bold, title, COLORS.reset))
end

---@param name string
---@param ok boolean|nil nil marks the check as skipped
---@param detail string|nil
local function report(name, ok, detail)
    local mark, color
    if ok == nil then
        mark, color, skipped = "○", COLORS.yellow, skipped + 1
    elseif ok then
        mark, color, passed = "✓", COLORS.green, passed + 1
    else
        mark, color, failed = "✗", COLORS.red, failed + 1
    end
    -- Pad by display width, not byte length, so the columns line up.
    local pad = string.rep(" ", math.max(0, 34 - vim.fn.strdisplaywidth(name)))
    out(
        ("  %s%s%s %s%s %s%s%s\n"):format(
            color,
            mark,
            COLORS.reset,
            name,
            pad,
            COLORS.dim,
            detail or "",
            COLORS.reset
        )
    )
end

local function wait_for(fn, timeout)
    return vim.wait(timeout or 30000, fn, 200)
end

--- Plugins that must be present and loadable.
local function check_plugins()
    header("Plugins")
    local plugins = require("lazy.core.config").plugins
    for _, name in ipairs({
        "oil.nvim",
        "conform.nvim",
        "nvim-lspconfig",
        "mason.nvim",
        "mason-lspconfig.nvim",
        "mason-tool-installer.nvim",
        "lazydev.nvim",
        "noice.nvim",
        "nvim-treesitter",
        "blink.cmp",
        "schemastore.nvim",
        "neovim-power-mode",
        "smart-splits.nvim",
        "nordic.nvim",
        "indent-blankline.nvim",
        "nvim-ufo",
        "nvim-autopairs",
        "flash.nvim",
        "codediff.nvim",
        "lazygit.nvim",
        "neotest",
        "snacks.nvim",
        "nvim-web-devicons",
        "vim-illuminate",
    }) do
        report(name, plugins[name] ~= nil, plugins[name] and "present" or "missing")
    end
end

--- Svelte is checked apart from the language loop: prettier cannot parse
--- .svelte without a plugin, so formatting comes from the server itself.
---@param fixtures Fixture[]
local function check_svelte(fixtures)
    header("Svelte")

    local root = vim.fn.fnamemodify(fixtures[1].file, ":h:h:h")
    local file = root .. "/svelte/src/Page.svelte"
    vim.cmd.edit(vim.fn.fnameescape(file))
    wait_for(function()
        return #vim.lsp.get_clients({ bufnr = 0, name = "svelte" }) > 0
    end)

    local buf = vim.api.nvim_get_current_buf()
    report("filetype", vim.bo.filetype == "svelte", vim.bo.filetype)

    local attached = #vim.lsp.get_clients({ bufnr = buf, name = "svelte" }) > 0
    report("language server", attached, attached and "svelte" or "did not attach")

    local hl = vim.treesitter.highlighter.active[buf] ~= nil
    report("highlighting", hl, hl and "treesitter active" or "NOT ACTIVE")

    local client = vim.lsp.get_clients({ bufnr = buf, name = "svelte" })[1]
    local can_format = client ~= nil
        and client.server_capabilities.documentFormattingProvider ~= nil
    report("formatting", can_format, can_format and "through the server" or "unavailable")
end

--- Oil must list dotfiles but leave the ".." entry out.
local function check_file_listing()
    header("File listing")

    local view = require("oil.view")
    report("dotfiles shown", view.should_display(".luarc.json", 0), "hidden files listed")

    local parent_shown = view.should_display("..", 0)
    report(
        "no parent entry",
        not parent_shown,
        parent_shown and '".." present' or '"-" goes up instead'
    )

    -- The toggle stays reachable; only the five zellij keys were removed.
    local toggle = require("oil.config").keymaps["g."]
    local kept = toggle and toggle[1] == "actions.toggle_hidden"
    report("g. still bound", kept, kept and "toggles hidden files" or "lost")
end

--- The :Ssh shortcut and its host completion (no network involved).
local function check_ssh_shortcut()
    header("Remote paths")

    local exists = vim.fn.exists(":Ssh") == 2
    report(":Ssh", exists, exists and "command available" or "missing")
    if not exists then
        return
    end

    local hosts = require("util.ssh").hosts()
    report("hosts discovered", #hosts > 0, #hosts .. " from /etc/hosts and ssh config")

    -- Patterns and negations describe rules, not reachable hosts.
    local junk = vim.tbl_filter(function(h)
        return h:find("[*?]") ~= nil or h:match("^!") ~= nil
    end, hosts)
    report("no patterns", #junk == 0, #junk == 0 and "only real names" or table.concat(junk, " "))

    local completed = vim.fn.getcompletion("Ssh ", "cmdline")
    report("completion works", #completed > 0, #completed .. " suggestions")
end

--- .conf files have no grammar of their own and must be mapped to one.
local function check_conf_files()
    header("Conf files")

    local tmp = vim.fn.tempname() .. ".conf"
    vim.fn.writefile({ "# ports", "PORT=8080", "DEBUG=true" }, tmp)
    vim.cmd.edit(vim.fn.fnameescape(tmp))
    vim.wait(500)

    local buf = vim.api.nvim_get_current_buf()
    report("filetype", vim.bo.filetype == "conf", vim.bo.filetype)

    local lang = vim.treesitter.language.get_lang("conf")
    report("mapped grammar", lang == "properties", lang or "none")

    local hl = vim.treesitter.highlighter.active[buf] ~= nil
    report("highlighting", hl, hl and "treesitter active" or "NOT ACTIVE")

    report("comment string", vim.bo.commentstring == "# %s", vim.bo.commentstring)

    vim.fn.delete(tmp)
end

--- Colorscheme and folding.
local function check_appearance()
    header("Appearance and folds")

    local scheme = vim.g.colors_name
    report("colorscheme", scheme == "nordic", scheme or "not set")

    local folds_ok = vim.o.foldlevel >= 99 and vim.o.foldenable
    report(
        "fold options",
        folds_ok,
        ("foldcolumn=%s foldlevel=%d"):format(vim.o.foldcolumn, vim.o.foldlevel)
    )

    -- Punctuation must not be italic: it catches ":" in type annotations.
    local delimiter = vim.api.nvim_get_hl(0, { name = "Delimiter" })
    report("punctuation upright", not delimiter.italic, "Delimiter without italic")

    -- Comments are the one place italic is wanted, so guard it from the above.
    local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
    report("comments italic", comment.italic == true, "italic_comments still on")

    -- dashboard-nvim owns the start screen; the snacks module must stay off.
    local plugins = require("lazy.core.config").plugins
    local dash = plugins["dashboard-nvim"] ~= nil
    local snacks_dash = Snacks and Snacks.config.dashboard.enabled == true
    report(
        "dashboard",
        dash and not snacks_dash,
        dash and (snacks_dash and "BOTH ENABLED" or "dashboard-nvim") or "missing"
    )

    require("lazy").load({ plugins = { "lualine.nvim" } })
    local global = vim.o.laststatus == 3
    report(
        "statusline",
        global,
        global and "lualine, one line for the editor" or "laststatus=" .. vim.o.laststatus
    )
end

--- Window navigation must reach smart-splits, not plain <C-w> mappings.
local function check_splits()
    header("Window navigation")

    for _, key in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
        local rhs = vim.fn.maparg(key, "n")
        local ok = rhs:match("smart%-splits") ~= nil or rhs:match("windows%.lua") ~= nil
        report(key .. " mapped", ok, ok and "smart-splits" or (rhs ~= "" and rhs or "unmapped"))
    end

    local in_session = require("smart-splits.mux.zellij").is_in_session()
    report(
        "zellij detected",
        in_session ~= nil,
        in_session and "inside a session" or "not in a session"
    )
end

--- Power mode must stay dormant until asked for by command.
local function check_power_mode()
    local plugin = require("lazy.core.config").plugins["neovim-power-mode"]
    local dormant = plugin ~= nil and plugin._.loaded == nil
    report("power mode dormant", dormant, dormant and "loads on command" or "LOADED ON ITS OWN")

    local has_cmd = vim.fn.exists(":PowerModeToggle") == 2
    report("command available", has_cmd, has_cmd and ":PowerModeToggle" or "command missing")
end

--- Packages Mason is supposed to keep installed.
local function check_mason()
    header("Mason packages")
    local ok, registry = pcall(require, "mason-registry")
    if not ok then
        report("mason-registry", false, "failed to load")
        return
    end
    for _, pkg in ipairs({
        "expert",
        "typescript-language-server",
        "lua-language-server",
        "bash-language-server",
        "fish-lsp",
        "prettierd",
        "stylua",
        "shfmt",
        "json-lsp",
        "yaml-language-server",
        "taplo",
    }) do
        report(
            pkg,
            registry.is_installed(pkg),
            registry.is_installed(pkg) and "installed" or "NOT INSTALLED"
        )
    end
end

--- Binaries that must come from the system, not from Mason.
local function check_system_tools()
    header("System tools")
    for _, tool in ipairs({ "rust-analyzer", "rustfmt" }) do
        local path = vim.fn.exepath(tool)
        local from_cargo = path:match("/%.cargo/bin/") ~= nil
        report(
            tool,
            from_cargo,
            from_cargo and path
                or ("should come from ~/.cargo/bin, got " .. (path ~= "" and path or "not found"))
        )
    end
    for _, tool in ipairs({ "mix", "fish_indent", "lazygit", "git" }) do
        local path = vim.fn.exepath(tool)
        report(tool, path ~= "", path ~= "" and path or "not in PATH")
    end
end

--- Treesitter parsers required for highlighting and for noice.
local function check_parsers()
    header("Treesitter parsers")
    for _, lang in ipairs({
        "rust",
        "elixir",
        "heex",
        "typescript",
        "lua",
        "bash",
        "fish",
        "markdown_inline",
    }) do
        local ok = pcall(vim.treesitter.language.inspect, lang)
        report(lang, ok, ok and "installed" or "NOT INSTALLED")
    end
end

--- Completion capabilities have to reach the servers when they start.
local function check_completion()
    header("Completion")

    local loaded = package.loaded["blink.cmp"] ~= nil
    report("blink.cmp loaded", loaded, loaded and "before the servers" or "NOT LOADED")

    local ok_store, store = pcall(require, "schemastore")
    local count = ok_store and #store.json.schemas() or 0
    report(
        "schema catalog",
        count > 0,
        count > 0 and (count .. " json schemas") or "failed to load"
    )

    local client = vim.lsp.get_clients()[1]
    if not client then
        report("server capabilities", false, "no server running")
        return
    end
    local item =
        vim.tbl_get(client.config, "capabilities", "textDocument", "completion", "completionItem")
    local folding = vim.tbl_get(client.config, "capabilities", "textDocument", "foldingRange")
    report(
        "foldingRange sent",
        folding ~= nil,
        folding and "ufo can fold via LSP" or "capability missing"
    )

    local ok = item ~= nil and item.snippetSupport == true
    report(
        "capabilities of " .. client.name,
        ok,
        ok and "snippetSupport sent" or "blink loaded after the server"
    )
end

---@class Fixture
---@field name string
---@field file string
---@field ft string
---@field lsp string
---@field formatter string
---@field expected string

--- Open each fixture, wait for the language server, format and compare.
---@param fixtures Fixture[]
local function check_languages(fixtures)
    header("Language servers")
    local formatting = {}

    for _, fx in ipairs(fixtures) do
        vim.cmd.edit(vim.fn.fnameescape(fx.file))
        local buf = vim.api.nvim_get_current_buf()

        local ft_ok = vim.bo[buf].filetype == fx.ft
        report(fx.name .. " · filetype", ft_ok, vim.bo[buf].filetype)

        -- On the treesitter main branch highlighting is not automatic; the
        -- FileType autocommand in treesitter.lua has to switch it on.
        local hl = vim.treesitter.highlighter.active[buf] ~= nil
        report(fx.name .. " · highlighting", hl, hl and "treesitter active" or "NOT ACTIVE")

        if fx.name == "lua" then
            local winbar = vim.wo.winbar ~= ""
            report("winbar breadcrumbs", winbar, winbar and "dropbar" or "empty")
        end

        -- Wait for the expected server by name: a file can attract several
        -- (a .vue buffer gets both vue_ls and ts_ls) and they start at
        -- different speeds.
        wait_for(function()
            return #vim.lsp.get_clients({ bufnr = buf, name = fx.lsp }) > 0
        end)
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            names[#names + 1] = client.name
        end
        if fx.name == "rust" then
            -- rustaceanvim is a filetype plugin and registers its command
            -- once the client is up, so this check waits for it.
            local has_cmd = vim.wait(5000, function()
                return vim.fn.exists(":RustLsp") == 2
            end, 200)
            report("rust · :RustLsp", has_cmd, has_cmd and "rustaceanvim commands" or "missing")
        end

        report(
            fx.name .. " · LSP",
            vim.tbl_contains(names, fx.lsp),
            #names > 0 and table.concat(names, ", ") or "did not attach"
        )

        formatting[#formatting + 1] = { fx = fx, buf = buf }
    end

    header("Formatting")
    for _, item in ipairs(formatting) do
        local fx, buf = item.fx, item.buf
        vim.api.nvim_set_current_buf(buf)

        local found = {}
        for _, f in ipairs(require("conform").list_formatters_to_run(buf)) do
            found[#found + 1] = f.name
            if not f.available then
                found[#found] = f.name .. " (no binary)"
            end
        end
        report(
            fx.name .. " · formatter",
            vim.tbl_contains(found, fx.formatter),
            table.concat(found, ", ")
        )

        require("conform").format({ bufnr = buf, timeout_ms = 10000, lsp_format = "fallback" })
        local got = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        local want = vim.trim(fx.expected)
        report(
            fx.name .. " · output",
            vim.trim(got) == want,
            vim.trim(got) == want and "matches expected" or "MISMATCH"
        )
    end
end

--- Illuminate replaced snacks.words, and its Alt keymaps had to go.
local function check_references()
    header("References")

    local loaded = package.loaded["illuminate"] ~= nil
    report("illuminate loaded", loaded, loaded and "highlighting references" or "NOT LOADED")

    for _, key in ipairs({ "]r", "[r" }) do
        local ok = vim.fn.maparg(key, "n") ~= ""
        report(key .. " mapped", ok, ok and "jump between references" or "missing")
    end

    local leftover = vim.fn.maparg("<A-n>", "n") ~= ""
    report(
        "no <A-n> leftover",
        not leftover,
        leftover and "STILL MAPPED" or "removed, zellij owns it"
    )

    local words_off = not (Snacks and Snacks.config.words.enabled)
    report("snacks.words off", words_off, words_off and "no duplicate highlighter" or "DUPLICATE")
end

--- rustaceanvim owns rust-analyzer; a second client would mean a double setup.
local function check_rust()
    header("Rust")

    local in_servers = false
    for line in io.lines(vim.fn.stdpath("config") .. "/lua/plugins/lsp.lua") do
        if line:match("rust_analyzer%s*=") then
            in_servers = true
        end
    end
    report(
        "no duplicate setup",
        not in_servers,
        in_servers and "lsp.lua ALSO configures it" or "only rustaceanvim"
    )

    require("lazy").load({ plugins = { "neotest" } })
    local rust_adapter = false
    for _, a in ipairs(require("neotest.config").adapters) do
        if tostring(a.name or ""):lower():match("rust") then
            rust_adapter = true
        end
    end
    report("neotest adapter", rust_adapter, rust_adapter and "tests runnable" or "missing")
end

--- Yank history has to survive both a put and a restart.
local function check_yank()
    header("Yank history")

    require("lazy").load({ plugins = { "yanky.nvim" } })

    local ok, history = pcall(require, "yanky.history")
    report("yanky loaded", ok, ok and "history tracked" or "NOT LOADED")
    if not ok then
        return
    end

    local storage = require("yanky.config").options.ring.storage
    report(
        "storage",
        storage == "sqlite",
        storage .. (storage == "sqlite" and ", survives restarts" or "")
    )

    local put = vim.fn.maparg("p", "n"):match("Yanky") ~= nil
    report("p goes through yanky", put, put and "put records history" or "plain put")
end

--- PostgreSQL: the parts the shared fixture loop does not cover.
---@param fixtures Fixture[]
local function check_sql(fixtures)
    header("PostgreSQL")

    local ft = vim.filetype.match({ filename = "schema.pgsql" })
    report(".pgsql detected", ft == "sql", ft or "untyped")

    local root = vim.fn.fnamemodify(fixtures[1].file, ":h:h:h") .. "/sql"
    vim.cmd.edit(vim.fn.fnameescape(root .. "/q.sql"))
    local buf = vim.api.nvim_get_current_buf()

    -- The built-in ftplugin would make <C-c> wait out timeoutlen in insert.
    local chords = 0
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, "i")) do
        if map.lhs:find("^<C%-C>") then
            chords = chords + 1
        end
    end
    report(
        "<C-c> in insert",
        chords == 0,
        chords == 0 and "leaves instantly" or chords .. " chords"
    )

    -- Without a config file the server must still find real syntax errors.
    local broken = root .. "/broken.sql"
    vim.fn.writefile({ "select * from;" }, broken)
    vim.cmd.edit(vim.fn.fnameescape(broken))
    local bbuf = vim.api.nvim_get_current_buf()
    wait_for(function()
        return #vim.diagnostic.get(bbuf, { severity = vim.diagnostic.severity.ERROR }) > 0
    end)
    local errors = vim.diagnostic.get(bbuf, { severity = vim.diagnostic.severity.ERROR })
    report(
        "syntax diagnostics",
        #errors > 0,
        #errors > 0 and errors[1].message:gsub("\n.*", "") or "none without a config file"
    )

    -- A project's .sql-formatter.json must win over our Postgres defaults.
    local team = root .. "/team"
    vim.fn.mkdir(team, "p")
    vim.fn.writefile(
        { '{ "language": "postgresql", "keywordCase": "upper" }' },
        team .. "/.sql-formatter.json"
    )
    vim.fn.writefile({ "select 1;" }, team .. "/t.sql")
    vim.cmd.edit(vim.fn.fnameescape(team .. "/t.sql"))
    local tbuf = vim.api.nvim_get_current_buf()
    require("conform").format({ bufnr = tbuf, timeout_ms = 10000 })
    local first = vim.api.nvim_buf_get_lines(tbuf, 0, 1, false)[1]
    report(
        "project config wins",
        first == "SELECT",
        first == "SELECT" and "keywordCase from the file" or first
    )
end

--- Go: the parts the shared fixture loop does not cover.
---@param fixtures Fixture[]
local function check_go(fixtures)
    header("Go")

    local root = vim.fn.fnamemodify(fixtures[1].file, ":h:h:h") .. "/gotests"
    vim.cmd.edit(vim.fn.fnameescape(root .. "/add.go"))
    local buf = vim.api.nvim_get_current_buf()

    wait_for(function()
        return #vim.lsp.get_clients({ bufnr = buf, name = "gopls" }) > 0
    end)
    local client = vim.lsp.get_clients({ bufnr = buf, name = "gopls" })[1]
    report("gopls attaches", client ~= nil, client and "in the second module" or "NOT ATTACHED")
    if not client then
        return
    end

    local gofumpt = vim.tbl_get(client.config.settings or {}, "gopls", "gofumpt")
    report("gofumpt setting", gofumpt == true, "gopls edits match conform")

    -- Unlike Elixir, Go ships its sources, so this jump has to work.
    vim.api.nvim_win_set_cursor(0, { 10, 6 }) -- fmt.Println
    local responses = vim.lsp.buf_request_sync(
        buf,
        "textDocument/definition",
        vim.lsp.util.make_position_params(0, client.offset_encoding),
        10000
    )
    local target
    for _, response in pairs(responses or {}) do
        local first = response.result and (response.result[1] or response.result)
        target = target or (first and (first.uri or first.targetUri))
    end
    local path = target and vim.uri_to_fname(target) or ""
    local in_stdlib = path:match("/src/fmt/") ~= nil
    report("jump into stdlib", in_stdlib, in_stdlib and vim.fs.basename(path) or "did not resolve")

    -- Loading the adapter before neotest itself is a circular require.
    require("neotest")
    local registered = false
    for _, adapter in ipairs(require("neotest.config").adapters) do
        registered = registered or adapter.name == "neotest-golang"
    end
    report("neotest adapter", registered, registered and "neotest-golang" or "NOT REGISTERED")

    local found, done = {}, false
    require("nio").run(function()
        local tree = require("neotest-golang")({ runner = "gotestsum" }).discover_positions(
            root .. "/add_test.go"
        )
        if tree then
            for _, node in tree:iter() do
                if node.type == "test" then
                    found[#found + 1] = node.name
                end
            end
        end
        done = true
    end)
    vim.wait(30000, function()
        return done
    end, 100)
    report(
        "test discovery",
        #found > 0,
        #found > 0 and table.concat(found, ", ") or "found nothing"
    )
end

--- Language servers cannot jump into Elixir itself, because a .beam records
--- the path of the machine that built it. The config resolves it instead.
local function check_elixir_source()
    header("Elixir stdlib sources")

    local ok, es = pcall(require, "util.elixir_source")
    report("resolver loads", ok, ok and "util.elixir_source" or "MISSING")
    if not ok then
        return
    end

    for _, mod in ipairs({ "GenServer", "Enum", "Mix.Task" }) do
        local path = es.find(mod)
        report(
            mod,
            path ~= nil,
            path and vim.fn.fnamemodify(path, ":t") or "no source tree with .ex files"
        )
    end

    -- An Elixir upgrade must not leave us reading the previous version.
    local path = es.find("GenServer")
    local running = vim.system({ "elixir", "--version" }, { text = true }):wait().stdout or ""
    local version = running:match("Elixir%s+([%d%.]+)")
    local tree = path and path:match("/elixir/([^/]+)/lib/") or nil
    local matches = version ~= nil and tree ~= nil and tree:sub(1, #version) == version
    report("version matches", matches, tree and (tree .. " vs " .. (version or "?")) or "no tree")
end

--- Cyrillic keys must be silent in command modes but still type in insert.
local function check_cyrillic()
    header("Cyrillic layout")

    local silenced = 0
    for _, key in ipairs({ "ф", "ы", "в", "Ф", "і", "ї", "є", "ґ" }) do
        if vim.fn.maparg(key, "n") == "<Nop>" then
            silenced = silenced + 1
        end
    end
    report("silenced in normal", silenced == 8, silenced .. " of 8 sample letters")

    for _, mode in ipairs({ "x", "o" }) do
        local mapped = vim.fn.maparg("ф", mode) == "<Nop>"
        report("silenced in " .. mode, mapped, mapped and "no beep" or "still errors")
    end

    -- Typing must keep working: insert and cmdline are deliberately untouched.
    local typable = vim.fn.maparg("ф", "i") == "" and vim.fn.maparg("ф", "c") == ""
    report("typing unaffected", typable, typable and "insert and cmdline free" or "SHADOWED")

    -- The Latin key on the same physical button must still do its job.
    local latin_free = vim.fn.maparg("a", "n") == ""
    report("latin untouched", latin_free, latin_free and "commands still work" or "shadowed")
end

--- which-key must know the prefix names, and its health check must be clean.
local function check_whichkey()
    header("Key discovery")

    require("lazy").load({ plugins = { "which-key.nvim" } })
    local loaded = package.loaded["which-key"] ~= nil
    report("which-key loaded", loaded, loaded and "prefix popup available" or "NOT LOADED")

    local helper = vim.fn.maparg("<leader>?", "n") ~= ""
    report("<leader>? mapped", helper, helper and "buffer-local keymaps" or "missing")

    -- Every mapping needs a desc, otherwise the popup shows a bare key.
    local missing = 0
    for _, mode in ipairs({ "n", "x", "o" }) do
        for _, k in ipairs(vim.api.nvim_get_keymap(mode)) do
            if k.lhs:match("^ ") and (not k.desc or k.desc == "") then
                missing = missing + 1
            end
        end
    end
    report(
        "leader keys described",
        missing == 0,
        missing == 0 and "all have desc" or (missing .. " without desc")
    )
end

--- The finder needs its native sorter built and ripgrep on PATH.
local function check_finder()
    header("Fuzzy finder")

    require("lazy").load({ plugins = { "telescope.nvim" } })

    local loaded = package.loaded["telescope"] ~= nil
    report("telescope loaded", loaded, loaded and "master branch" or "NOT LOADED")

    local fzf = loaded and require("telescope").extensions.fzf ~= nil
    report("fzf-native built", fzf, fzf and "native sorter active" or "extension missing")

    for _, tool in ipairs({ "rg", "fd" }) do
        local path = vim.fn.exepath(tool)
        report(tool, path ~= "", path ~= "" and path or "not in PATH")
    end
end

--- Inline blame is the reason gitsigns is here, so check it is actually on.
local function check_blame()
    header("Git blame")

    require("lazy").load({ plugins = { "gitsigns.nvim" } })
    local ok, gs = pcall(require, "gitsigns")
    report("gitsigns loaded", ok, ok and "signs and blame" or "NOT LOADED")
    if not ok then
        return
    end

    local cfg = require("gitsigns.config").config
    report(
        "inline blame",
        cfg.current_line_blame == true,
        cfg.current_line_blame and "on by default" or "off"
    )

    -- The namespace is created lazily on first render, so check the config
    -- that drives it instead of the runtime artefact.
    local fmt = cfg.current_line_blame_formatter
    local has_author = type(fmt) == "string" and fmt:find("<author>") ~= nil
    report("blame format", has_author, has_author and "author, date, summary" or tostring(fmt))

    for _, key in ipairs({ "<leader>gb", "]h", "[h" }) do
        local mapped = vim.fn.maparg(key, "n") ~= ""
        report(key, mapped, mapped and "mapped" or "missing")
    end
end

--- Git tooling is lazy-loaded, so only the commands should exist up front.
local function check_git()
    header("Git tools")

    for _, cmd in ipairs({ "CodeDiff", "LazyGit", "LazyGitCurrentFile", "GrugFar", "Trouble" }) do
        local ok = vim.fn.exists(":" .. cmd) == 2
        report(":" .. cmd, ok, ok and "available" or "missing")
    end
end

--- Flash takes over s/S, but must leave normal-mode r and R alone.
local function check_motions()
    header("Motions")

    for _, key in ipairs({ "s", "S" }) do
        local mapped = vim.fn.maparg(key, "n") ~= ""
        report(key .. " is flash", mapped, mapped and "jump" or "not mapped")
    end

    for _, key in ipairs({ "r", "R" }) do
        local free = vim.fn.maparg(key, "n") == ""
        report(key .. " left to vim", free, free and "replace still works" or "SHADOWED")
    end
end

--- Pairs are closed while typing, and treesitter keeps them out of strings.
local function check_pairs()
    header("Auto pairs")

    ---@param name string
    ---@param before string text already on the line
    ---@param key string the character to type at the end of it
    ---@param want string what the line should look like afterwards
    local function typed(name, before, key, want)
        vim.cmd("enew!")
        vim.bo.filetype = "lua"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { before })
        vim.api.nvim_win_set_cursor(0, { 1, #before })
        vim.fn.feedkeys("a" .. key, "x")
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x")
        local got = vim.api.nvim_buf_get_lines(0, 0, -1, false)[1]
        report(name, got == want, "[" .. got .. "]")
    end

    typed("bracket closed", "x = ", "(", "x = ()")
    typed("quote closed", "x = ", "'", "x = ''")
    typed("quote left alone in a string", 'x = "it', "'", "x = \"it'")
end

---@param fixtures Fixture[]
function M.run(fixtures)
    out(("%sNeovim config check%s\n"):format(COLORS.bold, COLORS.reset))

    check_plugins()
    check_appearance()
    check_conf_files()
    check_file_listing()
    check_ssh_shortcut()
    check_splits()
    check_power_mode()
    check_mason()
    check_system_tools()
    check_parsers()
    check_languages(fixtures)
    check_svelte(fixtures)
    check_completion()
    check_pairs()
    check_motions()
    check_go(fixtures)
    check_sql(fixtures)
    check_elixir_source()
    check_cyrillic()
    check_whichkey()
    check_finder()
    check_rust()
    check_yank()
    check_git()
    check_blame()
    check_references()

    local total = passed + failed + skipped
    local color = failed == 0 and COLORS.green or COLORS.red
    out(("\n%s%s%d of %d checks passed%s"):format(COLORS.bold, color, passed, total, COLORS.reset))
    if failed > 0 then
        out((", %s%d failed%s"):format(COLORS.red, failed, COLORS.reset))
    end
    if skipped > 0 then
        out((", %s%d skipped%s"):format(COLORS.yellow, skipped, COLORS.reset))
    end
    out("\n\n")

    return failed == 0
end

return M
