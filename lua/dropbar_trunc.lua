-- since i'm using the statusline, i'm changing the truncation to be 60% of the win width
local bar = require 'dropbar.bar'
local configs = require 'dropbar.configs'
local sources = require 'dropbar.sources'
local utils = require 'dropbar.utils'

function bar.dropbar_t:truncate()
  if not self.win or not vim.api.nvim_win_is_valid(self.win) then
    self:del()
    return
  end
  local win_width = math.ceil(vim.api.nvim_win_get_width(self.win) * 0.6)
  local len = self:displaywidth()
  local delta = len - win_width
  for _, component in ipairs(self.components) do
    if delta <= 0 then
      break
    end
    local name_len = vim.fn.strdisplaywidth(component.name)
    local min_len = vim.fn.strdisplaywidth(vim.fn.strcharpart(component.name, 0, component.min_width or 1) .. self.extends.icon)
    if name_len > min_len then
      component.name = vim.fn.strcharpart(component.name, 0, math.max(component.min_width or 1, name_len - delta - 1)) .. self.extends.icon
      delta = delta - name_len + vim.fn.strdisplaywidth(component.name)
    end
  end

  -- Return if dropbar already fits in the window
  -- or there's only one or less symbol in dropbar (cannot truncate)
  if delta <= 0 or #self.components <= 1 then
    return
  end

  -- Consider replacing symbols at the start of the winbar with an extends sign
  local sym_extends = bar.dropbar_symbol_t:new {
    icon = configs.opts.icons.ui.bar.extends,
    icon_hl = 'WinBarIconUIExtends',
    on_click = false,
    bar = self,
  }
  local extends_width = sym_extends:displaywidth()
  local sep_width = self.separator:displaywidth()
  local sym_first = self.components[1]
  local wdiff = extends_width - sym_first:displaywidth()
  -- Extends width larger than the first symbol, removing the
  -- first symbol will not help
  if wdiff >= 0 then
    return
  end
  -- Replace the first symbol with the extends sign and update delta
  self.components[1] = sym_extends
  delta = delta + wdiff
  sym_first:del()
  -- Keep removing symbols from the start, notice that self.components[1] is
  -- the extends symbol
  while delta > 0 and #self.components > 1 do
    local sym_remove = self.components[2]
    table.remove(self.components, 2)
    delta = delta - sym_remove:displaywidth() - sep_width
    sym_remove:del()
  end
  -- Update bar_idx of each symbol
  for i, component in ipairs(self.components) do
    component.bar_idx = i
  end
end
local function dropbar_sources(buf, _)
  if vim.bo[buf].ft == 'markdown' then
    return {
      sources.markdown,
    }
  end
  if vim.bo[buf].buftype == 'terminal' then
    return {
      sources.terminal,
    }
  end
  return {
    utils.source.fallback {
      sources.lsp,
      sources.treesitter,
    },
  }
end

return {
  dropbar_sources = dropbar_sources,
}
