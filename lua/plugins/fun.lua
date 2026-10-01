-- Fun: gimmicks. Nothing useful, switched on by hand.

return {
    -- Particle explosions and screen shake while typing. Off unless asked for:
    -- the plugin auto-enables itself by default, `auto_enable` turns that off.
    {
        "axsaucedo/neovim-power-mode",
        main = "power-mode", -- module name differs from the repo name
        cmd = {
            "PowerModeEnable",
            "PowerModeDisable",
            "PowerModeToggle",
            "PowerModeStyle",
            "PowerModeShake",
            "PowerModeFireWall",
            "PowerModeInterrupt",
            "PowerModeStatus",
        },
        opts = {
            auto_enable = false,
        },
    },
}
