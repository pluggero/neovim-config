return {
  "lukas-reineke/indent-blankline.nvim",
  version = "3.9.0",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  opts = {
    indent = { char = "┊" },
  },
}
