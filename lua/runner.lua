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

vim.keymap.set("n", "<leader>tc", function()
	M.orignal_window_id = vim.api.nvim_get_current_win()
	close_prev_run()
	local full_command = run_test_command()
	vim.cmd("new")
	M.test_window_id = vim.api.nvim_get_current_win()
	print("Open window " .. M.test_window_id)
	M.current_buffer_id = vim.api.nvim_create_buf(false, true)
	print("Create buffer " .. M.current_buffer_id)
	vim.api.nvim_set_current_buf(M.current_buffer_id)

	vim.fn.termopen(full_command)
	vim.api.nvim_set_current_win(M.orignal_window_id)
end, { desc = "[t]est [c]urrent file" })

vim.keymap.set("n", "<leader>rc", function()
	M.orignal_window_id = vim.api.nvim_get_current_win()
	close_prev_run()
	local full_command = run_package_command()
	print("Run command: " .. full_command)
	vim.cmd("new")
	M.test_window_id = vim.api.nvim_get_current_win()
	print("Open window " .. M.test_window_id)
	M.current_buffer_id = vim.api.nvim_create_buf(false, true)
	print("Create buffer " .. M.current_buffer_id)
	vim.api.nvim_set_current_buf(M.current_buffer_id)

	vim.fn.termopen(full_command)
	vim.api.nvim_set_current_win(M.orignal_window_id)
end, { desc = "[r]un [c]urrent file" })

vim.keymap.set("n", "<leader>td", function()
	close_prev_run()
end, { desc = "[t]estresult [d]iscad" })
return M
