-- File explorer and lazygit via snacks.nvim.
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

-- Track the file open in the main window so the explorer can highlight it.
local current_file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

require('snacks').setup {
  explorer = { enabled = true },
  lazygit = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true, -- show dotfiles by default
        ignored = true, -- show gitignored files by default
        format = function(item, picker)
          -- Highlight the currently opened file in the tree
          item.filename_hl = (not item.dir and item.file == current_file) and 'SnacksExplorerOpenFile' or nil
          return require('snacks.picker.format').file(item, picker)
        end,
        win = {
          list = {
            keys = {
              ['o'] = 'confirm', -- 'o' opens the file (Enter works too)
              ['.'] = 'toggle_hidden', -- '.' toggles dotfiles ('H' also works)
            },
          },
        },
      },
    },
  },
}

-- Bold/colored highlight for the opened file (re-applied on colorscheme change)
local function set_open_file_hl()
  local special = vim.api.nvim_get_hl(0, { name = 'Special', link = false })
  vim.api.nvim_set_hl(0, 'SnacksExplorerOpenFile', { fg = special.fg, bold = true })
end
set_open_file_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_open_file_hl })

-- Re-render open explorers when switching buffers, so the highlight follows.
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= '' then return end
    local name = vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf))
    if name == '' or name == current_file then return end
    current_file = name
    for _, p in ipairs(Snacks.picker.get { source = 'explorer' }) do
      p.list:update { force = true }
    end
  end,
})

vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = 'Explorer' })
