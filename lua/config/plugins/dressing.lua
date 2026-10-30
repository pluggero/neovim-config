return {
  "stevearc/dressing.nvim",
  version = "3.1.1",
  event = "VeryLazy",
  opts = {
    input = {
      get_config = function(opts)
        -- Center and enlarge the dap launch-args prompt, closer to the
        -- centered Telescope-backed vim.ui.select dialog used for Attach.
        if opts.kind == "dap_args" then
          return {
            relative = "editor",
            prefer_width = 60,
            title_pos = "center",
          }
        end
      end,
    },
  },
}
