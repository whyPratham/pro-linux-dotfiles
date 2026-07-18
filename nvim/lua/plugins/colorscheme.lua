return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        mason = true,
        lazy = true,
        mini = true,
        noice = true,
        notify = true,
        lsp_trouble = true,
      },
      color_overrides = {
        mocha = {
          mauve = "#cba6f7",
        },
      },
      highlight_groups = {
        Comment = { fg = "#585b70", style = { "italic" } },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
