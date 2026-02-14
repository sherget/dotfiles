return {
  {
    'tpope/vim-fugitive',
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>gg', '<CMD>Git<CR>')
      vim.keymap.set('n', '<leader>gc', '<CMD>Git commit --no-verify<CR>')
      vim.keymap.set('n', '<leader>gp', '<CMD>Git push<CR>')
      vim.keymap.set('n', '<leader>gdd', '<CMD>Git diff @ -- %<CR>')
      vim.keymap.set('n', '<leader>gds', '<CMD>Gvdiffsplit<CR>')
      vim.keymap.set('n', '<leader>gdt', '<CMD>Git difftool<CR>')
      vim.keymap.set('n', '<leader>gr', '<CMD>GDelete<CR>')
    end,
  },
}
