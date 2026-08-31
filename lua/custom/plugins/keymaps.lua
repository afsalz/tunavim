-- My keymaps. Loads after init.lua, so anything here wins over the defaults.

local map = vim.keymap.set

-- Save
map({ 'n', 'i' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
map('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save' })

-- Quit
map('n', '<leader>q', '<cmd>confirm q<cr>', { desc = 'Quit' })

-- Close buffer without destroying the window layout
map('n', '<leader>c', function() require('mini.bufremove').delete(0, false) end, { desc = 'Close buffer' })

-- File explorer: <leader>e is mapped in explorer.lua

-- Find files (formatting is on <leader>lf)
map('n', '<leader>f', function() require('telescope.builtin').find_files() end, { desc = 'Find file' })

-- Comment toggle via the builtin gcc/gc mappings
map('n', '<leader>/', 'gcc', { remap = true, desc = 'Comment line' })
map('v', '<leader>/', 'gc', { remap = true, desc = 'Comment selection' })

-- Search text across the whole project (snacks picker: highlights matches in the preview)
map('n', '<leader>st', function() Snacks.picker.grep() end, { desc = 'Search [T]ext' })
map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = '[S]earch by [G]rep' })
map({ 'n', 'v' }, '<leader>sw', function() Snacks.picker.grep_word() end, { desc = '[S]earch current [W]ord' })

-- Fuzzy search within the current buffer
map(
  'n',
  '<leader>sb',
  function() require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false }) end,
  { desc = '[S]earch current [B]uffer' }
)

-- LSP menu under <leader>l (<leader>lf format is set in init.lua)
map('n', '<leader>ld', vim.diagnostic.setloclist, { desc = 'Buffer [D]iagnostics' })
map('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'Code [A]ction' })
map('n', '<leader>lr', vim.lsp.buf.rename, { desc = '[R]ename' })
map('n', '<leader>lj', function() vim.diagnostic.jump { count = 1, float = true } end, { desc = 'Next diagnostic' })
map('n', '<leader>lk', function() vim.diagnostic.jump { count = -1, float = true } end, { desc = 'Prev diagnostic' })
map('n', '<leader>li', '<cmd>LspInfo<cr>', { desc = 'LSP [I]nfo' })
map('n', '<leader>lI', '<cmd>Mason<cr>', { desc = 'Mason [I]nstaller' })
map('n', '<leader>ll', vim.lsp.codelens.run, { desc = 'Code[L]ens action' })
map('n', '<leader>lq', vim.diagnostic.setqflist, { desc = 'Diagnostics to [q]uickfix' })
map('n', '<leader>ls', function() Snacks.picker.lsp_symbols() end, { desc = 'Document [s]ymbols' })
map('n', '<leader>lS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Workspace [S]ymbols' })
map('n', '<leader>lw', function() require('telescope.builtin').diagnostics() end, { desc = '[W]orkspace diagnostics' })

-- Dashboard
map('n', '<leader>;', '<cmd>Alpha<cr>', { desc = 'Dashboard' })

-- tmux new window
map('n', '<leader>z', '<cmd>silent !tmux neww<cr>', { desc = 'tmux new window' })

-- Resize windows with Ctrl + arrow keys
map('n', '<C-Up>', '<cmd>resize -2<cr>', { desc = 'Shrink window height' })
map('n', '<C-Down>', '<cmd>resize +2<cr>', { desc = 'Grow window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Shrink window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Grow window width' })

-- Move current line / selection up and down with Alt-j / Alt-k
map('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move line up' })
map('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

-- Stay in visual mode while indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })

-- Undo break-points: start a new undo block at punctuation, so u undoes in
-- sentence-sized chunks instead of the whole insert session (from LazyVim)
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- Buffer menu (<leader>b)
map('n', '<leader>bj', '<cmd>BufferLinePick<cr>', { desc = '[J]ump to buffer' })
map('n', '<leader>bf', function() require('telescope.builtin').buffers() end, { desc = '[F]ind buffer' })
map('n', '<leader>bb', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bn', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bh', '<cmd>BufferLineCloseLeft<cr>', { desc = 'Close buffers to the left' })
map('n', '<leader>bl', '<cmd>BufferLineCloseRight<cr>', { desc = 'Close buffers to the right' })
map('n', '<leader>bW', '<cmd>noautocmd w<cr>', { desc = 'Save without formatting' })

-- Telescope's git pickers error hard outside a repo; guard with a notification
local function git_guard(fn)
  return function()
    if vim.fs.root(0, '.git') or vim.fs.root(assert(vim.uv.cwd()), '.git') then
      fn()
    else
      vim.notify('Not a git repository', vim.log.levels.WARN)
    end
  end
end

-- Git menu (<leader>g); gitsigns also provides these as <leader>h "hunk" maps
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazy[g]it' })
map('n', '<leader>gj', function() require('gitsigns').nav_hunk 'next' end, { desc = 'Next hunk' })
map('n', '<leader>gk', function() require('gitsigns').nav_hunk 'prev' end, { desc = 'Prev hunk' })
map('n', '<leader>gl', function() require('gitsigns').blame_line() end, { desc = 'Blame line' })
map('n', '<leader>gp', function() require('gitsigns').preview_hunk() end, { desc = 'Preview hunk' })
map('n', '<leader>gs', function() require('gitsigns').stage_hunk() end, { desc = 'Stage hunk' })
map('n', '<leader>gr', function() require('gitsigns').reset_hunk() end, { desc = 'Reset hunk' })
map('n', '<leader>gR', function() require('gitsigns').reset_buffer() end, { desc = 'Reset buffer' })
map('n', '<leader>gd', function() require('gitsigns').diffthis() end, { desc = 'Diff against index' })
map('n', '<leader>go', git_guard(function() require('telescope.builtin').git_status() end), { desc = '[O]pen changed files' })
map('n', '<leader>gb', git_guard(function() require('telescope.builtin').git_branches() end), { desc = 'Checkout [b]ranch' })
map('n', '<leader>gc', git_guard(function() require('telescope.builtin').git_commits() end), { desc = 'Checkout [c]ommit' })
