----------------------------
-------- Which key ---------
----------------------------
local wk = require("which-key")

----------------------------
---------- Molten ----------
----------------------------
wk.add({
  {
    "<leader>m",
    group = "molten",
    icon = { icon = "🔥 " },
  },
}, { mode = { "n", "v" } })

----------------------------
--------- Notebook ---------
----------------------------
wk.add({
  {
    "<leader>n",
    group = "notebook",
    icon = { icon = "📓 " },
  },
}, { mode = { "n" } })

----------------------------
----------- Wiki -----------
----------------------------
wk.add({
  {
    "<localleader>w",
    group = "wiki",
    icon = { icon = "󰖬 " },
  },
}, { mode = { "n", "v" } })

wk.add({
  {
    "<localleader>W",
    group = "wiki",
    icon = { icon = "󰖬 " },
  },
}, { mode = { "n", "v" } })

vim.g.wiki_mappings_local = {
  ["<plug>(wiki-link-follow-split)"] = "<localleader>WH",
  ["<plug>(wiki-link-follow-vsplit)"] = "<localleader>WV",
  ["<plug>(wiki-link-follow-tab)"] = "<localleader>WHT",
}
