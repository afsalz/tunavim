<p align="center">
  <img src="logo.svg" alt="TunaVim logo" width="220">
</p>

<h1 align="center">TunaVim</h1>

<p align="center"><em>Tap into perpetual motion.</em></p>

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.12%2B-57A143?logo=neovim&logoColor=white" alt="Neovim 0.12+">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
</p>

My custom Neovim configuration — fast, single-file-first, and built on top of
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Plugins are
managed with Neovim's built-in `vim.pack` — no external plugin manager
required.

> [!WARNING]
> **Work in progress.** This is very much a "works on my machine" situation at
> the moment — it hasn't been tested with a fresh install yet. Expect rough
> edges if you try it out.

<p align="center">
  <img src="demo.gif" alt="TunaVim demo" width="900">
</p>

## Features

- **Native plugin management** with `vim.pack` and a tracked lockfile
  (`nvim-pack-lock.json`) for reproducible installs
- **LSP out of the box** — language servers, formatters, and linters installed
  automatically via [Mason](https://github.com/mason-org/mason.nvim); adding a
  server is a one-line change
- **Completion** with [blink.cmp](https://github.com/saghen/blink.cmp) +
  [LuaSnip](https://github.com/L3MON4D3/LuaSnip), plus
  [Supermaven](https://github.com/supermaven-inc/supermaven-nvim) AI suggestions
- **Formatting** with [conform.nvim](https://github.com/stevearc/conform.nvim),
  including format-on-save where configured
- **Linting** with [nvim-lint](https://github.com/mfussenegger/nvim-lint),
  including per-project ESLint resolution that handles both flat and legacy
  configs safely
- **Fuzzy finding** with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
  and [snacks.nvim](https://github.com/folke/snacks.nvim) pickers
- **File explorer & lazygit** via snacks.nvim, with the open file highlighted
  in the tree
- **Treesitter** (`main` branch) with automatic parser installation per filetype
- **Git integration** — [gitsigns](https://github.com/lewis6991/gitsigns.nvim)
  with distinct staged/unstaged gutter signs, hunk actions, and lazygit
- **Web dev extras** — Astro syntax support and automatic Tailwind class
  sorting on save
- **Note taking** with [Vimwiki](https://github.com/vimwiki/vimwiki) on
  `<leader>m`
- **Polished UI** — OneDark Pro theme, bufferline, lualine, alpha dashboard,
  which-key popups, indent guides, and TODO-comment highlighting

## Requirements

- **Neovim 0.12+** (nightly) — required for `vim.pack`; verify with
  `nvim --version`
- **Basic utils:** `git`, `make`, `unzip`, a C compiler (`gcc`)
- **Search tools:** [ripgrep](https://github.com/BurntSushi/ripgrep#installation),
  [fd](https://github.com/sharkdp/fd#installation)
- **[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation)**
  — used to compile parsers
- **Language toolchains** for whatever you work in (e.g. Node.js + npm, Go,
  rustup) — Mason installs the servers, formatters, and linters, but they rely
  on the underlying toolchains being present
- **[lazygit](https://github.com/jesseduffield/lazygit)** — for `<leader>gg`
- **A [Nerd Font](https://www.nerdfonts.com/)** — the config assumes one is
  installed (`vim.g.have_nerd_font = true` in `init.lua`)
- **Clipboard tool** — `xclip`/`xsel`/`win32yank` depending on platform
  (built in on macOS)

## Installation

Back up any existing configuration first:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

Clone and start:

```sh
git clone https://github.com/<your_github_username>/tunavim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
nvim
```

On first start, `vim.pack` installs all plugins and Mason installs the language
servers, formatters, and linters. Restart Neovim once installation finishes,
then run `:checkhealth` to verify the setup.

> [!TIP]
> To try TunaVim alongside an existing config, use
> [`NVIM_APPNAME`](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME):
> clone into `~/.config/tunavim` and launch with
> `NVIM_APPNAME=tunavim nvim`.

## Updating

```vim
:lua vim.pack.update()                          " fetch updates (:write applies, :quit cancels)
:lua vim.pack.update(nil, { offline = true })   " inspect current plugin state
```

Plugin build steps (telescope-fzf-native, LuaSnip's jsregexp, treesitter
parsers, tailwind-sorter) run automatically after install/update.

## Key mappings

Leader is `<Space>`. Press it and wait — which-key shows everything. The
highlights:

| Keys | Action |
| :--- | :----- |
| `<leader>f` / `<leader><leader>` | Find files / open buffers |
| `<leader>sg` / `<leader>sw` | Grep project / grep word under cursor |
| `<leader>e` | File explorer |
| `<leader>gg` | Lazygit |
| `<leader>w` / `<C-s>` | Save |
| `<leader>c` | Close buffer (keep window layout) |
| `<leader>/` | Toggle comment |
| `<leader>l…` | LSP menu (format, rename, code action, diagnostics…) |
| `<leader>g…` / `<leader>h…` | Git menu / git hunk actions |
| `<leader>b…` | Buffer menu |
| `<leader>m…` | Vimwiki |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<C-\>` | Floating terminal |
| `<C-hjkl>` | Move between windows |
| `grd` / `grr` / `grn` / `gra` | LSP definition / references / rename / code action |
| `gsa` / `gsd` / `gsr` | Surround add / delete / replace |

## Structure

```
├── init.lua                    # Options, keymaps, core plugins, LSP, completion
├── nvim-pack-lock.json         # Plugin lockfile (tracked)
└── lua/
    ├── custom/plugins/         # Auto-loaded personal modules
    │   ├── keymaps.lua         #   Main keymap definitions
    │   ├── ui.lua              #   Theme, bufferline, lualine, dashboard
    │   ├── explorer.lua        #   Snacks explorer + lazygit
    │   ├── web.lua             #   Astro + Tailwind sorting
    │   ├── ai.lua              #   Supermaven
    │   ├── terminal.lua        #   Toggleterm
    │   └── wiki.lua            #   Vimwiki
    └── kickstart/plugins/      # Modules kept from kickstart
        ├── lint.lua            #   nvim-lint + ESLint resolution
        ├── gitsigns.lua        #   Git hunk keymaps
        ├── autopairs.lua
        ├── indent_line.lua
        └── debug.lua           #   DAP (disabled by default)
```

Every `.lua` file dropped into `lua/custom/plugins/` is loaded automatically.

## Troubleshooting

- `:checkhealth` — overall system and plugin health (see `:checkhealth kickstart`
  for the base requirements check)
- `:Mason` — status of language servers, formatters, and linters
- `:LspInfo` — active LSP clients for the current buffer

## Credits

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
Licensed under the [MIT License](LICENSE.md).
