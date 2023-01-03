return {
  "hrsh7th/vim-searchx",
  config = function()
    local opts = { noremap = true }
    vim.keymap.set("n", "?", "<Cmd>call searchx#start({ 'dir': 0 })<CR>", opts)
    vim.keymap.set("n", "/", "<Cmd>call searchx#start({ 'dir': 1 })<CR>", opts)
    vim.keymap.set("x", "?", "<Cmd>call searchx#start({ 'dir': 0 })<CR>", opts)
    vim.keymap.set("x", "/", "<Cmd>call searchx#start({ 'dir': 1 })<CR>", opts)
    -- vim.keymap.set("c", ";", "<Cmd>call searchx#select()<CR>", opts)
    vim.keymap.set("n", "N", "<Cmd>call searchx#prev_dir()<CR>", opts)
    vim.keymap.set("n", "n", "<Cmd>call searchx#next_dir()<CR>", opts)
    vim.keymap.set("c", "<C-p>", "<Cmd>call searchx#prev()<CR>", opts)
    vim.keymap.set("c", "<C-n>", "<Cmd>call searchx#next()<CR>", opts)
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
    { "n", mode = { "n", "x" } },
    { "N", mode = { "n", "x" } },
    { "<C-p>", mode = { "c" } },
    { "<C-n>", mode = { "c" } },
  },
}