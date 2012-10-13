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
nnoremap <leader>v :e $MYVIMRC<cr>

if has('autocmd')
    filetype on
    autocmd! FileType make setlocal noexpandtab
    autocmd! BufWritePost $MYVIMRC source $MYVIMRC
endif
