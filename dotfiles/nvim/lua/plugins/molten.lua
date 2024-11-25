return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true

      vim.keymap.set(
        "n",
        "<leader>mo",
        ":noautocmd MoltenEnterOutput<CR>",
        { desc = "open output window", silent = true }
      )
      vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Run visual", silent = true })
      vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
      vim.keymap.set("n", "<leader>mb", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })
      vim.keymap.set("n", "<leader>mh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
      vim.keymap.set("n", "<leader>mi", ":MoltenInterrupt<CR>", { desc = "Run code cell", silent = true })
    end,
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width = 120,
      max_height = 18,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown", "norg" },
    config = function()
      local quarto = require("quarto")
      quarto.setup({
        lspFeatures = {
          languages = { "python", "rust", "lua", "c" },
          chunks = "all",
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          ft_runners = {},
          default_method = "molten",
          never_run = {},
        },
      })
      local runner = require("quarto.runner")
      vim.keymap.set("n", "<leader>mr", runner.run_cell, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<leader>ma", runner.run_above, { desc = "run cells above", silent = true })
      vim.keymap.set("n", "<leader>mA", runner.run_all, { desc = "run all cells", silent = true })
      --vim.keymap.set("n", "<leader>nbl", runner.run_line, { desc = "run line", silent = true })
      --vim.keymap.set("v", "<leader>nbv", runner.run_range, { desc = "run visual range", silent = true })
      vim.keymap.set("n", "<leader>mc", function()
        local lang = vim.fn.input("Code language: ", "python")
        vim.fn.append(vim.fn.line("."), { "```" .. lang, "", "```" })
        vim.fn.cursor(vim.fn.line(".") + 2, 0)
      end, { desc = "Add cell", silent = true })
    end,
  },
  {
    "jmbuhr/otter.nvim",
    ft = { "markdown", "quarto", "norg" },
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
  },
}
