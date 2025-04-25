return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("telescope").load_extension("lazygit")
    
    vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { desc = "Open LazyGit", silent = true })
    
    vim.keymap.set("n", "<leader>gl", ":Telescope lazygit<CR>", { desc = "LazyGit repositories", silent = true })
  end,
}
