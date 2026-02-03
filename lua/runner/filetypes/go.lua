print("Go actions loaded")
return {
	{
		cmd = function()
			print("Run Current")
			local file_dir = vim.fn.expand("%:p:h")
			return "go run " .. file_dir
		end,
		keys = "rc",
		desc = "[r]urn [c]urrent file",
	},
	{
		cmd = function()
			print("Test All")
			local file_dir = vim.fn.expand("%:p:h")
			return "go test " .. file_dir
		end,
		keys = "ta",
		desc = "[t]est [a]ll",
	},
}
