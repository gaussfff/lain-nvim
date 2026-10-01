-- Entry point loaded by tests/run.sh inside a headless Neovim.

local dir = vim.env.NVIM_TESTS_DIR or (vim.fn.stdpath("config") .. "/tests")

local fixtures = dofile(dir .. "/fixtures.lua").create()
local ok = dofile(dir .. "/spec.lua").run(fixtures)

os.exit(ok and 0 or 1)
