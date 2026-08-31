-- Web development: Tailwind class sorting on save.

-- tailwind-sorter has a build step; run it automatically on install/update.
-- Registered before vim.pack.add so the initial install triggers it.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'tailwind-sorter.nvim' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    local formatter_dir = ev.data.path .. '/formatter'
    vim.notify 'Building tailwind-sorter.nvim…'
    local res = vim.system({ 'npm', 'ci' }, { cwd = formatter_dir }):wait()
    if res.code == 0 then res = vim.system({ 'npm', 'run', 'build' }, { cwd = formatter_dir }):wait() end
    if res.code ~= 0 then vim.notify('tailwind-sorter build failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR) end
  end,
})

vim.pack.add { 'https://github.com/laytan/tailwind-sorter.nvim' }

-- Compat shim: tailwind-sorter uses nvim-treesitter's removed master-branch API
-- (parsers.get_parser). Restore it on top of the modern vim.treesitter API.
do
  local ok, ts_parsers = pcall(require, 'nvim-treesitter.parsers')
  if ok and ts_parsers.get_parser == nil then
    ts_parsers.get_parser = function(bufnr)
      local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr or vim.api.nvim_get_current_buf())
      return has_parser and parser or nil
    end
  end
end

require('tailwind-sorter').setup {
  on_save_enabled = true,
  on_save_pattern = { '*.html', '*.js', '*.jsx', '*.tsx', '*.twig', '*.hbs', '*.php', '*.heex', '*.astro' },
  node_path = 'node',
}

-- Compat shim #2: since Neovim 0.11, iter_matches yields a LIST of nodes per
-- capture; the plugin expects a single node. Unwrap to the last node.
do
  local tsutil = require 'tailwind-sorter.tsutil'
  local orig_get_query_matches = tsutil.get_query_matches
  tsutil.get_query_matches = function(buf)
    local matches = orig_get_query_matches(buf)
    for _, m in ipairs(matches) do
      if type(m.node) == 'table' then m.node = m.node[#m.node] end
    end
    return matches
  end
end

vim.keymap.set('n', '<leader>ts', '<cmd>TailwindSort<cr>', { desc = '[T]ailwind [S]ort' })
