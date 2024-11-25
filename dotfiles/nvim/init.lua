local pyenv_prefix = vim.fn.system("pyenv prefix neovim"):gsub("\n", "")
vim.g.python3_host_prog = pyenv_prefix .. "/bin/python"

require("config.lazy")

require("functions.create_ipynb")
