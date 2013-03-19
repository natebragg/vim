" SvnDiff.vim: Allows for easy diff of current file while editing.

command! -nargs=? SvnDiff call <SID>svnDiffStart(<args>)

function! <SID>svnDiffStart(...)
    vnew
    nnoremap <buffer> <silent> quit :call <SID>svnDiffCleanup()
    let b:target_window = winnr('#')
    let b:diff_window = winnr()
    exec b:target_window."wincmd w"
    nnoremap <buffer> <silent> quit :call <SID>svnDiffCleanup()
    let b:target_window = winnr()
    let b:diff_window = winnr('#')
    exec b:diff_window."wincmd w"

    setlocal buftype=nofile
    setlocal bufhidden=wipe

    let name = bufname("#")
    let b:all_revisions = system("svn log -q ".name." | awk '/^r[0-9]+/ {print $1}'")
    if a:0 > 0
        call <SID>svnDiff(name, a:1)
    else
        let revision = substitute(system("svn log -q -l 1 ".name." | awk '/^r[0-9]+/ {print $1}'"), "\n", "", "")
        call <SID>svnDiff(name, revision)
    endif
endfunction

function! <SID>svnDiff(name, revision)
    diffoff
    normal ggdG
    exec 'r !svn cat -r '.a:revision.' '.a:name
    normal ggdd
    exec 'silent file svn\ diff\ -r\ '.a:revision.'\ '.a:name
    diffthis
    exec b:target_window."wincmd w"
    diffthis
    syncbind
    exec b:diff_window."wincmd w"

    exec 'nnoremap <buffer> <silent> <C-N> :call <SID>svnDiff("'.a:name.'", <SID>svnGetNewer("'.a:revision.'"))<cr>'
    exec 'nnoremap <buffer> <silent> <C-P> :call <SID>svnDiff("'.a:name.'", <SID>svnGetPrior("'.a:revision.'"))<cr>'
endfunction

function! <SID>svnGetPrior(revision)
    let target_rev = substitute(system("awk '{if(seen)rev=$0; seen=0} /".a:revision."/ {seen=1;rev=$0} END{print rev}' <<ENDHERE\n".b:all_revisions."ENDHERE\n"), "\n", "", "")
    return target_rev
endfunction

function! <SID>svnGetNewer(revision)
    let target_rev = substitute(system("awk '/".a:revision."/ {if(rev){print rev}else{print $0}} {rev=$0}' <<ENDHERE\n".b:all_revisions."ENDHERE\n"), "\n", "", "")
    echo target_rev
    return target_rev
endfunction

function! <SID>svnDiffCleanup()
    exec b:target_window."wincmd w"
    diffoff
    exec b:diff_window."wincmd w"
    quit
endfunction
