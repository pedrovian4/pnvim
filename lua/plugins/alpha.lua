return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {
      '                                                              ',
      '    |\\---/|                                     |\\---/|        ',
      '    | ,_, |                                     | ,_, |        ',
      '     \\_`_/-..----.                               \\_`_/-..----.  ',
      '  ___/ `   \' ,""+ \\                            ___/ `   \' ,""+ \\ ',
      " (__...' __\\    |`._                        (__...' __\\    |`._ ",
      "    (_,...'(_,.`__)/'.+                           (_,...'(_,.`__)/'.+ ",
      '        IANCA                                      PEDRO         ',
      '                                                              ',
    }

    dashboard.section.header.opts.hl = 'Title'

    dashboard.section.buttons.val = {
      dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
      dashboard.button('f', '  Find file', ':Telescope find_files <CR>'),
      dashboard.button('r', '  Recent files', ':Telescope oldfiles <CR>'),
      dashboard.button('g', '  Find text', ':Telescope live_grep <CR>'),
      dashboard.button('c', '  Configuration', ':e ~/.config/nvim/init.lua <CR>'),
      dashboard.button('q', '  Quit Neovim', ':qa<CR>'),
    }

    dashboard.section.footer.opts.hl = 'Comment'

    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
      { type = 'padding', val = 1 },
    }

    alpha.setup(dashboard.config)
  end,
  lazy = false,
}
