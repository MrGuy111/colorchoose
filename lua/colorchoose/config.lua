-- lua/colorchoose/config.lua
local M = {
    -- Size of the floating window (percentage of the editor)
    width_ratio  = 0.8,
    height_ratio = 0.8,

    -- Border style – 'rounded' gives smooth, rounded corners
    border       = 'rounded',

    -- Folder that contains the preview files (relative to the current working directory)
    code_dir     = 'code',

    -- If nil, the first file found in `code_dir` is used
    preview_file = nil,
}

return M
