---@class Stack.Keybinds
---@field lhs string Left-hand side of the mapping (e.g., "q")
---@field rhs string Right-hand side of the mapping (e.g., ":q<CR>")
---@field mode? string Mode (default "n")
---@field desc? string Description for documentation
---@field opts? table Additional options for nvim_set_keymap

---@class Stack.w
---@field width integer
---@field height integer
---@field border ("none"|"single"|"double"|"rounded"|"solid"|"shadow")
---@field relative boolean
---@field split ("left"|"right"|"above"|"below")
---@field style string
---@field minimal boolean
---@field position ("left"|"right"|"top"|"bottom"|"center"|"notify")
---@field split_type? ("horizontal"|"vertical"|nil)
---@field title string
---@field title_pos ("left"|"center"|"right")
---@field footer string
---@field footer_pos ("left"|"center"|"right")
---@field focusable boolean

---@class Stack.b
---@field buflisted boolean
---@field buftype string
---@field scratch boolean
---
---@class Stack.Keymap.opts
---@field noremap boolean
---@field silent boolean

---@class Stack.HighlightSpec
---@field group string   # Highlight group name (e.g., "StackHeader")
---@field line integer   # 0-based line index (matches nvim API convention)
---@field start_col integer # 0-based starting column (inclusive)
---@field end_col integer   # 0-based ending column (exclusive)

---@class Stack.Win.Content
---@field lines string[]            # Array of text lines to display
---@field highlights Stack.HighlightSpec[] # Array of highlight specifications

---@class Stack.Win.Config
---@field w Stack.w
---@field b Stack.b
---@field keybinds table<Stack.Keybinds>
---@field keymap_opts table
---@field content Stack.Win.Content

return {}
