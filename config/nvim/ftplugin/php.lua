vim.bo.tabstop = 4 -- size of a hard tabstop (ts).
vim.bo.shiftwidth = 4 -- size of an indentation (sw).
vim.bo.expandtab = true -- always uses spaces instead of tab characters (et).
vim.bo.softtabstop = 4 -- number of spac

local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

local on_attach = function(_, bufnr)
  return vim.lsp.get_clients { bufnr = bufnr }
end

vim.keymap.set('n', '<leader>pec', vim.cmd.PhpactorExtractConstant)
vim.keymap.set('v', '<leader>pec', vim.cmd.PhpactorExtractConstant)
vim.keymap.set('n', '<leader>pee', vim.cmd.PhpactorExtractExpression)
vim.keymap.set('v', '<leader>pee', vim.cmd.PhpactorExtractExpression)
vim.keymap.set('v', '<leader>pem', vim.cmd.PhpactorExtractMethod)
vim.keymap.set('n', '<leader>pem', vim.cmd.PhpactorExtractMethod)
vim.keymap.set('n', '<leader>pmm', vim.cmd.PhpactorContextMenu)
vim.keymap.set('n', '<leader>pmf', vim.cmd.PhpactorMoveFile)
vim.keymap.set('n', '<leader>pce', vim.cmd.PhpactorClassExpand)
vim.keymap.set('n', '<leader>pcn', vim.cmd.PhpactorClassNew)

-- arrow shortcut
vim.keymap.set('i', '♠', '->')

-------------
-- Spryker --
-------------
local function file_exists(name)
  local f = io.open(name, 'r')
  return f ~= nil and io.close(f)
end

local extendSprykerCore = function()
  -- example input (current_file_path): vendor/spryker/discount/src/Spryker/Zed/Discount/Communication/Form/DiscountForm.php
  local current_file_path = vim.fn.expand '%:p:.'
  local src_delimiter = 'src/'
  local spryker_delimiter = 'Spryker/'
  local target_path = 'src/Pyz/'
    .. current_file_path:sub(current_file_path:find(src_delimiter, 1, true) + string.len(src_delimiter) + string.len(spryker_delimiter), -1)
  -- example output (target_path): src/Pyz/Zed/Discount/Communication/Form/DiscountForm.php
  if file_exists(target_path) then
    vim.ui.input({ prompt = 'File already exists, do you want to jump there? (y/n): ' }, function(input)
      if input == 'y' then
        vim.cmd { cmd = 'edit', args = { target_path } }
      end
    end)
  else
    -- copy relevant class stuff
    vim.cmd { cmd = 'normal', args = { 'gg' } }
    vim.cmd { cmd = 'call', args = { 'search("namespaces")' } }
    vim.cmd { cmd = 'normal', args = { 'V' } }
    vim.cmd { cmd = 'call', args = { 'search("class")' } }
    vim.cmd { cmd = 'normal', args = { 'j' } }
    vim.cmd { cmd = 'normal', args = { 'y' } }
    -- create file
    vim.cmd { cmd = 'edit', args = { target_path } }
    vim.cmd { cmd = 'normal', args = { 'P' } }
    vim.api.nvim_command '%s/namespace Spryker/namespace Pyz'
    local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
    local cr = vim.api.nvim_replace_termcodes('<CR>', true, false, true)
    vim.cmd { cmd = 'call', args = { 'search("extends")' } }
    vim.cmd { cmd = 'normal', args = { 'G' } }
    vim.api.nvim_feedkeys('a}' .. esc, 'm', true)
    -- now manipulate namespaces, class extension
  end
end

vim.keymap.set('n', '<leader>esc', extendSprykerCore)
