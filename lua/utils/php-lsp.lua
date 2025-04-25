-- PHP LSP utilities
-- A collection of functions for PHP LSP integration and code actions

local M = {}

-- Helper function to run code actions with specific context
function M.run_code_action(context_only)
  vim.lsp.buf.code_action {
    context = {
      only = context_only,
    },
  }
end

-- Implement interface methods
function M.implement_interface()
  M.run_code_action { 'source.implementMissingMethods' }
end

-- Extract selected code to a method
function M.extract_method()
  -- Check if we're in visual mode first
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' then
    M.run_code_action { 'refactor.extract.method' }
  else
    vim.notify('Select code to extract first (visual mode)', vim.log.levels.INFO)
  end
end

-- Fix/organize class imports
function M.organize_imports()
  M.run_code_action { 'source.organizeImports' }
end

-- Generate constructor
function M.generate_constructor()
  M.run_code_action { 'source.generateConstructor' }
end

-- Generate getters and setters
function M.generate_accessors()
  M.run_code_action { 'source.generateAccessors' }
end

-- Rename method or property safely with language server
function M.rename()
  vim.lsp.buf.rename()
end

-- Find implementations of an interface or method
function M.find_implementations()
  vim.lsp.buf.implementation()
end

-- Fix all fixable issues in the file
function M.fix_all()
  M.run_code_action { 'source.fixAll' }
end

-- Show method signatures under cursor
function M.signature_help()
  vim.lsp.buf.signature_help()
end

-- Toggle inline documentation
function M.toggle_inline_documentation()
  -- This is a placeholder - you'll need to implement with a plugin that supports inline docs
  vim.notify('Toggle inline documentation not implemented', vim.log.levels.INFO)
end

-- Setup PHP-specific keymaps when LSP attaches to a PHP buffer
function M.setup_keymaps(bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'PHP: ' .. desc })
  end

  -- Visual mode mappings
  local vmap = function(keys, func, desc)
    vim.keymap.set('v', keys, func, { buffer = bufnr, desc = 'PHP: ' .. desc })
  end

  -- Main PHP code actions
  map('<leader>pi', M.implement_interface, 'Implement Interface Methods')
  map('<leader>pc', M.generate_constructor, 'Generate Constructor')
  map('<leader>pg', M.generate_accessors, 'Generate Getters/Setters')
  map('<leader>pu', M.organize_imports, 'Fix/Organize Class Imports')
  map('<leader>pf', M.fix_all, 'Fix All Issues')

  -- Refactoring actions (some work in visual mode)
  map('<leader>pm', M.extract_method, 'Extract Method (select code first)')
  vmap('<leader>pm', M.extract_method, 'Extract Selected Code to Method')

  -- Navigation and info
  map('<leader>pd', vim.lsp.buf.definition, 'Go to Definition')
  map('<leader>pr', vim.lsp.buf.references, 'Find References')
  map('<leader>pt', vim.lsp.buf.type_definition, 'Go to Type Definition')
  map('<leader>ph', M.signature_help, 'Show Signature Help')

  -- Documentation
  map('<leader>pk', vim.lsp.buf.hover, 'Show Documentation')
  map('<leader>pK', function()
    require('neogen').generate { type = 'func' }
  end, 'Generate PHPDoc for Function/Method')

  -- File-wide actions
  map('<leader>po', function()
    vim.lsp.buf.document_symbol()
  end, 'Outline Document Structure')
end

-- Setup PHP-specific autcommands for enhanced features
function M.setup_autocmds(bufnr)
  local augroup = vim.api.nvim_create_augroup('php_lsp_utils_' .. bufnr, { clear = true })

  -- Auto-organize imports on save (optional - uncomment if desired)
  -- vim.api.nvim_create_autocmd('BufWritePre', {
  --   buffer = bufnr,
  --   group = augroup,
  --   callback = function()
  --     M.organize_imports()
  --   end,
  -- })

  -- Show method parameters when inside a function call
  vim.api.nvim_create_autocmd('CursorHoldI', {
    buffer = bufnr,
    group = augroup,
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]

      -- Basic check if we're inside a function call
      local before_cursor = line:sub(1, col)
      if before_cursor:match '%(.*$' then
        M.signature_help()
      end
    end,
  })
end

-- Initialize PHP LSP utilities for a buffer
function M.init(client, bufnr)
  -- Only run for PHP files
  if vim.bo[bufnr].filetype ~= 'php' then
    return
  end

  -- Setup keymaps
  M.setup_keymaps(bufnr)

  -- Setup autocmds
  M.setup_autocmds(bufnr)

  -- Notify that PHP utils are ready
  vim.notify('PHP LSP utilities loaded for buffer ' .. bufnr, vim.log.levels.INFO, { title = 'PHP Utils' })
end

return M
