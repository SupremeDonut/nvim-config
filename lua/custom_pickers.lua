local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local entry_display = require 'telescope.pickers.entry_display'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local displayer = entry_display.create {
  separator = ' ',
  items = {
    { width = 10 },
    { width = 30 },
    { remaining = true },
  },
}

local base_picker = function(file, title, use_desc)
  return function()
    local path = vim.fn.stdpath 'config' .. '/data/' .. file
    local chars = vim.fn.json_decode(vim.fn.readfile(path))
    local opts = { temp__scrolling_limit = 500 }
    pickers
      .new(opts, {
        prompt_title = title,
        finder = finders.new_table {
          results = chars,
          entry_maker = function(entry)
            return {
              value = entry[1],
              category = entry[2],
              desc = entry[3],
              ordinal = entry[2] .. ' ' .. entry[3],
              display = function(e)
                return displayer { e.value, e.category, e.desc }
              end,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if use_desc then
              vim.fn.setreg('+', selection.desc)
            else
              vim.fn.setreg('+', selection.value)
            end
            actions.close(prompt_bufnr)
          end)
          return true
        end,
        layout_config = {
          width = 0.5,
          height = 0.5,
        },
      })
      :find()
  end
end

return {
  math_picker = base_picker('math.json', 'Math Symbols'),
  nerd_picker = base_picker('nerd.json', 'Nerd Font Icons'),
  emoji_picker = base_picker('emoji.json', 'Emojis'),
  typst_picker = base_picker('typst.json', 'Typst Symbols', true),
}
