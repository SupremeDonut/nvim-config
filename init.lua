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
vim.o.signcolumn = 'yes'
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

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- INFO: Theming stuff
  {
    'folke/snacks.nvim',
    opts = {
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
              icon = ' ',
              key = 'f',
              desc = 'Find File',
              action = ":lua Snacks.dashboard.pick('files')",
            },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            -- { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            {
              icon = ' ',
              key = 'r',
              desc = 'Recent Files',
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = ' ',
              key = 'c',
              desc = 'Config',
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            -- { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            {
              icon = '󰒲 ',
              key = 'l',
              desc = 'Lazy',
              action = ':Lazy',
              enabled = package.loaded.lazy ~= nil,
            },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        sections = function()
          local list = {
            { section = 'header' },
            { icon = ' ', title = 'Actions', section = 'keys', indent = 2, padding = 1 },
            {
              icon = ' ',
              title = 'Recent Files',
              section = 'recent_files',
              indent = 2,
              padding = 1,
              limit = 7,
            },
            {
              icon = ' ',
              title = 'Projects',
              section = 'projects',
              indent = 2,
              padding = 1,
              dirs = function()
                local projectpath = vim.fn.stdpath 'cache' .. '/project_history'
                local ok, plist = pcall(dofile, projectpath)
                if not ok or type(plist) ~= 'table' then
                  plist = {}
                end
                return plist
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
    },
    init = function()
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
          local before = assert(loadstring(data))
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
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    opts = { indent = { char = '▏' }, exclude = { filetypes = { 'dashboard' } } },
  },
  'AhmedAbdulrahman/aylin.vim',
  'webhooked/kanso.nvim',
  'ribru17/bamboo.nvim',
  {
    'rose-pine/neovim',
    name = 'rose-pine',
  },
  {
    'catppuccin/nvim',
    priority = 1000,
    opts = {
      transparent_background = true,
    },
    init = function()
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
        end,
      })
    end,
    config = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
      -- vim.cmd.colorscheme 'rose-pine-moon'
    end,
  },
  {
    'chrisgrieser/nvim-origami',
    event = 'VeryLazy',
    opts = { foldtext = { lineCount = { template = '  󰘖 %d  ' } } },
    init = function()
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
    end,
  },
  -- INFO: Telescope stuff
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
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
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
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
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
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
      vim.keymap.set('n', '<leader>fm', custom_pickers.math_picker, { desc = '[F]ind [M]ath Symbols' })
      vim.keymap.set('n', '<leader>fn', custom_pickers.nerd_picker, { desc = '[F]ind [N]erd Font Symbols' })
      vim.keymap.set('n', '<leader>fe', custom_pickers.emoji_picker, { desc = '[F]ind [E]mojis' })
      vim.keymap.set('n', '<leader>ft', custom_pickers.typst_picker, { desc = '[F]ind [T]ypst Symbols' })
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      builtin_marks = { "'", '"', '^', '.', '<', '>', '[', ']' },
      sign_priority = { lower = 2, upper = 3, builtin = 1, bookmark = 4 },
    },
  },
  -- INFO: Treesitter stuff
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
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
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  {
    'Bekaboo/dropbar.nvim',
    config = function()
      local dropbar_trunc = require 'dropbar_trunc'
      local dropbar_api = require 'dropbar.api'

      vim.keymap.set({ 'n', 'v' }, '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })

      require('dropbar.configs').set {
        bar = {
          enable = false,
          sources = dropbar_trunc.dropbar_sources,
        },
        symbol = { -- i don't want this functionality
          on_click = function() end,
        },
        sources = {
          path = {
            max_depth = 4,
          },
        },
      }
    end,
  },
  -- INFO: markdown and notes stuff
  -- {
  --   'OXY2DEV/markview.nvim',
  --   config = function()
  --     local presets = require 'markview.presets'
  --     require('markview').setup {
  --       experimental = { check_rtp_message = false },
  --       markdown = { tables = presets.tables.single },
  --       typst = { enable = false },
  --     }
  --   end,
  -- },
  {
    'echaya/neowiki.nvim',
    opts = {
      wiki_dirs = {
        { name = 'School', path = '~/Notes' },
      },
    },
    keys = {
      { '<leader>ww', "<cmd>lua require('neowiki').open_wiki()<cr>", desc = 'Open Wiki' },
      { '<leader>wW', "<cmd>lua require('neowiki').open_wiki_floating()<cr>", desc = 'Open Floating Wiki' },
      { '<leader>wT', "<cmd>lua require('neowiki').open_wiki_new_tab()<cr>", desc = 'Open Wiki in Tab' },
    },
  },
  {
    'chomosuke/typst-preview.nvim',
    lazy = false,
    version = '1.*',
    opts = {},
    config = function()
      vim.api.nvim_create_user_command('TypstCompile', '!typst compile %:p', {})
    end,
  },
  {
    'pxwg/math-conceal.nvim',
    event = 'VeryLazy',
    build = 'make luajit',
    main = 'math-conceal',
    opts = {
      enabled = true,
      conceal = {
        'greek',
        'script',
        'math',
        'font',
        'delim',
        'phy',
      },
      ft = { '*.tex', '*.md', '*.typ' },
    },
  }, -- INFO: git stuff
  {
    'lewis6991/gitsigns.nvim',
    opts = {
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
    },
  },
  -- INFO: lsp and dap stuff
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = { window = { border = 'rounded', winblend = 0 } },
    },
  },
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      'j-hui/fidget.nvim',
      'saghen/blink.cmp',
    },
    config = function()
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
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
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

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'black',
        'prettier',
        'debugpy',
        'ruff',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
      end

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_enable = true,
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
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
    },
  },
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = 'make install_jsregexp',
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
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

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Start/Continue',
      },
      {
        '<F1>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<F2>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<F3>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>b',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>B',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      {
        '<F6>',
        function()
          require('dapui').toggle()
        end,
        desc = 'Debug: See last session result.',
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          'delve',
          'python',
        },
      }
      dapui.setup {}

      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      local breakpoint_icons = vim.g.have_nerd_font
          and {
            Breakpoint = '',
            BreakpointCondition = '',
            BreakpointRejected = '',
            LogPoint = '',
            Stopped = '',
          }
        or {
          Breakpoint = '●',
          BreakpointCondition = '⊜',
          BreakpointRejected = '⊘',
          LogPoint = '◆',
          Stopped = '⭔',
        }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
  -- INFO: other utilities
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
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
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.move').setup()
      require('mini.pairs').setup()
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    init = function()
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
            { 'dropbar and dropbar()' },
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
    end,
  },
  {
    'yorickpeterse/nvim-window',
    opts = {},
    keys = {
      { ',', '<cmd>lua require("nvim-window").pick()<CR>', desc = 'Jump to window' },
    },
  },
  {
    'CRAG666/code_runner.nvim',
    lazy = true,
    opts = { filetype = { python = 'py $fileName' } },
    keys = {
      { '<leader>rr', ':RunCode<CR>', desc = 'Run Code' },
      { '<leader>rf', ':RunFile<CR>', desc = 'Run File' },
      { '<leader>rp', ':RunProject<CR>', desc = 'Run Project' },
      { '<leader>rc', ':RunClose<CR>', desc = 'Close Runner' },
    },
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
