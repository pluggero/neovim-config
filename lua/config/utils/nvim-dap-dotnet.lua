--[[
nvim-dap-dotnet.lua - .NET debugging utilities for nvim-dap

This module provides utilities for .NET debugging with nvim-dap, including:
- Project discovery and .csproj file handling
- .NET runtime folder detection 
- Process selection and filtering for attach scenarios
- DLL path resolution for launch configurations

Dependencies:
- plenary.nvim (Path utilities)
- nvim-dap (debugging framework)
--]]

local M = {}

-- =======================
-- CONSTANTS
-- =======================
local CSPROJ_PATTERN = "/*.csproj"
local NET_FOLDER_PATTERN = "/net*"
local BIN_DEBUG_PATH = "/bin/Debug"

-- =======================
-- UTILITY FUNCTIONS
-- =======================

--- Error handling utility with optional print mode
--- @param message string Error message
--- @param should_print boolean If true, prints message instead of throwing error
--- @return nil
local function handle_error(message, should_print)
	if should_print then
		print(message)
		return nil
	else
		error(message)
	end
end

--- Input validation for path parameters
--- @param path string|nil Path to validate
--- @param param_name string Parameter name for error messages
--- @return boolean Always returns true if validation passes
local function validate_path(path, param_name)
	if not path or path == "" then
		handle_error(param_name .. " cannot be empty or nil")
	end
	return true
end

-- =======================
-- FILE OPERATIONS
-- =======================

--- Find .csproj files in a directory
--- @param directory string Directory to search in
--- @return table List of .csproj file paths
local function find_csproj_files(directory)
	validate_path(directory, "directory")
	return vim.fn.glob(directory .. CSPROJ_PATTERN, false, true)
end

--- Extract project name from .csproj file path
--- @param csproj_path string Path to .csproj file
--- @return string Project name without extension
local function get_project_name(csproj_path)
	return vim.fn.fnamemodify(csproj_path, ":t:r")
end

-- =======================
-- PROJECT DISCOVERY
-- =======================

--- Find the root directory of a .NET project by searching for .csproj files
--- Walks up the directory tree from start_path until a .csproj file is found
--- @param start_path string Starting directory path
--- @return string|nil Project root path or nil if not found
function M.find_project_root_by_csproj(start_path)
	validate_path(start_path, "start_path")

	local Path = require("plenary.path")
	local path = Path:new(start_path)

	while true do
		local csproj_files = find_csproj_files(path:absolute())
		if #csproj_files > 0 then
			return path:absolute()
		end

		local parent = path:parent()
		if parent:absolute() == path:absolute() then
			return nil
		end

		path = parent
	end
end

--- Find the highest version of the netX.Y folder within a given path
--- Sorts .NET runtime folders by version number and returns the highest
--- @param bin_debug_path string Path to bin/Debug directory
--- @return string Path to highest version net folder
function M.get_highest_net_folder(bin_debug_path)
	validate_path(bin_debug_path, "bin_debug_path")

	local dirs = vim.fn.glob(bin_debug_path .. NET_FOLDER_PATTERN, false, true)

	if #dirs == 0 then
		handle_error("No netX.Y folders found in " .. bin_debug_path)
	end

	table.sort(dirs, function(a, b)
		local ver_a = tonumber(a:match("net(%d+)%.%d+"))
		local ver_b = tonumber(b:match("net(%d+)%.%d+"))
		return (ver_a or 0) > (ver_b or 0)
	end)

	return dirs[1]
end

--- Build and return the full path to the .dll file for debugging
--- Resolves the current project's DLL path for launch configurations
--- @return string Full path to the project's DLL file
function M.build_dll_path()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		handle_error("No file is currently open")
	end

	local current_dir = vim.fn.fnamemodify(current_file, ":p:h")
	local project_root = M.find_project_root_by_csproj(current_dir)
	if not project_root then
		handle_error("Could not find project root (no .csproj found)")
	end

	-- Cache project files lookup to avoid redundant glob operations
	local csproj_files = find_csproj_files(project_root)
	if #csproj_files == 0 then
		handle_error("No .csproj file found in project root")
	end

	-- Use first .csproj file found (most common case)
	local project_name = get_project_name(csproj_files[1])
	local bin_debug_path = project_root .. BIN_DEBUG_PATH

	-- Early validation of bin/Debug path existence
	if vim.fn.isdirectory(bin_debug_path) == 0 then
		handle_error("Build output directory not found: " .. bin_debug_path .. ". Please build the project first.")
	end

	local highest_net_folder = M.get_highest_net_folder(bin_debug_path)
	local dll_path = highest_net_folder .. "/" .. project_name .. ".dll"

	-- Validate DLL exists before returning
	if vim.fn.filereadable(dll_path) == 0 then
		handle_error("DLL file not found: " .. dll_path .. ". Please build the project first.")
	end

	print("Launching: " .. dll_path)
	return dll_path
end

-- =======================
-- UI HELPER FUNCTIONS
-- =======================

--- Add numerical indices to array items for display
--- @param array table Array of strings to number
--- @return table Numbered array items
local function number_indices(array)
	local result = {}
	for i, value in ipairs(array) do
		result[i] = i .. ": " .. value
	end
	return result
end

--- Display options and get user selection via inputlist
--- @param prompt_title string Title to show above options
--- @param options table Array of option strings
--- @return string|nil Selected option or nil if cancelled
local function display_options(prompt_title, options)
	local numbered_options = number_indices(options)
	table.insert(numbered_options, 1, prompt_title)

	local choice = vim.fn.inputlist(numbered_options)

	if choice > 0 and choice <= #numbered_options then
		return numbered_options[choice + 1]
	else
		return nil
	end
end

--- Generic file selection helper using system commands
--- @param cmd string Shell command to execute
--- @param opts table Options containing empty_message, multiple_title_message, allow_multiple
--- @return string|table|nil Selected file(s) or nil if none found
local function file_selection(cmd, opts)
	local results = vim.fn.systemlist(cmd)

	if #results == 0 then
		handle_error(opts.empty_message, true)
		return nil
	end

	if opts.allow_multiple then
		return results
	end

	if #results == 1 then
		return results[1]
	end

	return display_options(opts.multiple_title_message, results)
end

--- Project selection helper for attach functionality
--- @param project_path string Path to search for projects
--- @param allow_multiple boolean Whether to allow multiple project selection
--- @return string|table|nil Selected project file(s) or nil if none found
local function project_selection(project_path, allow_multiple)
	validate_path(project_path, "project_path")

	local check_csproj_cmd = string.format('find %s -type f -name "*.csproj"', vim.fn.shellescape(project_path))
	return file_selection(check_csproj_cmd, {
		empty_message = "No csproj files found in " .. project_path,
		multiple_title_message = "Select project:",
		allow_multiple = allow_multiple,
	})
end

-- =======================
-- PROCESS SELECTION
-- =======================

--- Create process filter based on project files
--- @param project_files string|table Project file path(s) to match against
--- @return function Filter function for process selection
local function create_process_filter(project_files)
	return function(proc)
		if type(project_files) == "table" then
			for _, file in pairs(project_files) do
				local project_name = get_project_name(file)
				if vim.endswith(proc.name, project_name) then
					return true
				end
			end
			return false
		elseif type(project_files) == "string" then
			local project_name = get_project_name(project_files)
			return vim.startswith(proc.name, project_name or "dotnet")
		end
		return false
	end
end

--- Smart process picker for attaching debugger to .NET processes
--- Automatically filters processes based on project names found in project_path
--- @param dap_utils table DAP utilities object with get_processes and pick_process methods
--- @param project_path string Path to search for .NET projects
--- @return number|nil Process ID to attach to, or nil if none found/selected
function M.smart_pick_process(dap_utils, project_path)
	validate_path(project_path, "project_path")

	local project_files = project_selection(project_path, true)
	if not project_files then
		return nil
	end

	local filter = create_process_filter(project_files)
	local processes = vim.tbl_filter(filter, dap_utils.get_processes())

	if #processes == 0 then
		handle_error("No dotnet processes could be found automatically. Try 'Attach' instead", true)
		return nil
	end

	if #processes == 1 then
		return processes[1].pid
	end

	return dap_utils.pick_process({ filter = filter })
end

return M
