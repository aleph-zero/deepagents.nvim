local M = {}

local defaults = {
  cmd = "deepagents -S recommended",
  direction = "vertical",
  start_in_insert = true,
  keymaps = {
    vertical = "<leader>daa",
    horizontal = "<leader>daC",
    float = "<leader>daf",
  },
  command = "DeepAgents",
  terminal_opts = {},
}

local state = { terminal = nil, config = nil }

local function build_terminal()
  local ok, mod = pcall(require, "toggleterm.terminal")
  if not ok then
    error("deepagents.nvim requires akinsho/toggleterm.nvim")
  end
  local cfg = state.config
  local opts = vim.tbl_extend("force", {
    cmd = cfg.cmd,
    hidden = true,
    direction = cfg.direction,
    on_open = function()
      if cfg.start_in_insert then
        vim.cmd "startinsert!"
      end
    end,
  }, cfg.terminal_opts or {})
  return mod.Terminal:new(opts)
end

local function ensure_setup()
  if not state.config then
    M.setup {}
  end
end

function M.toggle(direction)
  ensure_setup()
  state.terminal = state.terminal or build_terminal()
  state.terminal.direction = direction or state.config.direction
  state.terminal:toggle()
end

function M.open(direction)
  ensure_setup()
  state.terminal = state.terminal or build_terminal()
  state.terminal.direction = direction or state.config.direction
  if not state.terminal:is_open() then
    state.terminal:open()
  end
end

function M.close()
  if state.terminal and state.terminal:is_open() then
    state.terminal:close()
  end
end

function M.setup(opts)
  state.config = vim.tbl_deep_extend("force", defaults, opts or {})

  for direction, lhs in pairs(state.config.keymaps or {}) do
    if lhs and lhs ~= "" then
      vim.keymap.set("n", lhs, function()
        M.toggle(direction)
      end, { desc = ("DeepAgents (%s)"):format(direction) })
    end
  end

  if state.config.command then
    vim.api.nvim_create_user_command(state.config.command, function(args)
      M.toggle(args.args ~= "" and args.args or nil)
    end, {
      nargs = "?",
      complete = function()
        return { "vertical", "horizontal", "float" }
      end,
      desc = "Toggle DeepAgents terminal",
    })
  end
end

return M
