return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    'goolord/alpha-nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>e', ':Neotree toggle<CR>', desc = 'Toggle Explorer', silent = true },
  },
  opts = {
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      hijack_netrw_behavior = 'open_default',
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ['<leader>e'] = 'close_window',
          ['<leader><leader>'] = 'global_command',
        },
      },
    },
    window = {
      width = 30,
      position = 'right',
      mapping_options = {
        noremap = true,
        nowait = true,
      },
    },
  },
  config = function(_, opts)
    -- Setup Neo-tree
    require('neo-tree').setup(opts)

    -- Function to detect project directories
    local function is_project_dir()
      local project_markers = {
        '.git', -- Git
        'package.json', -- Node.js
        'Cargo.toml', -- Rust
        'composer.json', -- PHP
        'go.mod', -- Go
        'requirements.txt', -- Python
        'Makefile', -- C
      }

      for _, marker in ipairs(project_markers) do
        local found
        if marker:sub(-1) == '/' then
          found = vim.fn.finddir(marker, vim.fn.getcwd() .. ';')
        else
          found = vim.fn.findfile(marker, vim.fn.getcwd() .. ';')
        end
        if found ~= '' then
          return true
        end
      end
      return false
    end

    -- Function to open Neo-tree and focus the main window
    local function open_neotree_and_focus_main()
      vim.cmd 'Neotree toggle'
      -- Give Neo-tree a moment to open, then switch to the main window
      vim.defer_fn(function()
        -- Move to the main window (assumes Neo-tree is the first window)
        -- This handles both left and right side Neo-tree positions
        if opts.window.position == 'left' then
          vim.cmd 'wincmd l' -- Move right if Neo-tree is on the left
        else
          vim.cmd 'wincmd h' -- Move left if Neo-tree is on the right
        end
      end, 10)
    end

    -- Create a toggle command for switching between Alpha and Neo-tree
    vim.api.nvim_create_user_command('ToggleStartScreen', function()
      if vim.bo.filetype == 'neo-tree' then
        vim.cmd 'Neotree close'
        vim.cmd 'Alpha'
      elseif vim.bo.filetype == 'alpha' then
        vim.cmd 'Alpha'
        open_neotree_and_focus_main()
      else
        open_neotree_and_focus_main()
      end
    end, {})

    -- Add keymap to toggle start screen
    vim.keymap.set('n', '<leader>;', ':ToggleStartScreen<CR>', { silent = true, desc = 'Toggle Start Screen' })

    -- Override the default Neo-tree toggle command
    vim.keymap.set('n', '<leader>e', function()
      if vim.bo.filetype == 'neo-tree' then
        vim.cmd 'Neotree close'
      else
        open_neotree_and_focus_main()
      end
    end, { silent = true, desc = 'Toggle Explorer' })

    -- VimEnter event to determine what to show on startup
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- Skip if opening a specific file
        if vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv()[0]) ~= 1 then
          return
        end

        -- Check if we're in a project
        if is_project_dir() then
          -- We're in a project, open Neo-tree and focus main window
          open_neotree_and_focus_main()
        else
          -- We're not in a project, open Alpha
          vim.schedule(function()
            if package.loaded['alpha'] then
              vim.cmd 'Alpha'
            else
              require('alpha').setup(require('alpha.themes.dashboard').config)
              vim.cmd 'Alpha'
            end
          end)
        end
      end,
      nested = true,
    })
  end,
  lazy = false,
}
