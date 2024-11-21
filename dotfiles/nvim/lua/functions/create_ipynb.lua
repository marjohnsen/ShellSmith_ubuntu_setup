local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function create_notebook()
  local filename = vim.fn.input("Enter notebook file path: ", "", "file")

  if not filename:match("%.ipynb$") then
    filename = filename .. ".ipynb"
  end

  local file = io.open(filename, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. filename)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

vim.api.nvim_create_user_command("CreateNotebook", function()
  create_notebook()
end, {})

vim.keymap.set("n", "<leader>nb", ":CreateNotebook<CR>", { desc = "Create ipynb" })
