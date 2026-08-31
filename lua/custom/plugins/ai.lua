-- Supermaven AI completion.
vim.pack.add { 'https://github.com/supermaven-inc/supermaven-nvim' }
require('supermaven-nvim').setup {
  -- NOTE: pick keys that don't alias core editing: <C-m> IS Enter and <C-h>
  -- is backspace/delete-char in insert mode.
  keymaps = {
    accept_suggestion = '<C-l>',
    clear_suggestion = '<C-]>',
    accept_word = '<C-j>',
  },
}
