runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

if has("win32")
  set nocompatible
  source $VIMRUNTIME/vimrc_example.vim

  colorscheme desert
endif

" disable arrow keys
noremap <F1> <nop>
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" show hidden buffers
set hidden

" easy buffer management
set wildmenu
set wildmode=list:full

set winminheight=0

set expandtab shiftround tabstop=4 shiftwidth=4 softtabstop=4

set hlsearch

syntax on

let mapleader='\'
nnoremap <leader>v :edit $MYVIMRC<cr>

nnoremap <leader>d :execute 'Gtags' expand("<cword>")<cr>
nnoremap <leader>r :execute 'Gtags -r' expand("<cword>")<cr>
nnoremap <leader>g :execute 'Gtags -g' expand("<cword>")<cr>

" find in column
noremap <leader>f :execute 'echo search(''\%' . virtcol('.') . 'c' . nr2char(getchar()) . "', 'W')"<cr>
noremap <leader>F :execute 'echo search(''\%' . virtcol('.') . 'c' . nr2char(getchar()) . "', 'Wb')"<cr>

" the current time
nnoremap <leader>t "=substitute(strftime("%H:%M"), "^0\\+\\(:0\\?\\)\\?", "", "")<cr>P
vnoremap <leader>t "=substitute(strftime("%H:%M"), "^0\\+\\(:0\\?\\)\\?", "", "")<cr>P
nnoremap <leader>T "=substitute(strftime("%H:%M:%S"), "^0\\+\\(:0\\?\\)\\?", "", "")<cr>P
vnoremap <leader>T "=substitute(strftime("%H:%M:%S"), "^0\\+\\(:0\\?\\)\\?", "", "")<cr>P

function! RenumID(idroot, offset, ...)
    let l:start = a:0 >= 1 ? a:1 : 0
    " for \= see :help sub-replace-expression
    exe "s/\\(".a:idroot."\\)\\(\\d\\+\\)/\\=submatch(1).(submatch(2)+(submatch(2)<".l:start."?0:".a:offset."))/g"
endfunction

function! PushAllRegisters()
    let l:registers = "\"0123456789abcdefghijklmnopqrstuvwxyz-*+/"
    let l:result = {"regs": {}, "type": {}, "names": l:registers}
    for i in range(strlen(l:result["names"]))
        let l:name_i = strcharpart(l:result["names"], i, 1)
        let l:result["regs"][l:name_i] = getreg(l:name_i)
        let l:result["type"][l:name_i] = getregtype(l:name_i)
    endfor
    return l:result
endfunction

function! PopAllRegisters(stashed_registers)
    for i in range(strlen(a:stashed_registers["names"]))
        let l:name_i = strcharpart(a:stashed_registers["names"], i, 1)
        let l:regs_i = a:stashed_registers["regs"][l:name_i]
        let l:type_i = a:stashed_registers["type"][l:name_i]
        call setreg(l:name_i, l:regs_i, l:type_i)
    endfor
endfunction

function! IndentBrace(startbrace)
    let l:line1 = line('.')
    let l:col1  = col('.')
    let l:curchar = strgetchar(getline(l:line1), l:col1 - 1)
    let l:found = l:curchar == char2nr(a:startbrace)
    if !l:found
        execute "normal! [" . a:startbrace
        let l:line2 = line('.')
        let l:col2  = col('.')
        let l:found = l:line1 != l:line2 || l:col1 != l:col2
    endif
    if l:found
        execute "normal! i(l%a)%"
    endif
endfunction

function! OutdentBrace(startbrace)
    execute "normal [" . a:startbrace
    let line1 = line('.')
    let l:col1  = col('.')
    let l:curchar = strgetchar(getline(l:line1), l:col1 - 1)
    let l:found = l:curchar == char2nr(a:startbrace)
    if l:found
        let l:old_reg = PushAllRegisters()
        let l:autoindent = &autoindent
        execute "normal! yi" . a:startbrace
        let l:contents = @0
        execute "normal [" . a:startbrace
        set noautoindent
        " this has a bug, in that the format options mess with l:contents
        " (e.g., a comment will comment out the whole block)
        execute "normal! c%" . l:contents
        let &autoindent = l:autoindent
        call PopAllRegisters(l:old_reg)
    endif
endfunction

nnoremap <leader>[{ :call IndentBrace('{')<cr>
nnoremap <leader>[( :call IndentBrace('(')<cr>
nnoremap <leader>]} :call OutdentBrace('{')<cr>
nnoremap <leader>]) :call OutdentBrace('(')<cr>

if has('autocmd')
    filetype plugin indent on
    autocmd! FileType make setlocal noexpandtab
    autocmd! FileType scheme setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType lua setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType proto setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType sql setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType xml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType xsd setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType xslt setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! FileType svn setlocal textwidth=80 formatoptions+=a
    autocmd! FileType gitcommit setlocal textwidth=80 formatoptions+=a
    autocmd! FileType tex setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! BufWritePost $MYVIMRC source $MYVIMRC
    "autocmd! CursorHold * checktime
endif

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" Thanks to c++11 lambdas; see :help ft-c-syntax
let c_no_curly_error = 1

" remove comment leaders on join and add them in insert mode
set formatoptions+=jr

" treat leading zeros as decimal for ctrl-A/ctrl-X
set nrformats-=octal

" Printers, found with lpstat -a

set printoptions+=syntax:y,paper:letter,duplex:off,wrap:n
