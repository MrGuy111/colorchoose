-- lua/colorchoose/init.lua
local M = {}

--- Optional setup function – lets the user override default configuration.
function M.setup(opts)
    if opts then
        local config = require('colorchoose.config')
        for k, v in pairs(opts) do
            config[k] = v
        end
    end
end

--- Open the ColorChoose UI.
function M.open(opts)
    require('colorchoose.ui').open(opts)
end

return M
