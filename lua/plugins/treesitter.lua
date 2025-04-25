-- Treesitter for better syntax highlighting and code navigation
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'php',
      'typescript',
      'javascript',
      'css',
      'json',
    },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = { enable = true },
  },
}
