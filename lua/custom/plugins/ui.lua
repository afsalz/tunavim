-- UI: colorscheme, buffer tabs, statusline, dashboard, cursor beacon.

-- [[ Colorscheme ]]
vim.pack.add { 'https://github.com/olimorris/onedarkpro.nvim' }
require('onedarkpro').setup {}
vim.cmd.colorscheme 'onedark_dark'

-- [[ Bufferline: buffer tabs along the top ]]
vim.pack.add { 'https://github.com/akinsho/bufferline.nvim' }
require('bufferline').setup {
  options = { ---@diagnostic disable-line: missing-fields
    -- Shift the buffer tabs right of the snacks explorer sidebar (as in LazyVim)
    offsets = {
      { filetype = 'snacks_layout_box' },
    },
  },
}

vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev buffer' })

-- [[ Lualine: statusline ]]
vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }
require('lualine').setup {
  options = {
    theme = 'auto',
    globalstatus = true,
  },
}

-- [[ Alpha: startup dashboard ]]
vim.pack.add { 'https://github.com/goolord/alpha-nvim' }
local dashboard = require 'alpha.themes.dashboard'

dashboard.section.header.val = {
  [[████████╗ ██╗   ██╗ ███╗   ██╗  █████╗  ██╗   ██╗ ██╗ ███╗   ███╗]],
  [[╚══██╔══╝ ██║   ██║ ████╗  ██║ ██╔══██╗ ██║   ██║ ██║ ████╗ ████║]],
  [[   ██║    ██║   ██║ ██╔██╗ ██║ ███████║ ██║   ██║ ██║ ██╔████╔██║]],
  [[   ██║    ██║   ██║ ██║╚██╗██║ ██╔══██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║]],
  [[   ██║    ╚██████╔╝ ██║ ╚████║ ██║  ██║  ╚████╔╝  ██║ ██║ ╚═╝ ██║]],
  [[   ╚═╝     ╚═════╝  ╚═╝  ╚═══╝ ╚═╝  ╚═╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
}

dashboard.section.buttons.val = {
  dashboard.button('f', '󰈞  Find file', '<cmd>Telescope find_files<cr>'),
  dashboard.button('n', '󰈔  New file', '<cmd>ene <bar> startinsert<cr>'),
  dashboard.button('r', '󰄉  Recent files', '<cmd>Telescope oldfiles<cr>'),
  dashboard.button('g', '󰊄  Find text', '<cmd>Telescope live_grep<cr>'),
  dashboard.button('c', '󰒓  Config', '<cmd>e $MYVIMRC<cr>'),
  dashboard.button('q', '󰅚  Quit', '<cmd>qa<cr>'),
}

-- The TunaVim motto
dashboard.section.footer.val = 'Tap into perpetual motion'

-- Center the dashboard vertically: size the top padding from the window height
local function dashboard_top_padding()
  local header_height = #dashboard.section.header.val
  local buttons_height = #dashboard.section.buttons.val * 2 - 1
  local content_height = header_height + 2 + buttons_height + 1 -- + mid padding + footer
  return math.max(2, math.floor((vim.o.lines - content_height) / 2) - 1)
end
dashboard.config.layout[1].val = dashboard_top_padding()

require('alpha').setup(dashboard.config)

-- [[ Beacon: flash the cursor line after big jumps ]]
-- vim.pack.add { 'https://github.com/danilamihailov/beacon.nvim' }
