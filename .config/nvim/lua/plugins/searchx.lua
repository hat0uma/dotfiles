return {
  "hrsh7th/vim-searchx",
  config = function()
    local function searchx_start(searchx_opts)
      return function()
        local scrolloff = vim.o.scrolloff
        vim.o.scrolloff = 0
        vim.fn["searchx#start"](searchx_opts)
        vim.o.scrolloff = scrolloff
      end
    end

    local key_opts = { noremap = true }
    vim.keymap.set({ "n", "x" }, "?", searchx_start { dir = 0 }, key_opts)
    vim.keymap.set({ "n", "x" }, "/", searchx_start { dir = 1 }, key_opts)
    -- vim.keymap.set({ "n", "x" }, "<leader><leader>", searchx_start { dir = 1 }, key_opts)
    -- vim.keymap.set("c", ";", "<Cmd>call searchx#select()<CR>", opts)
    vim.keymap.set("n", "N", "<Cmd>call searchx#prev_dir()<CR>", key_opts)
    vim.keymap.set("n", "n", "<Cmd>call searchx#next_dir()<CR>", key_opts)
    vim.keymap.set("c", "<C-p>", "<Cmd>call searchx#prev()<CR>", key_opts)
    vim.keymap.set("c", "<C-n>", "<Cmd>call searchx#next()<CR>", key_opts)
    vim.g.searchx = {
      auto_accept = true,
      scrolloff = 0,
      scrolltime = 0,
      nohlsearch = { jump = true },
      markers = vim.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", ""),
    }
    vim.cmd [[
        " Convert search pattern.
        function g:searchx.convert(input) abort
          if a:input !~# '\k'
            return '\V' .. a:input
          endif
          return a:input[0] .. substitute(a:input[1:], '\\\@<! ', '.\\{-}', 'g')
        endfunction
      ]]
  end,
  keys = {
    { "?", mode = { "n", "x" } },
    { "/", mode = { "n", "x" } },
    -- { "<leader><leader>", mode = { "n", "x" } },
    { "n", mode = { "n", "x" } },
    { "N", mode = { "n", "x" } },
  },
}
