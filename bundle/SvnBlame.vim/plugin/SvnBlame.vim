command! -nargs=? SvnBlame call <SID>svnBlame(<args>)

function! <SID>svnBlame(...)
    let s:cur_line = line(".")
    let s:blame_target = bufnr("%")
    setlocal nowrap
    setlocal scrollbind
    15vnew
    nnoremap <buffer> <silent> quit :call <SID>svnBlameCleanup()
    let s:blame_buffer = bufnr("%")
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal scrollbind
    if a:0 > 0
        exec 'r !svn blame -r ' . a:1 . ' # | awk '"'"'{printf " \%4s  \%-7s\n",$1,$2}'"'"
        exec 'silent file svn\ blame\ -r\ ' . a:1 . '\ #'
    else
        r !svn blame # | awk '{printf " \%4s  \%-7s\n",$1,$2}'
        silent file svn\ blame\ #
    endif
    g/^$/d
    setlocal nomodifiable
    exec "normal " . s:cur_line . "G"
    syncbind
endfunction

function! <SID>svnBlameCleanup()
    call setbufvar( s:blame_target, "&scrollbind", 0 )
    quit
endfunction
