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

let mapleader='\'
nnoremap <leader>v :edit $MYVIMRC<cr>

nnoremap <leader>d :execute 'Gtags' expand("<cword>")<cr>
nnoremap <leader>r :execute 'Gtags -r' expand("<cword>")<cr>
nnoremap <leader>g :execute 'Gtags -g' expand("<cword>")<cr>

if has('autocmd')
    filetype on
    autocmd! FileType make setlocal noexpandtab
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
