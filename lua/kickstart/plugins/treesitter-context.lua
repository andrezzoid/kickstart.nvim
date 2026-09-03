-- Shows current code context (function/class/etc) at top of buffer
-- https://github.com/nvim-treesitter/nvim-treesitter-context
-- NOTE: depends on nvim-treesitter, which is added in init.lua.

vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter-context' }

require('treesitter-context').setup {
  max_lines = 3,
}

vim.keymap.set('n', '<leader>tc', '<cmd>TSContextToggle<CR>', { desc = '[T]oggle treesitter [C]ontext' })
vim.keymap.set('n', 'gC', function()
  require('treesitter-context').go_to_context()
end, { desc = '[G]o to [C]ontext (upward)' })
