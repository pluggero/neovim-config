return {
  "lukas-reineke/indent-blankline.nvim",
  version = "3.10.1",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  opts = {
    indent = { char = "┊" },
  },
}
