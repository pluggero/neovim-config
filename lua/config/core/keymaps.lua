vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- custom scripts
keymap.set("n", "<leader>ss", ":%!sort -u --version-sort<CR>", { desc = "Sort the buffer removing duplicates" }) -- Sort the buffer removing duplicates
keymap.set("v", "<leader>ss", ":!sort -u --version-sort<CR>", { desc = "Sort selection removing duplicates" })
keymap.set(
	"n",
	"<leader>sg",
	":tabnew|read !grep -Hnr '<C-R><C-W>'<CR>",
	{ desc = "Grep recursively for word under cursor in new tab" }
) -- Grep recursively for word under cursor in new tab
keymap.set("n", "<leader>sd", ":!echo <C-R><C-W> | base64 -d<CR>", { desc = "Base64 decode word under cursor" }) -- Base64 decode word under cursor
keymap.set(
	"n",
	"<leader>fl",
	[[:%s/\([^\r\n]\)\r\?\n\([^\r\n]\)/\1 \2/g<CR>]],
	{ desc = "Fix line breaks in text copied from a PDF" }
) -- Fixes the linebreaks from a text that was copied from a pdf
keymap.set("n", "<leader>fp", function()
	local file_dir = vim.fn.expand("%:p:h")
	if file_dir ~= "" then
		vim.fn.setreg("+", file_dir) -- Copies the directory path to the clipboard
		vim.notify("File path copied to clipboard.")
	else
		vim.notify("No file is currently focused.", vim.log.levels.WARN)
	end
end, { desc = "Copy the current file's directory to clipboard" }) -- Copy the current file's directory to clipboard

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Move selected lines in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Better Join Behavior
keymap.set("n", "J", "mzJ`z")

-- Better scroll behavior
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- window management
keymap.set("n", "<leader>s|", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>s-", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>s=", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>th", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tt", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
