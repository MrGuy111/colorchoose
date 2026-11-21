-- code/sample.lua
-- A simple file used to preview colorschemes.

local function greet(name)
    print("Hello, " .. name .. "!")
end

greet("Neovim")

-- Demonstrate different syntax elements
local numbers = { 1, 2, 3, 4, 5 }
local total = 0

for _, n in ipairs(numbers) do
    total = total + n
end

print("Total: " .. total)

-- Comments, strings, keywords, numbers, etc. are all highlighted.
