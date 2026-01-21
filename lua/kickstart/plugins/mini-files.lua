-- File explorer using mini.files
-- Navigation: h/l to move, q to close, = to sync changes, g? for help

return {
  {
    'echasnovski/mini.nvim',
    keys = {
      {
        '<leader>e',
        function()
          local MiniFiles = require 'mini.files'
          if not MiniFiles.close() then
            MiniFiles.open(vim.api.nvim_buf_get_name(0))
          end
        end,
        desc = 'File [E]xplorer (current file)',
      },
      {
        '<leader>E',
        function()
          local MiniFiles = require 'mini.files'
          if not MiniFiles.close() then
            MiniFiles.open()
          end
        end,
        desc = 'File [E]xplorer (cwd)',
      },
    },
    config = function()
      require('mini.files').setup {
        windows = {
          preview = true,
        },
      }
    end,
  },
}
