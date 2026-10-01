-- Creates throwaway projects for the language checks and describes what
-- correctly formatted output for each of them looks like.

local M = {}

local function write(path, text)
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    local file = assert(io.open(path, "w"))
    file:write(text)
    file:close()
end

---@return Fixture[]
function M.create()
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")

    local function at(relative)
        return root .. "/" .. relative
    end

    -- Rust: Cargo.toml is the root marker for rust_analyzer.
    write(at("rs/Cargo.toml"), '[package]\nname = "fixture"\nversion = "0.1.0"\nedition = "2021"\n')
    write(at("rs/src/main.rs"), 'fn main( ) {\nlet x=1;\nprintln!("{}",x);\n}\n')

    -- Elixir: mix.exs is the root marker for expert and the cwd for mix format.
    write(
        at("ex/mix.exs"),
        'defmodule Fixture.MixProject do\n  use Mix.Project\n  def project, do: [app: :fixture, version: "0.1.0"]\nend\n'
    )
    write(at("ex/.formatter.exs"), '[inputs: ["*.ex", "*.exs"]]\n')
    write(at("ex/a.ex"), "defmodule A do\ndef  x( ), do:   1\nend\n")

    -- TypeScript: package.json and tsconfig.json are the root markers for ts_ls.
    write(at("ts/package.json"), '{ "name": "fixture", "version": "1.0.0" }\n')
    write(at("ts/tsconfig.json"), '{ "compilerOptions": { "strict": true } }\n')
    write(at("ts/x.ts"), "const  x   =1\nfunction  f( a:number ){return a+x}\nconsole.log(f(2))\n")

    -- Go: go.mod is the root marker for gopls. The unused "os" import and the
    -- blank line after the brace are deliberate: only goimports fixes the
    -- first, and only gofumpt removes the second.
    write(at("go/go.mod"), "module fixture\n\ngo 1.25\n")
    write(
        at("go/main.go"),
        'package main\n\nimport "os"\n\nfunc  main( ){\n\n\tfmt.Println( "hi" )\n}\n'
    )

    -- A second, valid Go module. The one above is deliberately broken, and a
    -- package that does not type-check makes gopls answers unreliable.
    write(at("gotests/go.mod"), "module fixture\n\ngo 1.25\n")
    write(
        at("gotests/add.go"),
        'package main\n\nimport "fmt"\n\nfunc Add(a, b int) int {\n\treturn a + b\n}\n\nfunc main() {\n\tfmt.Println(Add(1, 2))\n}\n'
    )
    write(
        at("gotests/add_test.go"),
        'package main\n\nimport "testing"\n\nfunc TestAdd(t *testing.T) {\n\tif Add(1, 2) != 3 {\n\t\tt.Fatal("bad")\n\t}\n}\n'
    )

    -- PostgreSQL: postgres_lsp needs a root, .git is enough. The "::" cast
    -- proves the dialect: sql-formatter's default one rejects it outright.
    vim.fn.mkdir(at("sql/.git"), "p")
    write(at("sql/q.sql"), "select id::text,meta->>'role' from users where id=1;\n")

    -- Lua: .luarc.json is the root marker for lua_ls.
    write(at("lua/.luarc.json"), '{ "runtime.version": "LuaJIT" }\n')
    write(at("lua/m.lua"), "local  t={a=1,b=2}\nreturn   t\n")

    -- Bash: bashls looks for .git upwards.
    vim.fn.mkdir(at("sh/.git"), "p")
    write(at("sh/s.sh"), '#!/usr/bin/env bash\nfoo( ){\necho   "hi"\n}\n')

    -- Vue: package.json is the root marker for vue_ls and ts_ls.
    write(at("vue/package.json"), '{ "name": "fixture", "devDependencies": { "vue": "^3.5.0" } }\n')
    write(at("vue/tsconfig.json"), '{ "compilerOptions": { "strict": true } }\n')
    write(
        at("vue/App.vue"),
        '<script setup lang="ts">\nconst x = 1\n</script>\n\n<template>\n  <div>{{ x }}</div>\n</template>\n'
    )

    -- Svelte: the server looks for a lockfile or .git upwards.
    vim.fn.mkdir(at("svelte/.git"), "p")
    write(
        at("svelte/package.json"),
        '{ "name": "fixture", "devDependencies": { "svelte": "^5.0.0" } }\n'
    )
    write(
        at("svelte/src/Page.svelte"),
        '<script lang="ts">\n  let count = 0;\n</script>\n\n<button>{count}</button>\n'
    )

    -- Config formats: jsonls and yamlls attach anywhere, taplo wants .git.
    vim.fn.mkdir(at("conf/.git"), "p")
    write(at("conf/data.json"), '{"name":"fixture","version":"1.0.0"}\n')
    write(at("conf/data.yaml"), "name: fixture\nversion: 1\n")
    write(at("conf/data.toml"), 'name = "fixture"\nversion = 1\n')

    -- .conf has no grammar of its own; treesitter.lua maps it to properties.
    write(at("conf/app.conf"), "# ports\nPORT=8080\nDEBUG=true\n")

    -- Fish: fish_lsp looks for config.fish or .git.
    write(at("fish/config.fish"), "# fixture\n")
    write(at("fish/c.fish"), 'function foo\necho "hi"\nend\n')

    return {
        {
            name = "rust",
            file = at("rs/src/main.rs"),
            ft = "rust",
            lsp = "rust-analyzer", -- rustaceanvim names it with a hyphen
            formatter = "rustfmt",
            expected = 'fn main() {\n    let x = 1;\n    println!("{}", x);\n}',
        },
        {
            name = "elixir",
            file = at("ex/a.ex"),
            ft = "elixir",
            lsp = "expert",
            formatter = "mix",
            expected = "defmodule A do\n  def x(), do: 1\nend",
        },
        {
            name = "typescript",
            file = at("ts/x.ts"),
            ft = "typescript",
            lsp = "ts_ls",
            formatter = "prettierd",
            expected = "const x = 1;\nfunction f(a: number) {\n  return a + x;\n}\nconsole.log(f(2));",
        },
        {
            name = "go",
            file = at("go/main.go"),
            ft = "go",
            lsp = "gopls",
            formatter = "goimports",
            expected = 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("hi")\n}',
        },
        {
            name = "sql",
            file = at("sql/q.sql"),
            ft = "sql",
            lsp = "postgres_lsp",
            formatter = "sql_formatter",
            expected = "select\n    id::text,\n    meta ->> 'role'\nfrom\n    users\nwhere\n    id = 1;",
        },
        {
            name = "lua",
            file = at("lua/m.lua"),
            ft = "lua",
            lsp = "lua_ls",
            formatter = "stylua",
            expected = "local t = { a = 1, b = 2 }\nreturn t",
        },
        {
            name = "bash",
            file = at("sh/s.sh"),
            ft = "sh",
            lsp = "bashls",
            formatter = "shfmt",
            -- shfmt indents with the buffer's shiftwidth, which is 4 here.
            expected = '#!/usr/bin/env bash\nfoo() {\n    echo "hi"\n}',
        },
        {
            name = "json",
            file = at("conf/data.json"),
            ft = "json",
            lsp = "jsonls",
            formatter = "prettierd",
            expected = '{ "name": "fixture", "version": "1.0.0" }',
        },
        {
            name = "yaml",
            file = at("conf/data.yaml"),
            ft = "yaml",
            lsp = "yamlls",
            formatter = "prettierd",
            expected = "name: fixture\nversion: 1",
        },
        {
            name = "toml",
            file = at("conf/data.toml"),
            ft = "toml",
            lsp = "taplo",
            formatter = "taplo",
            expected = 'name = "fixture"\nversion = 1',
        },
        {
            name = "vue",
            file = at("vue/App.vue"),
            ft = "vue",
            lsp = "vue_ls",
            formatter = "prettierd",
            expected = '<script setup lang="ts">\nconst x = 1;\n</script>\n\n<template>\n  <div>{{ x }}</div>\n</template>',
        },
        {
            name = "fish",
            file = at("fish/c.fish"),
            ft = "fish",
            lsp = "fish_lsp",
            formatter = "fish_indent",
            expected = "function foo\n    echo hi\nend",
        },
    }
end

return M
