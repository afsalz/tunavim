-- In-buffer markdown rendering: headings, code blocks, tables, checkboxes, callouts
-- (https://github.com/MeanderingProgrammer/render-markdown.nvim).
-- Uses the markdown/markdown_inline treesitter parsers and mini.icons from init.lua.
vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  file_types = { 'markdown' },
  -- Show raw markdown on the cursor line so editing feels normal
  anti_conceal = { enabled = true },
}

vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', { desc = '[T]oggle [M]arkdown render' })
