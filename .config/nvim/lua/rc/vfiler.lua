local action = require "vfiler/action"
local vf = require "vfiler"

require("vfiler/config").setup {
  options = {
    columns = "indent,devicons,name,mode,time",
    auto_cd = false,
    auto_resize = true,
    keep = false,
    layout = "floating",
    width = math.floor(vim.o.columns * 0.7),
    height = math.floor(vim.o.lines * 0.7),
    show_hidden_files = true,
    header = true,
    find_file = true,
    preview = {
      height = math.floor(vim.o.lines * 0.7),
    },
  },
  mappings = {
    ["."] = action.toggle_show_hidden,
    ["<BS>"] = action.change_to_parent,
    ["<C-l>"] = action.reload,
    ["<C-p>"] = action.toggle_auto_preview,
    ["<C-r>"] = action.sync_with_current_filer,
    ["<C-s>"] = action.toggle_sort,
    ["<CR>"] = action.open,
    ["<S-Space>"] = function(vfiler, context, view)
      action.toggle_select(vfiler, context, view)
      action.move_cursor_up(vfiler, context, view)
    end,
    ["<Space>"] = function(vfiler, context, view)
      action.toggle_select(vfiler, context, view)
      action.move_cursor_down(vfiler, context, view)
    end,
    ["<Tab>"] = action.switch_to_filer,
    ["~"] = action.jump_to_home,
    ["*"] = action.toggle_select_all,
    ["\\"] = action.jump_to_root,
    ["cc"] = action.copy_to_filer,
    ["dd"] = action.delete,
    ["gg"] = action.move_cursor_top,
    ["b"] = action.list_bookmark,
    ["h"] = action.close_tree_or_cd,
    ["j"] = action.loop_cursor_down,
    ["k"] = action.loop_cursor_up,
    ["l"] = function(vfiler, context, view)
      local api = require "vfiler/actions/api"
      local item = view:get_item()
      if item.type == "directory" then
        api.cd(vfiler, context, view, item.path)
      else
        api.open_file(vfiler, context, view, item.path)
      end
    end,
    ["mm"] = action.move_to_filer,
    ["o"] = action.open_tree,
    ["p"] = action.toggle_preview,
    ["q"] = action.quit,
    ["r"] = action.rename,
    ["s"] = action.open_by_split,
    ["t"] = action.open_by_tabpage,
    ["v"] = action.open_by_vsplit,
    ["x"] = action.execute_file,
    ["yy"] = action.yank_path,
    ["B"] = action.add_bookmark,
    ["C"] = action.copy,
    ["D"] = action.delete,
    ["G"] = action.move_cursor_bottom,
    ["J"] = action.jump_to_directory,
    ["K"] = action.new_directory,
    ["L"] = action.switch_to_drive,
    ["M"] = action.move,
    ["N"] = action.new_file,
    ["P"] = action.paste,
    ["S"] = action.change_sort,
    ["U"] = action.clear_selected_all,
    ["YY"] = action.yank_name,
  },
  events = {
    my_vfiler_augroup = {
      -- BufEnter = function(vfiler, context, view) end,
    },
  },
}
local function my_vfiler_start()
  local path
  local bufname = vim.fn.bufname()
  if vim.fn.filereadable(bufname) ~= 0 then
    path = vim.fn.fnamemodify(bufname, ":h")
  else
    path = vim.loop.cwd()
  end
  vf.start(path)
  -- vim.cmd [[ doautocmd BufEnter ]]
end
vim.api.nvim_create_user_command("MyVFilerStart", my_vfiler_start, {})
