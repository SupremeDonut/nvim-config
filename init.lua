vim.loader.enable()

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.expandtab = true
vim.o.title = true
vim.o.titlelen = 0
vim.o.titlestring = 'nvim %{expand("%:p:t")}'

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>cd', '<cmd>cd %:p:h<CR>:pwd<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore cursor position on open, if possible
local function table_contains(t, e)
  for _, v in pairs(t) do
    if v == e then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd('BufRead', {
  callback = function(args)
    local ignored_fts = { 'gitrebase', 'gitcommit', 'hgcommit', 'svn', 'xxd' }
    vim.api.nvim_create_autocmd('BufWinEnter', {
      once = true,
      buffer = args.buf,
      callback = function()
        local ft = vim.bo[args.buf].filetype
        local row = vim.api.nvim_buf_get_mark(args.buf, '"')[1]
        if not table_contains(ignored_fts, ft) and row > 0 and row <= vim.api.nvim_buf_line_count(args.buf) then
          vim.api.nvim_feedkeys([[g`"]], 'nx', false)
        end
      end,
    })
  end,
})

-- mini.nvim is always loaded (including in vscode)
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.move').setup()
if not vim.g.vscode then
  require('mini.pairs').setup()
end

if vim.g.vscode then
  return
end

-- Hijack directory opens with telescope file_browser
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if vim.fn.isdirectory(bufname) ~= 1 then
      return
    end
    -- Schedule so the buffer is fully set up before we replace it
    vim.schedule(function()
      vim.pack.add({
        'https://github.com/nvim-telescope/telescope.nvim',
        'https://github.com/nvim-telescope/telescope-file-browser.nvim',
      })
      require('telescope').load_extension 'file_browser'
      -- Wipe the directory buffer
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
      require('telescope').extensions.file_browser.file_browser {
        path = bufname,
        respect_gitignore = false,
        hidden = true,
      }
    end)
  end,
})

-- PackChanged hooks for plugins with build steps
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    local dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. name

    if name == 'nvim-treesitter' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    elseif name == 'telescope-fzf-native.nvim' then
      if vim.fn.executable('make') == 1 then
        vim.fn.system({ 'make', '-C', dir })
      end
    elseif name == 'markdown-preview.nvim' then
      vim.fn.system({ 'yarn', 'install', '--cwd', dir .. '/app' })
    elseif name == 'LuaSnip' then
      vim.fn.system({ 'make', 'install_jsregexp', '-C', dir })
    end
  end,
})

-- INFO: All plugins (eagerly loaded)
vim.pack.add({
  -- theming
  'https://github.com/catppuccin/nvim',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  -- git
  'https://github.com/lewis6991/gitsigns.nvim',
  -- lsp and completion
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/folke/lazydev.nvim',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') },
  -- treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',
  -- markdown and notes
  'https://github.com/OXY2DEV/markview.nvim',
  -- utilities
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
})

-- INFO: Theming configuration

-- catppuccin
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    -- adds transparency to a bunch of elements
    vim.cmd [[hi Normal guibg=NONE]]
    vim.cmd [[hi NormalNC guibg=NONE]]
    vim.cmd [[hi NormalFloat guibg=NONE]]
    vim.cmd [[hi FloatBorder guibg=NONE]]
    vim.cmd [[hi SignColumn guibg=NONE]]
    vim.cmd [[hi LineNr guibg=NONE]]
    vim.cmd [[hi LspInlayHint guibg=NONE]]
  end,
})
require('catppuccin').setup {
  transparent_background = true,
}
vim.cmd.colorscheme 'catppuccin-mocha'

-- snacks dashboard
local projectpath = vim.fn.stdpath 'cache' .. '/project_history'

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    local projects = {}
    for _, client in pairs(vim.lsp.get_clients() or {}) do
      local root_dir = client.config.root_dir
      if root_dir and not vim.tbl_contains(projects, root_dir) then
        table.insert(projects, root_dir)
      end
      for _, folder in pairs(client.workspace_folders or {}) do
        if not vim.tbl_contains(projects, folder.name) then
          table.insert(projects, folder.name)
        end
      end
    end

    if #projects == 0 then
      return
    end

    if not vim.uv.fs_stat(projectpath) then
      local fd = assert(vim.uv.fs_open(projectpath, 'w', 384))
      vim.uv.fs_close(fd)
    end
    local fd = assert(vim.uv.fs_open(projectpath, 'r+', 384))
    local stat = assert(vim.uv.fs_fstat(fd))
    local data = assert(vim.uv.fs_read(fd, stat.size, 0))
    local before = assert(load(data))
    local plist = before()

    if plist and #plist > 10 then
      plist = vim.list_slice(plist, 10)
    end

    plist = vim.tbl_filter(function(k)
      return not vim.tbl_contains(projects, k)
    end, plist or {})

    for i = #projects, 1, -1 do
      table.insert(plist, 1, projects[i])
    end
    local dump = 'return ' .. vim.inspect(plist)
    assert(vim.uv.fs_write(fd, dump, 0))
    assert(vim.uv.fs_ftruncate(fd, #dump))
    vim.uv.fs_close(fd)
  end,
})
vim.api.nvim_create_user_command('Dashboard', function()
  require('snacks.dashboard').open()
end, {})

require('snacks').setup {
  dashboard = {
    preset = {
      header = [[
 ███▄    █  ▓█████ ▒█████   ██▒   █▓  ██▓ ███▄ ▄███▓
 ██ ▀█   █  ▓█   ▀▒██▒  ██▒▓██░   █▒▒▓██▒▓██▒▀█▀ ██▒
▓██  ▀█ ██▒ ▒███  ▒██░  ██▒ ▓██  █▒░▒▒██▒▓██    ▓██░
▓██▒  ▐▌██▒ ▒▓█  ▄▒██   ██░  ▒██ █░░░░██░▒██    ▒██
▒██░   ▓██░▒░▒████░ ████▓▒░   ▒▀█░  ░░██░▒██▒   ░██▒
░ ▒░   ▒ ▒ ░░░ ▒░ ░ ▒░▒░▒░    ░ ▐░   ░▓  ░ ▒░   ░  ░
░ ░░   ░ ▒░░ ░ ░    ░ ▒ ▒░    ░ ░░  ░ ▒ ░░  ░      ░
   ░   ░ ░     ░  ░ ░ ░ ▒        ░  ░ ▒ ░░      ░
         ░ ░   ░      ░ ░        ░    ░         ░
      ]],
      keys = {
        {
          icon = ' ',
          key = 'f',
          desc = 'Find File',
          action = ":lua Snacks.dashboard.pick('files')",
        },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        {
          icon = ' ',
          key = 'r',
          desc = 'Recent Files',
          action = ":lua Snacks.dashboard.pick('oldfiles')",
        },
        {
          icon = ' ',
          key = 'c',
          desc = 'Config',
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
        },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = function()
      local list = {
        { section = 'header' },
        { icon = ' ', title = 'Actions', section = 'keys', indent = 2, padding = 1 },
        {
          icon = ' ',
          title = 'Recent Files',
          section = 'recent_files',
          indent = 2,
          padding = 1,
          limit = 7,
        },
        {
          icon = ' ',
          title = 'Projects',
          section = 'projects',
          indent = 2,
          padding = 1,
          dirs = function()
            local ok, pl = pcall(dofile, projectpath)
            if not ok or type(pl) ~= 'table' then
              pl = {}
            end
            return pl
          end,
          action = function(dir)
            vim.fn.chdir(dir)
            require('snacks.dashboard').pick()
          end,
        },
        { section = 'startup', icon = '' },
      }
      return list
    end,
  },
}

-- lualine
local function trunc(trunc_width, trunc_char, hide_width)
  return function(str)
    local width = vim.o.columns
    if width <= hide_width then
      return ''
    elseif width <= trunc_width then
      return str:sub(1, trunc_char)
    end
    return str
  end
end

require('lualine').setup {
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = trunc(100, 1, 0),
      },
    },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      {
        'filename',
        path = 1,
        fmt = function(name)
          local separator = package.config:sub(1, 1)
          local parts = vim.split(name, separator)
          if #parts == 1 then
            return name
          end

          local filename = table.remove(parts)
          local dir = table.concat(parts, separator)
          return string.format('%%#Comment#%s%s%%#Normal#%s', dir, separator, filename)
        end,
      },
    },
    lualine_x = {
      {
        'filetype',
        icon_only = false,
        cond = function()
          return vim.o.columns > 80
        end,
      },
      {
        'filetype',
        icon_only = true,
        cond = function()
          return vim.o.columns <= 80
        end,
      },
    },
    lualine_y = {
      { 'progress' },
      { 'filesize', fmt = trunc(0, 0, 110) },
    },
  },
}

-- INFO: Git configuration
require('gitsigns').setup {
  signcolumn = false,
  numhl = true,
  current_line_blame = true,
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        ---@diagnostic disable-next-line: param-type-mismatch
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        ---@diagnostic disable-next-line: param-type-mismatch
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })

    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk_inline, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      ---@diagnostic disable-next-line: param-type-mismatch
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })

    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
  end,
}

-- INFO: LSP configuration
require('fidget').setup {
  notification = { window = { border = 'rounded', winblend = 0 } },
}

require('mason').setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
    map('<leader>cw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace Symols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>ci', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle [I]nlay Hints')
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = { current_line = false },
  virtual_lines = { current_line = true },
  underline = { severity = vim.diagnostic.severity.ERROR },
}

local ensure_installed = {
  'stylua',
  'lua-language-server',
  'prettier',
  'debugpy',
  'pyright',
  'ruff',
  'jdtls',
  'rust-analyzer',
  'clangd',
}

local installed_package_names = require('mason-registry').get_installed_package_names()
for _, v in ipairs(ensure_installed) do
  if not vim.tbl_contains(installed_package_names, v) then
    vim.cmd(':MasonInstall ' .. v)
  end
end

local installed_packages = require('mason-registry').get_installed_packages()
local installed_lsp_names = vim.iter(installed_packages):fold({}, function(acc, pack)
  table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
  return acc
end)

vim.lsp.enable(installed_lsp_names)

-- INFO: Completion (blink.cmp)
require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = 'rounded' } },
    menu = {
      border = 'rounded',
      auto_show = true,
      winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
      draw = { treesitter = { 'lsp' } },
    },
    ghost_text = { enabled = true },
  },

  cmdline = {
    completion = { menu = { auto_show = true } },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'lazydev' },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
    },
  },

  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}

-- INFO: Treesitter
local ensureInstalled = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}
local alreadyInstalled = require('nvim-treesitter.config').get_installed()
local parsersToInstall = vim
  .iter(ensureInstalled)
  :filter(function(parser)
    return not vim.tbl_contains(alreadyInstalled, parser)
  end)
  :totable()
require('nvim-treesitter').install(parsersToInstall)
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- INFO: Markdown and notes
local presets = require 'markview.presets'
require('markview').setup {
  experimental = { check_rtp_message = false },
  markdown = { tables = presets.tables.single },
  typst = { enable = false },
}

-- INFO: Utilities
require('guess-indent').setup {}

require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },

  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>f', group = '[F]ind' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>r', group = '[R]un' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>w', group = '[W]orkspace' },
  },
}

require('todo-comments').setup { signs = false }

-- INFO: Lazy-loaded plugins (deferred after startup)
vim.schedule(function()
  -- Telescope and dependencies
  vim.pack.add({
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    'https://github.com/nvim-telescope/telescope-ui-select.nvim',
    'https://github.com/nvim-telescope/telescope-file-browser.nvim',
    -- indent guides
    'https://github.com/lukas-reineke/indent-blankline.nvim',
    -- folding
    'https://github.com/chrisgrieser/nvim-origami',
    -- formatting
    'https://github.com/stevearc/conform.nvim',
    -- code runner
    'https://github.com/CRAG666/code_runner.nvim',
  })

  -- Telescope setup
  require('telescope').setup {
    defaults = {
      sorting_strategy = 'ascending',
      layout_config = {
        prompt_position = 'top',
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
        '--glob',
        '!**/.git/*',
      },
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown(),
      },
      file_browser = {
        hijack_netrw = true,
        hidden = {
          file_browser = true,
          folder_browser = true,
        },
      },
    },
  }

  require('telescope').load_extension 'fzf'
  require('telescope').load_extension 'ui-select'
  require('telescope').load_extension 'file_browser'

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
  vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch existing [B]uffers' })

  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })

  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope file_browser<CR>', { desc = 'Telescope [F]ile [B]rowser' })

  local custom_pickers = require 'custom_pickers'
  vim.keymap.set('n', '<leader>fe', custom_pickers.emoji_picker, { desc = '[F]ind [E]mojis' })
  vim.keymap.set('n', '<leader>fm', custom_pickers.math_picker, { desc = '[F]ind [M]ath Symbols' })
  vim.keymap.set('n', '<leader>fn', custom_pickers.nerd_picker, { desc = '[F]ind [N]erd Font Symbols' })
  vim.keymap.set('n', '<leader>ft', custom_pickers.typst_picker, { desc = '[F]ind [T]ypst Symbols' })

  -- indent-blankline
  require('ibl').setup { indent = { char = '▏' }, exclude = { filetypes = { 'dashboard' } } }

  -- origami (folding)
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  require('origami').setup { foldtext = { lineCount = { template = '  󰘖 %d  ' } } }

  -- conform (formatting)
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      markdown = { 'prettier' },
    },
  }

  vim.keymap.set('', '<leader>f', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[F]ormat buffer' })

  -- code runner
  require('code_runner').setup { filetype = { python = 'python $fileName' } }
  vim.keymap.set('n', '<leader>rr', ':RunCode<CR>', { desc = 'Run Code' })
  vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { desc = 'Run File' })
  vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { desc = 'Run Project' })
  vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { desc = 'Close Runner' })
end)

-- INFO: Filetype-triggered plugins
vim.api.nvim_create_autocmd('BufReadPre', {
  once = true,
  callback = function()
    vim.pack.add({ 'https://github.com/catgoose/nvim-colorizer.lua' })
    require('colorizer').setup {
      lazy_load = true,
      user_default_options = {
        names = false,
        css = true,
      },
    }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  once = true,
  callback = function()
    vim.pack.add({ 'https://github.com/iamcco/markdown-preview.nvim' })
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typst',
  once = true,
  callback = function()
    vim.pack.add({ { src = 'https://github.com/chomosuke/typst-preview.nvim', version = vim.version.range('1.x') } })
    require('typst-preview').setup {}
    vim.api.nvim_create_user_command('TypstCompile', function(opts)
      vim.cmd('!typst compile %:p ' .. opts.args)
    end, { nargs = '?' })
  end,
})

-- INFO: AI stuff
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  callback = function()
    vim.pack.add({ 'https://github.com/zbirenbaum/copilot.lua' })
    require 'copilot_grimoire'
  end,
})

-- vim: ts=2 sts=2 sw=2 et
