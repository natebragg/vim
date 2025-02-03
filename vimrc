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

function! IndentBrace(startbrace, outertextobj)
    let l:line0 = line('.')
    let l:col0  = col('.')
    execute "normal! v"
    execute "normal! " . a:outertextobj
    let l:linerhs = line('.')
    let l:colrhs  = col('.')
    execute "normal! o"
    let l:linelhs = line('.')
    let l:collhs  = col('.')
    let l:startchar = strgetchar(getline(l:linelhs), l:collhs - 1)
    " succeeds when the cursor's highlighted start
    " and end are different positions
    let l:moved = l:linelhs != l:linerhs || l:collhs != l:colrhs
    " and for sanity's sake the start position cursor
    " points at the start brace character.
    let l:found = l:startchar == char2nr(a:startbrace) && l:moved
    if l:found
        execute "normal! oA)gvovi("
        for i in range(l:linerhs - l:linelhs)
            let l:line = l:linelhs + i + 1
            call setpos('.', [0, l:line, l:collhs, 0])
            let l:curchar = strgetchar(getline(l:line), l:collhs - 1)
            if l:curchar == char2nr(' ')
                execute "normal! I "
            endif
        endfor
    else
      execute "normal! v"
    endif
    " if the line didn't change, to stay on the same
    " character the column must move forward by one
    " to account for the new starting brace
    if l:found && l:line0 == l:linelhs
      let l:col0 = l:col0 + 1
    endif
    call setpos('.', [0, l:line0, l:col0, 0])
endfunction

function! OutdentBrace(startbrace, outertextobj)
    let line0 = line('.')
    let l:col0  = col('.')
    execute "normal v"
    execute "normal " . a:outertextobj
    let l:linerhs = line('.')
    let l:colrhs  = col('.')
    execute "normal! o"
    let l:linelhs = line('.')
    let l:collhs  = col('.')
    let l:curchar = strgetchar(getline(l:linelhs), l:collhs - 1)
    let l:found = l:curchar == char2nr(a:startbrace)
    if l:found
        call setpos('.', [0, l:linerhs, l:colrhs, 0])
        execute "normal! \"_x"
        call setpos('.', [0, l:linelhs, l:collhs, 0])
        execute "normal! \"_x"
        for i in range(l:linerhs - l:linelhs)
            let l:line = l:linelhs + i + 1
            call setpos('.', [0, l:line, l:collhs, 0])
            let l:curchar = strgetchar(getline(l:line), l:collhs - 1)
            if l:curchar == char2nr(' ')
                execute "normal! \"_x"
            endif
        endfor
    endif
    " if the line didn't change, to stay on the same
    " character the column must move backward by one
    " to account for the new starting brace
    if l:found && l:line0 == l:linelhs
      let l:col0 = l:col0 - 1
    endif
    call setpos('.', [0, l:line0, l:col0, 0])
endfunction

nnoremap <leader>[{ :call IndentBrace('{', 'aB')<cr>
nnoremap <leader>[( :call IndentBrace('(', 'ab')<cr>
nnoremap <leader>[[ :call IndentBrace('[', 'a[')<cr>
nnoremap <leader>]} :call OutdentBrace('{', 'aB')<cr>
nnoremap <leader>]) :call OutdentBrace('(', 'ab')<cr>
nnoremap <leader>]] :call OutdentBrace('[', 'a[')<cr>

function! IsBlock(line, col)
    let l:nrparen = char2nr('(')
    let l:nrbrack = char2nr('{')
    let l:nrsquar = char2nr('[')
    let l:chratlc = strgetchar(getline(a:line), a:col - 1)
    let l:isparen = l:chratlc == l:nrparen
    let l:isbrack = l:chratlc == l:nrbrack
    let l:issquar = l:chratlc == l:nrsquar
    let l:isblock = l:isparen || l:isbrack || l:issquar
    return l:isblock
endfunction

function! GotoEndtoken(line, col, tokenline, tokencol)
    if IsBlock(a:tokenline, a:tokencol)
        " if we started on a block, we have arrived at the end of the block
        call setpos('.', [0, a:tokenline, a:tokencol, 0])
        execute "normal! %"
        return
    endif

    call setpos('.', [0, a:line, a:col, 0])
    execute "normal! %"
    let l:lineclose = line('.')
    let l:colclose  = col('.')
    call setpos('.', [0, a:tokenline, a:tokencol, 0])
    let l:chratlc = strgetchar(getline(a:tokenline), a:tokencol - 1)
    if l:chratlc == char2nr(' ')
        execute "normal w"
    endif
    let l:tokenline = line('.')
    let l:tokencol  = col('.')
    let l:chratlc = strgetchar(getline(l:tokenline), l:tokencol - 1)
    " spaces and closing braces and newlines are closing braces
    execute "normal! t "
    let l:colspace  = col('.')
    execute "normal! $"
    let l:colend  = col('.')
    let l:mincol  = min([l:colspace, l:colend])
    if l:mincol == l:tokencol
        let l:mincol = l:colend
    endif
    if l:lineclose == l:tokenline
        let l:mincol  = min([l:mincol, l:colclose])
    endif
    call setpos('.', [0, l:tokenline, l:mincol, 0])
endfunction

function! ExpandCompletely()
    let l:line0 = line('.')
    let l:col0  = col('.')
    execute "normal! ^"
    let l:lineopen = line('.')
    let l:colopen  = col('.')
    let l:onblock = IsBlock(l:lineopen, l:colopen)
    " don't expand when not on a block
    if ! l:onblock
        call setpos('.', [0, l:line0, l:col0, 0])
        return
    endif
    call GotoEndtoken(l:lineopen, l:colopen, l:lineopen, l:colopen)
    let l:lineclose = line('.')
    let l:colclose  = col('.')
    call setpos('.', [0, l:lineopen, l:colopen, 0])
    " we now know where this block begins and ends
    execute "normal! l"
    let l:linetoken = line('.')
    let l:coltoken  = col('.')
    " don't expand when there is no next character on the same line
    if l:coltoken == l:colopen
        call setpos('.', [0, l:line0, l:col0, 0])
        return
    endif
    let l:atblock = IsBlock(l:linetoken, l:coltoken)
    let l:startcol = l:atblock ? l:coltoken : l:colopen + &shiftwidth
    while 1
        call GotoEndtoken(l:lineopen, l:colopen, l:lineopen, l:colopen)
        let l:lineclose = line('.')
        let l:colclose  = col('.')
        call GotoEndtoken(l:lineopen, l:colopen, l:linetoken, l:coltoken)
        let l:linetokenend = line('.')
        let l:coltokenend  = col('.')
        if l:linetokenend == l:lineclose && l:colclose - l:coltokenend <= 1
            break
        endif
        execute "normal! a^"
        let l:linetoken = line('.')
        let l:coltoken  = col('.')
        let l:coloffset = l:startcol - l:coltoken
        if l:coloffset > 0
            execute "normal! " .    l:coloffset  . "i ^"
        else
            execute "normal! " . (- l:coloffset) . "X^"
        endif
        let l:linetoken = line('.')
        let l:coltoken  = col('.')
    endwhile
endfunction

nnoremap <leader>l %a<cr><esc>
nnoremap <leader>t :call ExpandCompletely()<cr>

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
