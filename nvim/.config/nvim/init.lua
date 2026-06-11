--- Enes's Neovim config
----------------------------------------------
---  SETTINGS
----------------------------------------------
-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Nerd font (JetBrainsMono Nerd Font installed)
vim.g.have_nerd_font = true

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- no need for mode
vim.o.showmode = false

-- case insensitive search unless	there is a capital letter
vim.o.ignorecase = true
vim.o.smartcase = true

-- no wrap
vim.o.wrap = false

-- decrease mapped sequence resolve timeoutlen
vim.o.timeoutlen = 200
vim.o.ttimeoutlen = 10

-- no mouse
vim.o.mouse = ""

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- swapfile is annoying only
vim.o.swapfile = false

-- keep signcolumn on
vim.o.signcolumn = "yes"

-- better looking rounded borders
vim.o.winborder = "rounded"

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Enable search as you type
vim.o.incsearch = true

-- reoload buffer on focus
vim.o.autoread = true
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

-- Set statusline high and no background
vim.cmd(":hi statusline guibg=None")

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function() vim.hl.on_yank() end,
})

----------------------------------------------
---  REMAPS
----------------------------------------------
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '<leader>lf', function()
	-- TODO: solve this with conform
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports.ruff" } }, apply = true })
	vim.defer_fn(function()
		vim.lsp.buf.format()
		vim.cmd("write")
	end, 100)
end)
map('n', '<C-p>', function() Snacks.picker.smart() end)
map('n', '<leader>f', function() Snacks.picker.git_files() end)
map('n', '<leader>b', function() Snacks.picker.buffers() end)
map('n', '<leader>rg', function() Snacks.picker.grep() end)
map('n', '<leader>h', function() Snacks.picker.help() end)
map('n', '<leader>k', function() Snacks.picker.keymaps() end)
map('n', '<leader>p', function() Snacks.picker.recent() end)
map('n', '<leader>e', ':Oil<CR>')

map('n', '<leader>gg', function() Snacks.lazygit() end)
map({ 'n', 'v' }, '<leader>gb', function() Snacks.gitbrowse() end)
map('n', '<leader>z', function() Snacks.zen() end)
map('n', '<leader>bd', function() Snacks.bufdelete() end)
map('n', '<C-/>', function() Snacks.terminal() end)

map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
map({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')
map({ 'n', 'v', 'x' }, '<leader>s', ':e #<CR>')
map({ 'n', 'v', 'x' }, '<leader>S', ':sf #<CR>')
map({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")

vim.cmd([[
nnoremap g= g+| " g=g=g= is less awkward than g+g+g+
]])

map("n", "gh", "0", { desc = "Jump: Start of line" })
map("n", "gl", "$", { desc = "Jump: End of line" })
vim.keymap.set("n", "yab", ":%y<CR>", { silent = true })
vim.keymap.set("n", "vab", "ggVG", { noremap = true, silent = true })

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Enter substitue mode in selection" })
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })
map({ "n" }, "<leader>c", "1z=")


----------------------------------------------
---  LSP & DIAGNOSTICS
----------------------------------------------
vim.diagnostic.config {
	update_in_insert = false,
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	-- Can switch between these as you prefer
	virtual_text = true, -- Text shows up at the end of the line
	virtual_lines = false, -- Text shows up underneath the line, with virtual lines

	-- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
	jump = { float = true },
}
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })


----------------------------------------------
---  PLUGINS (lazy.nvim)
----------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"vague-theme/vague.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("vague").setup({ transparent = true })
			vim.cmd("colorscheme vague")
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile   = { enabled = true },
			quickfile = { enabled = true },
			picker    = { enabled = true },
			notifier  = { enabled = true, timeout = 3000 },
			input     = { enabled = true },
			dashboard = { enabled = true },
			zen       = { enabled = true },
			terminal  = { enabled = true },
			bufdelete = { enabled = true },
			gitbrowse = { enabled = true },
			lazygit   = { enabled = true },
		},
	},
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				view_options = { show_hidden = true },
				columns = { "icon" },
				float = {
					max_width = 0.3,
					max_height = 0.6,
					border = "rounded",
				},
			})
		end,
	},
	{ "neovim/nvim-lspconfig" },
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			keymaps = {
				accept_suggestion = "<C-j>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-k>",
			},
			disable_keymaps = false,
		},
	},
	{ "nvim-treesitter/nvim-treesitter" },
	{ "lewis6991/gitsigns.nvim",        opts = {} },
	{ "akinsho/git-conflict.nvim",      opts = {} },
	{ "NMAC427/guess-indent.nvim",      opts = {} },
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "none",
				["<C-b>"] = { "scroll_documentation_up" },
				["<C-f>"] = { "scroll_documentation_down" },
				["<C-n>"] = { "show" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = false, auto_insert = false },
				},
				menu = { border = "rounded" },
				documentation = {
					auto_show = true,
					window = { border = "rounded" },
				},
			},
			sources = {
				default = { "lsp", "path", "buffer" },
				per_filetype = {
					gitcommit = { "buffer" },
				},
			},
			cmdline = {
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" then
						return { "cmdline", "path" }
					end
					return {}
				end,
			},
			signature = { enabled = true },
		},
	},
	{ "folke/which-key.nvim",   opts = {} },
	{ "echasnovski/mini.icons", lazy = true, opts = {} },
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VimEnter",
		opts = {},
	},
})


vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local opts = { buffer = args.buf }
		map('n', 'gd', vim.lsp.buf.definition, opts)
		map('n', 'gD', vim.lsp.buf.declaration, opts)
		map('n', 'gr', function() Snacks.picker.lsp_references() end, opts)
		map('n', '<leader>rn', vim.lsp.buf.rename, opts)
		map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		map('n', 'K', vim.lsp.buf.hover, opts)
	end,
})


local lsp_servers = { "lua_ls", "basedpyright", "clangd", "ruff", "rust_analyzer" }
vim.lsp.enable(lsp_servers)
map('n', '<leader>lt', function()
	local clients = vim.lsp.get_clients()
	if #clients > 0 then
		vim.lsp.stop_client(clients)
		print("LSP stopped")
	else
		vim.lsp.enable(lsp_servers)
		print("LSP started")
	end
end)
