local ok, secrets = pcall(require, 'secrets')
local license_key = ok and secrets.intelephense_license or nil

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
    {
      'danymat/neogen',
      dependencies = 'nvim-treesitter/nvim-treesitter',
      config = true,
    },
    { 'kevinhwang91/nvim-ufo', dependencies = 'kevinhwang91/promise-async' },
  },
  config = function()
    -- Initialize UFO if available (but don't error if not)
    local ufo_available = false
    local folding_capabilities = {}

    do
      local has_ufo, ufo = pcall(require, 'ufo')
      if has_ufo and ufo and type(ufo.setup) == 'function' then
        ufo.setup()
        ufo_available = true
        folding_capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        }
      end
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Documentation generation
        map('<leader>doc', function()
          require('neogen').generate()
        end, 'Generate Documentation')

        -- Standard LSP features
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- Documentation
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>k', vim.lsp.buf.signature_help, 'Signature Help')

        -- Interface Implementation
        map('<leader>cii', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Implement' or action.title:match 'interface'
            end,
            apply = false,
          }
        end, 'Implement Interface')

        map('<leader>cim', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Implement' or action.title:match 'methods' or action.title:match 'interface' or action.title:match 'abstract'
            end,
            apply = false,
          }
        end, 'Implement Missing Methods')

        -- Extract Method/Variable
        map('<leader>cem', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Extract method'
            end,
            apply = false,
          }
        end, 'Extract Method')

        map('<leader>cev', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Extract variable'
            end,
            apply = false,
          }
        end, 'Extract Variable')

        -- Generate Getters/Setters
        map('<leader>cgs', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Generate accessor' or action.title:match 'getter' or action.title:match 'setter'
            end,
            apply = false,
          }
        end, 'Generate Getters/Setters')

        -- Generate Constructor
        map('<leader>cgc', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Generate constructor'
            end,
            apply = false,
          }
        end, 'Generate Constructor')

        -- Add Function Parameter
        map('<leader>cap', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Add parameter'
            end,
            apply = false,
          }
        end, 'Add Function Parameter')

        -- Fix Namespace
        map('<leader>cfn', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'namespace' and action.title:match 'Fix '
            end,
            apply = false,
          }
        end, 'Fix Namespace')

        -- Import Class (Add Use Statement)
        map('<leader>ciu', function()
          vim.lsp.buf.code_action {
            filter = function(action)
              return action.title:match 'Import'
            end,
            apply = false,
          }
        end, 'Import Class/Add Use Statement')

        -- Format document
        map('<leader>cf', function()
          vim.lsp.buf.format { async = true }
        end, 'Format Document')

        -- Organize imports
        map('<leader>ci', function()
          vim.lsp.buf.execute_command {
            command = 'intelephense.organizeImports',
            arguments = { vim.uri_from_bufnr(0) },
          }
        end, 'Organize Imports')

        -- Index workspace
        map('<leader>cI', function()
          vim.lsp.buf.execute_command {
            command = 'intelephense.index.workspace',
          }
        end, 'Index Workspace')

        local client_supports_method = function(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end

        if ufo_available and client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentSymbol, event.buf) then
          local has_ufo, ufo = pcall(require, 'ufo')
          if has_ufo and ufo and type(ufo.setupFoldProvider) == 'function' then
            vim.schedule(function()
              pcall(ufo.setupFoldProvider, event.buf)
            end)
          end
        end
      end,
    })

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Add UFO folding capabilities (provides better folding with LSP) if available
    if ufo_available then
      capabilities = vim.tbl_deep_extend('force', capabilities, folding_capabilities)
    end

    require('neogen').setup {
      enabled = true,
      languages = {
        php = {
          template = {
            annotation_convention = 'phpdoc',
          },
        },
        javascript = {
          template = {
            annotation_convention = 'jsdoc',
          },
        },
        typescript = {
          template = {
            annotation_convention = 'tsdoc',
          },
        },
      },
    }

    -- Define base servers (excluding TypeScript for now)
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
          },
        },
      },
      intelephense = {
        init_options = {
          licenceKey = license_key,
        },
        settings = {
          intelephense = {
            stubs = {
              'apache',
              'bcmath',
              'bz2',
              'calendar',
              'com_dotnet',
              'Core',
              'ctype',
              'curl',
              'date',
              'dba',
              'dom',
              'enchant',
              'exif',
              'FFI',
              'fileinfo',
              'filter',
              'fpm',
              'ftp',
              'gd',
              'gettext',
              'gmp',
              'hash',
              'iconv',
              'imap',
              'intl',
              'json',
              'ldap',
              'libxml',
              'mbstring',
              'meta',
              'mysqli',
              'oci8',
              'odbc',
              'openssl',
              'pcntl',
              'pcre',
              'PDO',
              'pdo_ibm',
              'pdo_mysql',
              'pdo_pgsql',
              'pdo_sqlite',
              'pgsql',
              'Phar',
              'posix',
              'pspell',
              'readline',
              'Reflection',
              'session',
              'shmop',
              'SimpleXML',
              'snmp',
              'soap',
              'sockets',
              'sodium',
              'SPL',
              'sqlite3',
              'standard',
              'superglobals',
              'sysvmsg',
              'sysvsem',
              'sysvshm',
              'tidy',
              'tokenizer',
              'xml',
              'xmlreader',
              'xmlrpc',
              'xmlwriter',
              'xsl',
              'Zend OPcache',
              'zip',
              'zlib',
              'wordpress',
              'phpunit',
              'woocommerce',
              'symfony',
              'wordpress-globals',
              'laravel',
            },
            files = {
              maxSize = 5000000,
              associations = { '*.php', '*.phtml', '*.inc', '*.module' },
              exclude = {
                '**/.git/**',
                '**/.svn/**',
                '**/.hg/**',
                '**/CVS/**',
                '**/.DS_Store/**',
                '**/node_modules/**',
                '**/bower_components/**',
                '**/vendor/**/{Tests,tests}/**',
                '**/.history/**',
                '**/vendor/**/vendor/**',
                '**/dist/**',
              },
            },
            phpdoc = {
              returnVoid = false,
              useFullyQualifiedNames = false,
            },
            environment = {
              shortOpenTag = true,
              phpVersion = '8.2', -- Set to your PHP version
            },
            completion = {
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
              triggerParameterHints = true,
              maxItems = 100,
            },
            format = {
              enable = true,
            },
            diagnostics = {
              enable = true,
              run = 'onType', -- onType or onSave
            },
            codeLens = true, -- Premium feature with license
            telemetry = {
              enable = false,
            },
            -- Enhanced settings for better code actions
            references = {
              exclude = {},
            },
            rename = {
              exclude = {},
            },
            signatures = {
              enable = true,
            },
          },
        },
        commands = {
          IntelephenseRenameSymbol = {
            function()
              vim.lsp.buf.execute_command {
                command = 'intelephense.renameSymbol',
                arguments = { vim.uri_from_bufnr(0) },
              }
            end,
            description = 'Rename Symbol (Intelephense)',
          },
          IntelephenseIndexWorkspace = {
            function()
              vim.lsp.buf.execute_command {
                command = 'intelephense.index.workspace',
              }
            end,
            description = 'Index Workspace (Intelephense)',
          },
          IntelephenseImplementInterface = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Implement' or action.title:match 'interface'
                end,
                apply = false,
              }
            end,
            description = 'Implement Interface (Intelephense)',
          },
          IntelephenseImplementMethods = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Implement' or action.title:match 'methods' or action.title:match 'interface' or action.title:match 'abstract'
                end,
                apply = false,
              }
            end,
            description = 'Implement Missing Methods (Intelephense)',
          },
          IntelephenseExtractMethod = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Extract method'
                end,
                apply = false,
              }
            end,
            description = 'Extract Method (Intelephense)',
          },
          IntelephenseExtractVariable = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Extract variable'
                end,
                apply = false,
              }
            end,
            description = 'Extract Variable (Intelephense)',
          },
          IntelephenseGenerateGettersSetters = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Generate accessor' or action.title:match 'getter' or action.title:match 'setter'
                end,
                apply = false,
              }
            end,
            description = 'Generate Getters/Setters (Intelephense)',
          },
          IntelephenseGenerateConstructor = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Generate constructor'
                end,
                apply = false,
              }
            end,
            description = 'Generate Constructor (Intelephense)',
          },
          IntelephenseAddFunctionParameter = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Add parameter'
                end,
                apply = false,
              }
            end,
            description = 'Add Function Parameter (Intelephense)',
          },
          IntelephenseFixNamespace = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'namespace' and action.title:match 'Fix '
                end,
                apply = false,
              }
            end,
            description = 'Fix Namespace (Intelephense)',
          },
          IntelephenseUseStatement = {
            function()
              vim.lsp.buf.code_action {
                filter = function(action)
                  return action.title:match 'Import'
                end,
                apply = false,
              }
            end,
            description = 'Import Class/Add Use Statement (Intelephense)',
          },
        },
      },
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
      'prettier',
      'phpcbf',
      'php-cs-fixer',
      'typescript-language-server',
    })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        function(server_name)
          if server_name == 'tsserver' then
            return
          end

          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
      callback = function()
        if not vim.lsp.get_active_clients({ name = 'tsserver' })[1] then
          require('lspconfig').tsserver.setup {
            capabilities = capabilities,
            init_options = {
              preferences = {
                includeCompletionsWithSnippetText = true,
                includeCompletionsForImportStatements = true,
              },
            },
          }
        end
      end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'php',
      callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
      end,
    })
  end,
}
