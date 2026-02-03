local M = {
	current_buffer_id = nil,
	test_window_id = nil,
	original_window_id = nil,
}

local clean_empty_bufs = function()
	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == "" and not vim.bo.modified and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end

local close_prev_run = function()
	if M.test_window_id ~= nil and vim.api.nvim_win_is_valid(M.test_window_id) then
		vim.api.nvim_win_close(M.test_window_id, true)
		M.test_window_id = nil
	end
	if M.current_buffer_id ~= nil and vim.api.nvim_buf_is_valid(M.current_buffer_id) then
		vim.api.nvim_buf_delete(M.current_buffer_id, { force = true })
		M.current_buffer_id = nil
	end
	clean_empty_bufs()
end

local jump_to_line = function()
	local line = vim.api.nvim_get_current_line()
	local path = line:match("([^%w]/[^%s]+)")
	if path == nil then
		return
	end
	local file, line_num, col = path:match("([^:]+):?(%d*):?(%d*)")
	local absolute_path = vim.fn.fnamemodify(file, ":p")
	local buf_num = vim.fn.bufnr(absolute_path)
	if buf_num ~= -1 then
		local buf_wins = vim.fn.win_findbuf(buf_num)
		if #buf_wins > 0 then
			vim.api.nvim_win_set_cursor(buf_wins[1], { tonumber(line_num) or 0, tonumber(col) or 0 })
		end
	end
end

local run_in_split_terminal = function(shell_command)
	M.orignal_window_id = vim.api.nvim_get_current_win()
	close_prev_run()
	vim.cmd("new")
	M.test_window_id = vim.api.nvim_get_current_win()
	M.current_buffer_id = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(M.current_buffer_id)

	vim.keymap.set("n", "<enter>", jump_to_line, { buffer = M.current_buffer_id })

	vim.fn.termopen(shell_command)
	vim.api.nvim_set_current_win(M.orignal_window_id)
end

vim.keymap.set("n", "<leader>td", function()
	close_prev_run()
end, { desc = "[t]estresult [d]iscad" })

local group = vim.api.nvim_create_augroup("MyPlugin", { clear = true })
local go_actions = require("runner.filetypes.go")

local define_keymaps = function(keymaps_for_file)
	for i = 1, #keymaps_for_file do
		local key_conf = keymaps_for_file[i]
		print("Define auto command " .. key_conf.keys)
		vim.keymap.set("n", "<leader>" .. key_conf.keys, function()
			run_in_split_terminal(key_conf.cmd())
		end, { desc = key_conf.desc, buffer = true })
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
	group = group,
	callback = function()
		local filepath = vim.api.nvim_buf_get_name(0)
		local filename = vim.fn.fnamemodify(filepath, ":t")
		if filename:match(".go$") then
			print("Go file matched")
			define_keymaps(go_actions)
		end
	end,
})
M.setup = function() end
return M
