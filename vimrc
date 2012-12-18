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
