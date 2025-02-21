-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set(
  "n",
  "<leader>\\",
  "<cmd>!bash -c 'cat %:p:h/1.in | python3 %:p:h/solve.py && " .. 'echo "----------------"' .. "&& cat %:p:h/1.ans'<cr>",
  { desc = "run command for codequest" }
)
