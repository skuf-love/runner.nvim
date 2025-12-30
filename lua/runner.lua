local M = {
	current_buffer_id = nil,
	test_window_id = nil,
	original_window_id = nil,
}
M.setup = function()
	-- Nothing here yet
end

local run_test_command = function()
	local file_dir = vim.fn.expand("%:p:h")
	return "go test " .. file_dir
end

local run_package_command = function()
	local file_dir = vim.fn.expand("%:p:h")
	return "go run " .. file_dir
end

local clean_empty_bufs = function()
	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == "" and not vim.bo.modified and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end
local close_prev_run = function()
	if M.test_window_id ~= nil and vim.api.nvim_win_is_valid(M.test_window_id) then
		print("Close window " .. M.test_window_id)
		vim.api.nvim_win_close(M.test_window_id, true)
		M.test_window_id = nil
	end
	if M.current_buffer_id ~= nil and vim.api.nvim_buf_is_valid(M.current_buffer_id) then
		print("Delete buffer " .. M.current_buffer_id)
		vim.api.nvim_buf_delete(M.current_buffer_id, { force = true })
		M.current_buffer_id = nil
	end
	clean_empty_bufs()
end

local jump_to_line = function()
	local line = vim.api.nvim_get_current_line()
	print("Current line: " .. line)
	local path = line:match("([^%w]/[^%s]+)")
	if path == nil then
		return
	end
	print("Matched path: " .. path)
	local file, line_num, col = path:match("([^:]+):?(%d*):?(%d*)")
	print("File: " .. file)
	if line_num ~= "" then
		print("Line Num: " .. #line_num)
	end
	local absolute_path = vim.fn.fnamemodify(file, ":p")
	print("Expanded path: " .. absolute_path)
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
	print("Open window " .. M.test_window_id)
	M.current_buffer_id = vim.api.nvim_create_buf(false, true)
	print("Create buffer " .. M.current_buffer_id)
	vim.api.nvim_set_current_buf(M.current_buffer_id)

	vim.keymap.set("n", "<enter>", jump_to_line, { buffer = M.current_buffer_id })

	print("Running command: " .. shell_command)
	vim.fn.termopen(shell_command)
	vim.api.nvim_set_current_win(M.orignal_window_id)
end

vim.keymap.set("n", "<leader>tc", function()
	run_in_split_terminal(run_test_command())
end, { desc = "[t]est [c]urrent file" })

vim.keymap.set("n", "<leader>rc", function()
	run_in_split_terminal(run_package_command())
end, { desc = "[r]un [c]urrent file" })

vim.keymap.set("n", "<leader>td", function()
	close_prev_run()
end, { desc = "[t]estresult [d]iscad" })
return M
