-- plugin/colorchoose.lua
if vim.g.loaded_colorchoose then
    return
end
vim.g.loaded_colorchoose = true

vim.api.nvim_create_user_command('ColorChoose', function()
    require('colorchoose').open()
end, { desc = 'Open the ColorChoose theme picker' })
