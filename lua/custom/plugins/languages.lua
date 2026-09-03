-- Per-language parsers, formatters and linters. Upstream kickstart leaves
-- these as commented examples in init.lua; keeping them here means upstream
-- merges never conflict on them.
--
-- LSP servers stay in init.lua: Mason derives its install list from that
-- table, so they can't move without coupling two files.
--
-- Rule for formatters and linters: only the project's own tools run. Both
-- conform and nvim-lint resolve node_modules/.bin before any global binary,
-- and each tool is gated on its config file existing upward from the buffer.
-- No config, no run. Nothing needs a global install except stylua.
--
-- Loaded last via `require 'custom.plugins'`, so every setup() in init.lua
-- has already run.

-- ============================================================
-- Treesitter parsers
-- ============================================================
-- init.lua auto-installs a parser the first time a filetype is opened. This
-- just pre-installs the ones I use so the first open isn't delayed.
require('nvim-treesitter').install {
  'css',
  'javascript',
  'jsdoc',
  'json',
  'tsx',
  'typescript',
}

-- ============================================================
-- Formatters (conform)
-- ============================================================
local conform = require 'conform'

-- lsp_format = 'never': without a project formatter config, do nothing rather
-- than let ts_ls format with its own opinions.
local web = { 'oxfmt', 'prettier', stop_after_first = true, lsp_format = 'never' }
for ft, formatters in pairs {
  lua = { 'stylua' },
  javascript = web,
  javascriptreact = web,
  typescript = web,
  typescriptreact = web,
  json = web,
  jsonc = web,
  css = web,
  html = web,
  yaml = web,
  markdown = web,
} do
  conform.formatters_by_ft[ft] = formatters
end

-- require_cwd: skip the formatter when none of its config files is found.
conform.formatters.oxfmt = { require_cwd = true } -- .oxfmtrc.json(c), oxfmt.config.ts, vite.config.{ts,js}
conform.formatters.prettier = { require_cwd = true } -- .prettierrc*, prettier.config.*, "prettier" key in package.json
conform.formatters.stylua = { require_cwd = true } -- stylua.toml, .stylua.toml

-- Format on save, unless disabled for the buffer or globally.
-- NOTE: calling setup() again replaces the format_on_save hook from init.lua,
-- so upstream's `enabled_filetypes` allowlist there is dead. This owns it.
conform.setup {
  notify_no_formatters = false, -- most files have no project formatter; don't nag on every save
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return nil end
    return { timeout_ms = 500 }
  end,
}

vim.keymap.set('n', '<leader>w', function()
  vim.b.disable_autoformat = true
  vim.cmd.write()
  vim.b.disable_autoformat = nil
end, { desc = '[W]rite without formatting' })

vim.keymap.set('n', '<leader>tf', function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify('Autoformat ' .. (vim.b.disable_autoformat and 'disabled' or 'enabled') .. ' for this buffer')
end, { desc = '[T]oggle auto[F]ormat (buffer)' })

-- ============================================================
-- Linters (nvim-lint)
-- ============================================================
-- Not using kickstart/plugins/lint.lua: its autocmd runs every linter in
-- linters_by_ft unconditionally, and eslint errors out without a config.
vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }
local lint = require 'lint'

local js_linters = { 'oxlint', 'eslint' }
lint.linters_by_ft = {
  javascript = js_linters,
  javascriptreact = js_linters,
  typescript = js_linters,
  typescriptreact = js_linters,
  css = { 'stylelint' },
}

-- A linter runs only if one of its config files exists upward from the buffer.
local lint_root_markers = {
  oxlint = { '.oxlintrc.json' },
  eslint = {
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    'eslint.config.mts',
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.json',
    '.eslintrc.yml',
    '.eslintrc.yaml',
  },
  stylelint = {
    '.stylelintrc',
    '.stylelintrc.json',
    '.stylelintrc.js',
    '.stylelintrc.cjs',
    '.stylelintrc.mjs',
    '.stylelintrc.yml',
    '.stylelintrc.yaml',
    'stylelint.config.js',
    'stylelint.config.cjs',
    'stylelint.config.mjs',
  },
}

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('custom-lint', { clear = true }),
  callback = function(ev)
    -- Skip read-only buffers like LSP hover popups.
    if not vim.bo[ev.buf].modifiable then return end
    local names = {}
    for _, name in ipairs(lint.linters_by_ft[vim.bo[ev.buf].filetype] or {}) do
      if vim.fs.root(ev.buf, lint_root_markers[name]) then table.insert(names, name) end
    end
    if #names > 0 then lint.try_lint(names) end
  end,
})
