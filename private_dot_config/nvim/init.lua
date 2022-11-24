-- Plugin source defined in ~/.config/nvim/lua/plugins.lua
require('plugins')

-- vim options
vim.env.PATH = vim.env.VIM_PATH or vim.env.PATH
vim.opt.number = true
vim.opt.syntax = 'on'
vim.opt.autoindent = true
vim.opt.smarttab = true
-- below tabs/spaces configs shouldn't be necessary now because of vim-slueth plugin
--vim.opt.shiftwidth = 2
--vim.opt.expandtab = true
--vim.opt.tabstop = 2
vim.opt.signcolumn = 'yes'
vim.cmd('colorscheme monokai')
vim.g.mapleader = ' '

-- oscyank
vim.g.oscyank_term = 'default' -- make yank work in tmux

-- airline
vim.g.airline_theme = 'molokai'

---- START LSP Config ----
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- Don't spam the LSP
  debounce_text_changes = 1000,
}

require('lspconfig')['clangd'].setup {
  on_attach = on_attach,
  flags = lsp_flags,
}

require('lspconfig')['gopls'].setup {
  cmd = {'gopls', '-remote=auto'},
  on_attach = on_attach,
  flags = lsp_flags,
  init_options = {
    staticcheck = true,
  },
}
---- END LSP Config ----

-- nvim-cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    })
})

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'tf', builtin.find_files, {})
vim.keymap.set('n', 'tg', builtin.live_grep, {})
vim.keymap.set('n', 'tb', builtin.buffers, {})
vim.keymap.set('n', 'th', builtin.help_tags, {})

-- gofmt/goimports
function FormatAndImports(wait_ms)
    vim.lsp.buf.format({timeout_ms = wait_ms})
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end
vim.api.nvim_create_autocmd("BufWritePre", {pattern = "*.go", command = "lua FormatAndImports(3000)"})

-- open file to last viewed line
vim.api.nvim_create_autocmd("BufRead", {pattern = "*", command = [[call setpos(".", getpos("'\""))]]})

