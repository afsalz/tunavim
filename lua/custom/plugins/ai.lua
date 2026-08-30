-- Supermaven AI completion.
vim.pack.add { 'https://github.com/supermaven-inc/supermaven-nvim' }
require('supermaven-nvim').setup {
  keymaps = {
    accept_suggestion = '<C-l>',
    clear_suggestion = '<C-m>',
    accept_word = '<C-h>',
  },
}
