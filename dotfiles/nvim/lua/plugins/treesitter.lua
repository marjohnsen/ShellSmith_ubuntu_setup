return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "norg" })

      opts.textobjects = opts.textobjects or {}
      opts.textobjects.move = opts.textobjects.move or {}
      opts.textobjects.move.goto_next_start =
        vim.tbl_deep_extend("force", opts.textobjects.move.goto_next_start or {}, {
          ["<leader>mj"] = { query = "@code_cell.inner", desc = "next code block" },
        })
      opts.textobjects.move.goto_previous_start =
        vim.tbl_deep_extend("force", opts.textobjects.move.goto_previous_start or {}, {
          ["<leader>mk"] = { query = "@code_cell.inner", desc = "previous code block" },
        })

      opts.textobjects.select = vim.tbl_deep_extend("force", opts.textobjects.select or {}, {
        enable = true,
        lookahead = true,
        keymaps = {
          ["ib"] = { query = "@code_cell.inner", desc = "in block" },
          ["ab"] = { query = "@code_cell.outer", desc = "around block" },
        },
      })

      opts.textobjects.swap = vim.tbl_deep_extend("force", opts.textobjects.swap or {}, {
        enable = true,
        swap_next = {
          ["<leader>ml"] = { query = "@code_cell.outer", desc = "Swap next block" },
        },
        swap_previous = {
          ["<leader>mh"] = { query = "@code_cell.outer", desc = "Swap previous block" },
        },
      })
    end,
  },
}
