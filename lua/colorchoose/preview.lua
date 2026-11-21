-- lua/colorchoose/preview.lua
local M = {}

--- Read a file into a table of lines.
local function read_file(path)
    local fd = io.open(path, 'r')
    if not fd then
        return { 'Could not open file: ' .. path }
    end

    local lines = {}
    for line in fd:lines() do
        table.insert(lines, line)
    end
    fd:close()
    return lines
end

--- Get the lines that should be shown on the preview screen.
function M.get_preview_lines(opts)
    local code_dir = opts.code_dir or 'code'
    local file     = opts.preview_file

    if not file then
        local files = vim.fn.globpath(code_dir, '*', false, true)
        if #files > 0 then
            file = files[1]
        end
    end

    if not file then
        return { 'No file found in "' .. code_dir .. '"' }
    end

    return read_file(file)
end

--- Configure the buffer so that other plugins are effectively disabled.
--- `eventignorewin = 'all'` tells Neovim to ignore all window/buffer
--- autocommands for this window, which prevents most plugins from
--- reacting to events in the preview buffer.
function M.setup_buffer(buf, opts)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Ignore all window/buffer events for this window
    vim.api.nvim_buf_set_option(buf, 'eventignorewin', 'all')

    -- Prevent ftplugin scripts from running
    vim.b[buf].did_ftplugin = 1

    -- Optionally set a filetype for syntax highlighting
    local ft = 'lua' -- adjust if you prefer automatic detection
    vim.api.nvim_buf_set_option(buf, 'filetype', ft)
end

return M
