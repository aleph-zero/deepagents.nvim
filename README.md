# deepagents.nvim

Toggle the [LangChain DeepAgents CLI](https://docs.langchain.com/oss/python/deepagents/cli/overview)
inside Neovim — vertical split, horizontal split, or floating window. Modeled
after the common Claude Code / aider terminal-toggle plugins.

## Requirements

- Neovim 0.9+
- [`akinsho/toggleterm.nvim`](https://github.com/akinsho/toggleterm.nvim)
- The `deepagents` CLI on `$PATH`:
  ```sh
  uv tool install deepagents-cli
  # or
  curl -LsSf https://langch.in/gh-da-cli | bash
  ```

## Install

### lazy.nvim

```lua
{
  "andrewseldon/deepagents.nvim", -- replace with your repo path
  dependencies = { "akinsho/toggleterm.nvim" },
  cmd = "DeepAgents",
  keys = { "<leader>daa", "<leader>daC", "<leader>daf" },
  opts = {},
}
```

`opts = {}` is enough to get the defaults below. Pass an `opts` table to override
any of them.

## Defaults

```lua
{
  cmd = "deepagents -S recommended", -- shell allowlist for safe auto-approve
  direction = "vertical",            -- vertical | horizontal | float
  start_in_insert = true,
  keymaps = {
    vertical   = "<leader>daa",
    horizontal = "<leader>daC",
    float      = "<leader>daf",
  },
  command = "DeepAgents",            -- :DeepAgents [direction]; set to false to disable
  terminal_opts = {},                -- merged into toggleterm Terminal:new()
}
```

Set any keymap to `false` (or `""`) to skip it. Set `command = false` to skip
registering the user command.

## Usage

- `<leader>daa` — toggle in a vertical split (default 40% width if you set
  toggleterm's `size` callback; see below)
- `<leader>daC` — toggle in a horizontal split
- `<leader>daf` — toggle in a floating window
- `:DeepAgents` — toggle in the default direction
- `:DeepAgents float` — toggle in a specific direction

Pressing the same keymap again hides the terminal without killing the session.

## Programmatic API

```lua
local da = require("deepagents")
da.toggle("vertical")
da.open("float")
da.close()
```

## Recommended toggleterm config

This plugin defers sizing/styling to your toggleterm setup so it stays
consistent with any other terminals you toggle. A reasonable baseline:

```lua
require("toggleterm").setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 20
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  shade_terminals = false,
}
```

## Auto-reload buffers when DeepAgents edits files

DeepAgents writes files directly to disk. To pick those changes up in open
buffers without manual `:e`, add this once in your config (CLI-agnostic — covers
Claude Code, aider, codex, etc. too):

```lua
vim.o.autoread = true

local timer = vim.uv.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  if vim.fn.getcmdwintype() == "" then
    vim.cmd "checktime"
  end
end))

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
```

## Health check

```
:checkhealth deepagents
```

Verifies that toggleterm is installed and `deepagents` is on `$PATH`.

## Why a wrapper?

The DeepAgents CLI is a TUI — anything that runs a TUI in a terminal works.
This plugin is a thin (~80 lines) wrapper over toggleterm that pins the command,
sets sensible toggle keymaps, and exposes a `:DeepAgents` command. If you
already have a toggleterm-based workflow, you could inline the equivalent in a
dozen lines of your own config; the plugin exists so you don't have to.

## License

MIT
