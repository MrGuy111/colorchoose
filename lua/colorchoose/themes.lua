-- lua/colorchoose/themes.lua
local M = {}

--- Return a sorted list of all available colorschemes.
function M.list()
    local colors = vim.fn.getcompletion('', 'color')
    local seen   = {}
    local result = {}

    for _, name in ipairs(colors) do
        if not seen[name] then
            seen[name] = true
            table.insert(result, name)
        end
    end

    table.sort(result)
    return result
end

--- Apply a colorscheme by name.
function M.apply(name)
    vim.cmd('colorscheme ' .. name)
end

return M
