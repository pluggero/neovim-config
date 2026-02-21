return {
  "lukas-reineke/indent-blankline.nvim",
  version = "3.9.1",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  opts = {
    indent = { char = "┊" },
  },
}
