-- Linting via nvim-lint.

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
}

-- golangci-lint: only in projects that actually configure it (it's a heavy
-- whole-package linter; without a config, gopls diagnostics are enough).
local golangci_configs = { '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json' }
local function golangci_enabled(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  return vim.bo[bufnr].filetype == 'go' and #vim.fs.find(golangci_configs, { upward = true, path = bufname }) > 0
end

-- shellcheck: only warnings and up
lint.linters.shellcheck.args = vim.list_extend({ '--severity', 'warning' }, lint.linters.shellcheck.args or {})

-- ESLint: Mason's eslint_d bundles a flat-config-only ESLint, so it can only be
-- used in projects with an eslint.config.* file. Legacy .eslintrc* projects are
-- linted with their own node_modules/.bin/eslint_d or eslint instead (the version
-- that understands their config). Resolved and cached per buffer.
local eslint_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}
local flat_configs = {
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}
local legacy_configs = {
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.json',
  '.eslintrc.yaml',
  '.eslintrc.yml',
}

-- Route through Neovim's trust database
-- (the same prompt-once mechanism as 'exrc'). Denied or unreviewed binaries are
-- skipped; a trusted binary re-prompts if its contents ever change.
local function trusted_executable(path) return vim.fn.executable(path) == 1 and vim.secure.read(path) ~= nil end

-- bufnr -> false (no usable eslint) or { linter = 'eslint_d'|'eslint', cmd = string|nil }
local eslint_state = {}
local function eslint_resolve(bufnr)
  local cached = eslint_state[bufnr]
  if cached ~= nil then return cached end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local state = false
  if #vim.fs.find(flat_configs, { upward = true, path = bufname }) > 0 then
    state = { linter = 'eslint_d' } -- Mason's flat-config eslint_d
  elseif #vim.fs.find(legacy_configs, { upward = true, path = bufname }) > 0 then
    for dir in vim.fs.parents(bufname) do
      local eslint_d_bin = dir .. '/node_modules/.bin/eslint_d'
      local eslint_bin = dir .. '/node_modules/.bin/eslint'
      if trusted_executable(eslint_d_bin) then
        state = { linter = 'eslint_d', cmd = eslint_d_bin }
        break
      elseif trusted_executable(eslint_bin) then
        state = { linter = 'eslint', cmd = eslint_bin }
        break
      end
    end
  end
  eslint_state[bufnr] = state
  return state
end

-- Make both eslint linters use the per-buffer resolved binary, and harden their
-- output parser: some project setups print a banner (e.g. 'Running ESLint in
-- "development" mode...' with ANSI colors) before the JSON, which breaks parsing.
for _, name in ipairs { 'eslint_d', 'eslint' } do
  local linter = lint.linters[name]

  local default_cmd = linter.cmd
  linter.cmd = function()
    local state = eslint_state[vim.api.nvim_get_current_buf()]
    return (state and state.cmd) or default_cmd
  end

  local orig_parser = linter.parser
  linter.parser = function(output, ...)
    output = output:gsub('\27%[[%d;]*m', '') -- strip ANSI color codes
    local json_start = output:find '[%[{]' -- drop any banner before the JSON
    if json_start then output = output:sub(json_start) end
    return orig_parser(output, ...)
  end
end

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Skip read-only buffers (e.g. markdown inside LSP hover popups)
    if vim.bo.modifiable then
      lint.try_lint()
      if golangci_enabled(vim.api.nvim_get_current_buf()) then lint.try_lint 'golangcilint' end
      if eslint_filetypes[vim.bo.filetype] then
        local state = eslint_resolve(vim.api.nvim_get_current_buf())
        if state then lint.try_lint(state.linter) end
      end
    end
  end,
})
