return {
  'f-person/git-blame.nvim',
  event = 'BufRead',
  config = function()
    require('gitblame').setup {
      enabled = true,
      date_format = '%Y-%m-%d',
      message_template = '  <author> • <date> • <summary>',
      message_when_not_committed = '  Not committed yet',
      highlight_group = 'Comment',
      display_virtual_text = true,
      delay = 1000,
    }

    vim.keymap.set('n', '<leader>gb', ':GitBlameToggle<CR>', { desc = 'Toggle Git Blame', silent = true })

    vim.keymap.set('n', '<leader>gc', ':GitBlameCopyCommitURL<CR>', { desc = 'Copy Git Commit URL', silent = true })

    vim.keymap.set('n', '<leader>go', ':GitBlameOpenCommitURL<CR>', { desc = 'Open Commit URL', silent = true })
  end,
}
