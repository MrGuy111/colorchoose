-- lua/colorchoose/ui.lua
local M = {}

local state = {
    win            = nil,
    buf            = nil,
    screen         = 'themes', -- 'themes' or 'preview'
    themes         = {},
    current_index  = 1,
    original_theme = nil,
    opts           = {},
}

-- ------------------------------------------------------------
-- Helpers
-- ------------------------------------------------------------
local function close()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        vim.api.nvim_buf_delete(state.buf, { force = true })
    end
    state.win = nil
    state.buf = nil
end

local function clear_highlights()
    vim.api.nvim_buf_clear_namespace(state.buf, -1, 0, -1)
end

local function set_lines(lines)
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
end

-- ------------------------------------------------------------
-- Renderers
-- ------------------------------------------------------------
local function render_themes()
    local lines = { 'Select a theme:', '' }
    for i, theme in ipairs(state.themes) do
        local prefix = (i == state.current_index) and '> ' or '  '
        table.insert(lines, prefix .. theme)
    end

    set_lines(lines)

    -- Highlight the current theme line
    clear_highlights()
    local hl_line = state.current_index + 1 -- 0‑based line number
    vim.api.nvim_buf_add_highlight(state.buf, -1, 'Visual', hl_line, 0, -1)
end

local function render_preview()
    local lines = require('colorchoose.preview').get_preview_lines(state.opts)
    set_lines(lines)
    require('colorchoose.preview').setup_buffer(state.buf, state.opts)
end

local function switch_screen(screen)
    state.screen = screen
    if screen == 'themes' then
        render_themes()
    else
        render_preview()
    end
end

-- ------------------------------------------------------------
-- Theme navigation / application
-- ------------------------------------------------------------
local function apply_current_theme()
    local theme = state.themes[state.current_index]
    if theme then
        require('colorchoose.themes').apply(theme)
    end
end

local function next_theme()
    state.current_index = state.current_index + 1
    if state.current_index > #state.themes then
        state.current_index = 1
    end
    render_themes()
    apply_current_theme()
end

local function prev_theme()
    state.current_index = state.current_index - 1
    if state.current_index < 1 then
        state.current_index = #state.themes
    end
    render_themes()
    apply_current_theme()
end

-- ------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------
function M.open(opts)
    opts                 = opts or {}
    local config         = require('colorchoose.config')
    state.opts           = vim.tbl_deep_extend('force', config, opts)

    state.themes         = require('colorchoose.themes').list()
    state.original_theme = vim.g.colors_name
    state.current_index  = 1

    -- Calculate float size and position (centered with margin)
    local ui             = vim.api.nvim_list_uis()[1]
    local width          = math.floor(ui.width * state.opts.width_ratio)
    local height         = math.floor(ui.height * state.opts.height_ratio)
    local row            = math.floor((ui.height - height) / 2)
    local col            = math.floor((ui.width - width) / 2)

    -- Create scratch buffer
    state.buf            = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.buf, 'bufhidden', 'wipe')

    -- Open floating window
    state.win = vim.api.nvim_open_win(state.buf, true, {
        relative  = 'editor',
        width     = width,
        height    = height,
        row       = row,
        col       = col,
        style     = 'minimal',
        border    = state.opts.border, -- 'rounded'
        title     = ' ColorChoose ',
        title_pos = 'center',
    })

    -- Window‑local options
    vim.api.nvim_win_set_option(state.win, 'wrap', false)
    vim.api.nvim_win_set_option(state.win, 'cursorline', true)

    -- Key mappings
    local map = function(mode, lhs, rhs, desc)
        vim.api.nvim_buf_set_keymap(state.buf, mode, lhs, rhs,
            { noremap = true, silent = true, desc = desc })
    end

    map('n', 'j', next_theme, 'Next theme')
    map('n', 'k', prev_theme, 'Previous theme')
    map('n', '<CR>', apply_current_theme, 'Apply theme')
    map('n', 'p', function()
        switch_screen(state.screen == 'themes' and 'preview' or 'themes')
    end, 'Toggle preview')
    map('n', 'q', close, 'Close')
    map('n', '<Esc>', close, 'Close')
    map('n', '?', function()
        vim.notify('j/k: navigate • Enter: apply • p: preview • q: quit',
            vim.log.levels.INFO)
    end, 'Help')

    -- Initial screen
    switch_screen('themes')
end

return M
