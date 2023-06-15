set mouse=a

if exists("g:GuiLoaded")
    " nvim-qt
    if exists(':GuiFont')
        " GuiFont! HackGenNerd Console:h12
        GuiFont! Sarasa Term J Nerd Font:h11
    endif
    if exists(':GuiTabline')
        GuiTabline 0
    endif
    if exists(':GuiPopupmenu')
        GuiPopupmenu 0
    endif
    if exists(':GuiScrollBar')
        GuiScrollBar 0
    endif
    " Right Click Context Menu (Copy-Cut-Paste)
    nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
    inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
    xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
    snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv

elseif exists("g:fvim_loaded")
    " fvim
    set guifont=Sarasa\ Term\ J\ Nerd\ Font:h16
    nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
    nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
    nnoremap <A-CR> :FVimToggleFullScreen<CR>

    FVimCustomTitleBar v:true
endif

