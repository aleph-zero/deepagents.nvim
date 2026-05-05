local M = {}

local health = vim.health

function M.check()
  health.start "deepagents.nvim"

  local ok = pcall(require, "toggleterm.terminal")
  if ok then
    health.ok "toggleterm.nvim is installed"
  else
    health.error "toggleterm.nvim not found (required dependency)"
  end

  if vim.fn.executable "deepagents" == 1 then
    local exe = vim.fn.exepath "deepagents"
    health.ok(("`deepagents` binary found at %s"):format(exe))
  else
    health.error "`deepagents` binary not on $PATH (install with: uv tool install deepagents-cli)"
  end
end

return M
