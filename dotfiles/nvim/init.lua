-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.python3_host_prog = vim.fn.system("pyenv prefix neovim") .. "/bin/python"

require("config.lazy")
