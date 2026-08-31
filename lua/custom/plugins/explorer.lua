-- File explorer and lazygit via snacks.nvim.
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

-- Track the file open in the main window so the explorer can highlight it.
local current_file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

-- Explorer root for a buffer: the wiki root for vimwiki files, otherwise the
-- file's git root, otherwise its parent directory.
local function buf_root(buf)
  buf = buf or 0
  if vim.bo[buf].filetype == 'vimwiki' then
    local ok, path = pcall(vim.fn['vimwiki#vars#get_wikilocal'], 'path')
    if ok and type(path) == 'string' and path ~= '' then return vim.fs.normalize(path) end
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return vim.fs.normalize(assert(vim.uv.cwd())) end
  return vim.fs.root(name, '.git') or vim.fs.dirname(vim.fs.normalize(name))
end

-- Point an open explorer at the given root (no-op if already there).
local function retarget_explorer(picker, root)
  if vim.fs.normalize(picker:cwd()) ~= root then
    picker:set_cwd(root)
    require('snacks.explorer.actions').update(picker, { target = current_file, refresh = true })
    return true
  end
  return false
end

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
          local ret = require('snacks.picker.format').file(item, picker)
          -- Highlight the row of the currently opened file (raw extmark chunk:
          -- line_hl_group paints the whole line, text keeps its own colors)
          if not item.dir and item.file == current_file then ret[#ret + 1] = { col = 0, line_hl_group = 'SnacksExplorerOpenFile' } end
          return ret
        end,
        actions = {
          -- 'o': files open in nvim (normal confirm), folders open in the
          -- system file manager (Finder on macOS) via vim.ui.open
          open_smart = function(picker, item)
            if not item then return end
            if item.dir then
              vim.ui.open(item.file)
            else
              picker:action 'confirm'
            end
          end,
        },
        win = {
          list = {
            keys = {
              ['o'] = 'open_smart', -- file -> nvim, folder -> Finder (Enter keeps default behavior)
              ['.'] = 'toggle_hidden', -- '.' toggles dotfiles ('H' also works)
            },
          },
        },
      },
    },
  },
}

-- Subtle row background for the opened file: Special's color mixed into the
-- normal background (re-applied on colorscheme change)
local function set_open_file_hl()
  local special = vim.api.nvim_get_hl(0, { name = 'Special', link = false }).fg or 0xffffff
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg or 0x000000
  local mixed = 0
  for _, shift in ipairs { 16, 8, 0 } do
    local s = bit.rshift(special, shift) % 0x100
    local n = bit.rshift(normal, shift) % 0x100
    mixed = mixed + math.floor(s * 0.2 + n * 0.8) * bit.lshift(1, shift)
  end
  vim.api.nvim_set_hl(0, 'SnacksExplorerOpenFile', { bg = mixed })
end
set_open_file_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_open_file_hl })

-- Follow the file being edited: re-render open explorers so the highlight
-- moves, and re-root them when the file belongs to a different project
-- (e.g. entering a vimwiki page roots the tree at the wiki directory).
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= '' then return end
    local name = vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf))
    if name == '' or name == current_file then return end
    current_file = name
    local root = buf_root(ev.buf)
    for _, p in ipairs(Snacks.picker.get { source = 'explorer' }) do
      if not retarget_explorer(p, root) then p.list:update { force = true } end
    end
  end,
})

vim.keymap.set('n', '<leader>e', function()
  local explorer = Snacks.picker.get({ source = 'explorer' })[1]
  if explorer then
    explorer:close()
  else
    Snacks.explorer { cwd = buf_root(0) }
  end
end, { desc = 'Explorer (rooted at current file)' })
