-- File explorer using mini.files
-- Navigation: h/l to move, q to close, = to sync changes, g? for help
-- NOTE: mini.nvim is already added in init.lua; adding it again here is a no-op
-- and keeps this file self-contained.

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

local MiniFiles = require 'mini.files'

MiniFiles.setup {
  windows = {
    preview = true,
  },
}

vim.keymap.set('n', '<leader>e', function()
  if not MiniFiles.close() then
    MiniFiles.open(vim.api.nvim_buf_get_name(0))
  end
end, { desc = 'File [E]xplorer (current file)' })

vim.keymap.set('n', '<leader>E', function()
  if not MiniFiles.close() then
    MiniFiles.open()
  end
end, { desc = 'File [E]xplorer (cwd)' })
