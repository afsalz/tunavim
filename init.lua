-- ============================================================
-- Neovim config
-- Started from kickstart.nvim, tuned to my workflow.
-- Plugins are managed with the built-in `vim.pack`:
--   update:  :lua vim.pack.update()
-- ============================================================

-- ============================================================
-- OPTIONS
-- ============================================================
do
  vim.loader.enable()

  -- Leader must be set before plugins load
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  vim.g.have_nerd_font = true

  vim.o.number = true
  vim.o.relativenumber = true

  -- 2-space indentation
  vim.o.shiftwidth = 2
  vim.o.tabstop = 2
  vim.o.expandtab = true

  vim.o.mouse = 'a'
  vim.o.showmode = false -- mode is already in the statusline

  -- Sync clipboard with the OS (scheduled to keep startup fast)
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  vim.o.breakindent = true
  vim.o.undofile = true

  -- Case-insensitive search unless the query has capitals
  vim.o.ignorecase = true
  vim.o.smartcase = true

  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300

  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Show invisible characters (tabs stay blank so indent-blankline's
  -- │ guides indicate indentation instead of » chevrons, e.g. in Go)
  vim.o.list = true
  vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }

  vim.o.inccommand = 'split' -- live preview for :substitute
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.o.confirm = true -- ask instead of failing on unsaved changes
end

-- ============================================================
-- BASE KEYMAPS & AUTOCMDS
-- (my main keymaps live in lua/custom/plugins/keymaps.lua)
-- ============================================================
do
  vim.keymap.set({ 'i', 'n', 's' }, '<Esc>', function()
    vim.cmd 'nohlsearch'
    local ok, luasnip = pcall(require, 'luasnip')
    if ok and not luasnip.session.jump_active then
      local buf = vim.api.nvim_get_current_buf()
      while luasnip.session.current_nodes[buf] do
        luasnip.unlink_current()
      end
    end
    return '<Esc>'
  end, { expr = true, desc = 'Escape, clear hlsearch, stop snippet' })

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    virtual_lines = false,
    -- Auto-open the float when jumping with [d / ]d
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  -- Easier exit from the builtin terminal
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Window navigation with Ctrl + hjkl
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('config-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- PLUGIN BUILD HOOKS
-- Some plugins need a build step after install/update.
-- ============================================================
do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local output = result.stderr or ''
      if output == '' then output = result.stdout or 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- CORE UX PLUGINS
-- ============================================================
do
  -- Auto-detect indentation per file
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Git signs in the gutter (keymaps in lua/kickstart/plugins/gitsigns.lua)
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '▌' }, ---@diagnostic disable-line: missing-fields
      change = { text = '▌' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '►' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '►' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '▌' }, ---@diagnostic disable-line: missing-fields
      untracked = { text = '▌' }, ---@diagnostic disable-line: missing-fields
    },
    -- Staged hunks: thinner bar + dimmed highlight, so staged vs unstaged is
    -- visible at a glance
    signs_staged = {
      add = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      change = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '▸' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '▸' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '▎' }, ---@diagnostic disable-line: missing-fields
    },
  }

  -- Popup showing pending keybinds
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    preset = 'helix',
    delay = 200,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
      { 'gs', group = 'Surround', mode = { 'n', 'v' } },
      { '<leader>l', group = '[L]SP' },
      { '<leader>m', group = 'Vi[m]wiki' },
      { '<leader>b', group = '[B]uffers' },
      { '<leader>g', group = '[G]it' },
    },
  }

  -- Highlight TODO/FIXME/NOTE in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- mini.nvim modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- Compatibility shim for plugins that expect nvim-web-devicons
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Better around/inside textobjects (va), ci', yiiq, ...)
  require('mini.ai').setup {
    -- Avoid clashing with builtin incremental selection on Neovim >= 0.12
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (gsaiw), gsd', gsr)')
  -- On the gs prefix so the builtin `s` (substitute) keeps working
  require('mini.surround').setup {
    mappings = {
      add = 'gsa',
      delete = 'gsd',
      find = 'gsf',
      find_left = 'gsF',
      highlight = 'gsh',
      replace = 'gsr',
      update_n_lines = 'gsn',
    },
  }

  -- Delete buffers without breaking window layout (used by <leader>c)
  require('mini.bufremove').setup()
end

-- ============================================================
-- TELESCOPE (fuzzy finder)
-- ============================================================
do
  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end
  vim.pack.add(telescope_plugins)

  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Telescope-backed LSP pickers, mapped when a server attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })
end

-- ============================================================
-- LSP
-- ============================================================
do
  -- LSP progress messages in the corner
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Highlight other references of the symbol under the cursor on hold
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('config-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('config-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'config-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  ---@type table<string, vim.lsp.Config>
  local servers = {
    gopls = {},
    ts_ls = {},
    rust_analyzer = {},

    stylua = {}, -- Lua formatter (installed via Mason, used by conform)

    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- stylua handles formatting

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false },
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  require('mason').setup {}
  require('mason-lspconfig').setup {
    automatic_enable = false,
  }

  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- formatters / linters
    'prettier',
    'eslint_d',
    'shellcheck',
    'golangci-lint',
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- FORMATTING (conform.nvim; manual format on <leader>lf)
-- ============================================================
do
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local enabled_filetypes = {
        lua = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 1000 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      jsonc = { 'prettier' },
    },
    formatters = {
      prettier = {
        prepend_args = { '--print-width', '100' },
      },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>lf', function() require('conform').format { async = true } end, { desc = '[L]SP [F]ormat buffer' })
end

-- ============================================================
-- COMPLETION & SNIPPETS (blink.cmp + LuaSnip)
-- ============================================================
do
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {
    region_check_events = 'CursorMoved',
    delete_check_events = 'TextChanged',
  }

  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    -- <CR> accept, arrows or <C-n>/<C-p> select, <C-space> menu/docs, <C-e> hide
    keymap = { preset = 'enter' },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    fuzzy = { implementation = 'lua' },

    signature = { enabled = true },
  }
end

-- ============================================================
-- TREESITTER
-- ============================================================
do
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    if not vim.treesitter.language.add(language) then return end
    vim.treesitter.start(buf, language)

    -- Use treesitter indentation when an indent query exists
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- Auto-install missing parsers, then attach
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- REMAINING PLUGIN MODULES
-- ============================================================
do
  -- require 'kickstart.plugins.debug' -- DAP; enable when I need step-debugging
  require 'kickstart.plugins.lint'
  require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.gitsigns' -- gitsigns hunk keymaps (<leader>h*)

  -- My plugins and keymaps: lua/custom/plugins/*.lua
  require 'custom.plugins'
end

-- vim: ts=2 sts=2 sw=2 et
