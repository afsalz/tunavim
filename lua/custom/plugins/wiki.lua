-- Vimwiki on <leader>m* so <leader>w stays free for "save".

-- Must be set before the plugin loads: disable vimwiki's global <leader>w* maps.
-- In-wiki maps (Enter to follow links, etc.) remain enabled.
vim.g.vimwiki_key_mappings = { global = 0 }

vim.pack.add { 'https://github.com/vimwiki/vimwiki' }

vim.keymap.set('n', '<leader>mw', '<cmd>VimwikiIndex<cr>', { desc = 'Vimwiki index' })
vim.keymap.set('n', '<leader>mi', '<cmd>VimwikiDiaryIndex<cr>', { desc = 'Vimwiki diary index' })
vim.keymap.set('n', '<leader>ms', '<cmd>VimwikiUISelect<cr>', { desc = 'Vimwiki select wiki' })
vim.keymap.set('n', '<leader>mt', '<cmd>VimwikiTabIndex<cr>', { desc = 'Vimwiki index in tab' })
