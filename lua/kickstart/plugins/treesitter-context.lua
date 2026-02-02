-- Shows current code context (function/class/etc) at top of buffer
-- https://github.com/nvim-treesitter/nvim-treesitter-context

return {
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      max_lines = 3,
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)

      vim.keymap.set('n', '<leader>tc', '<cmd>TSContextToggle<CR>', { desc = '[T]oggle treesitter [C]ontext' })
      vim.keymap.set('n', 'gC', function()
        require('treesitter-context').go_to_context()
      end, { desc = '[G]o to [C]ontext (upward)' })
    end,
  },
}
