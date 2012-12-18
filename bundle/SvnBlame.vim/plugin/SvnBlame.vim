" SvnBlame.vim: Allows for easy blaming of current file while editing.

command! -nargs=? SvnBlame call <SID>svnBlameStart(<args>)

function! <SID>svnBlameStart(...)
    let cur_line = line(".")
    setlocal nowrap
    setlocal scrollbind
    15vnew
    nnoremap <buffer> <silent> quit :call <SID>svnBlameCleanup()
    let b:blame_target = bufnr("#")
    let b:target_modifiable = getbufvar(b:blame_target, "&modifiable")
    call setbufvar( b:blame_target, "&modifiable", 0 )
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal scrollbind
    let name = bufname("#")
    let b:all_revisions = system("svn log -q ".name." | awk '/^r[0-9]+/ {print $1}'")
    if a:0 > 0
        call <SID>svnBlame(name, a:1)
    else
        let revision = substitute(system("svn log -q -l 1 ".name." | awk '/^r[0-9]+/ {print $1}'"), "\n", "", "")
        call <SID>svnBlame(name, revision)
    endif
    exec "normal " . cur_line . "G"
    syncbind
endfunction

function! <SID>svnBlame(name, revision)
    setlocal modifiable
    normal ggdG
    exec 'r !svn blame -r '.a:revision.' '.a:name.' | awk '"'"'{printf " \%4s  \%-7s\n",$1,$2}'"'"
    g/^$/d
    exec 'silent file svn\ blame\ -r\ '.a:revision.'\ '.a:name
    setlocal nomodifiable
    exec 'nnoremap <buffer> <silent> <C-N> :call <SID>svnBlame("'.a:name.'", <SID>svnGetNewer("'.a:revision.'"))<cr>'
    exec 'nnoremap <buffer> <silent> <C-O> :call <SID>svnBlame("'.a:name.'", <SID>svnGetOlder("'.a:revision.'"))<cr>'
endfunction

function! <SID>svnGetOlder(revision)
    let target_rev = substitute(system("awk '{if(seen)rev=$0; seen=0} /".a:revision."/ {seen=1;rev=$0} END{print rev}' <<ENDHERE\n".b:all_revisions."ENDHERE\n"), "\n", "", "")
    return target_rev
endfunction

function! <SID>svnGetNewer(revision)
    let target_rev = substitute(system("awk '/".a:revision."/ {if(rev){print rev}else{print $0}} {rev=$0}' <<ENDHERE\n".b:all_revisions."ENDHERE\n"), "\n", "", "")
    echo target_rev
    return target_rev
endfunction

function! <SID>svnBlameCleanup()
    call setbufvar( b:blame_target, "&scrollbind", 0 )
    call setbufvar( b:blame_target, "&modifiable", b:target_modifiable )
    quit
endfunction
