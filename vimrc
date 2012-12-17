runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" disable arrow keys
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

set expandtab shiftround tabstop=4 shiftwidth=4 softtabstop=4

let mapleader='\'
nnoremap <leader>v :edit $MYVIMRC<cr>

if has('autocmd')
    filetype on
    autocmd! FileType make setlocal noexpandtab
    autocmd! FileType proto setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd! BufWritePost $MYVIMRC source $MYVIMRC
    "autocmd! CursorHold * checktime
endif

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis

" Thanks to c++11 lambdas; see :help ft-c-syntax
let c_no_curly_error = 1

command! -nargs=? SvnBlame call s:svnBlame(<args>)

function! s:svnBlame(...)
    let cur_line = line(".")
    setlocal nowrap
    setlocal scrollbind
    15vnew
    setlocal scrollbind
    if a:0 > 0
        exec 'r !svn blame -r ' . a:1 . ' # | awk '"'"'{printf " \%4s  \%-7s\n",$1,$2}'"'"
    else
        r !svn blame # | awk '{printf " \%4s  \%-7s\n",$1,$2}'
    endif
    g/^$/d
    exec "normal " . cur_line . "G"
    syncbind
endfunction
