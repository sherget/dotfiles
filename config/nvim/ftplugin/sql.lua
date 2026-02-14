require('cmp').setup.filetype({ 'sql' }, {
  sources = {
    { name = 'vim-dadbod-completion' },
    { name = 'buffer' },
  },
})

vim.keymap.set('n', '♠', vim.fn['<Plug>(DBUI_ExecuteQuery)'])
vim.keymap.set('v', '♠', vim.fn['<Plug>(DBUI_ExecuteQuery)'])
