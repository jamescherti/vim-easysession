" Name:        easysession.vim
" Description: Manage your Vim sessions effortlessly.
"
" Maintainer:  James Cherti
" URL:         https://github.com/jamescherti/vim-easysession
"
" Licence:     Copyright (C) 2022-2024 James Cherti
"              Distributed under terms of the MIT license.
"
"              Permission is hereby granted, free of charge, to any person
"              obtaining a copy of this software and associated documentation
"              files (the 'Software'), to deal in the Software without
"              restriction, including without limitation the rights to use,
"              copy, modify, merge, publish, distribute, sublicense, and/or
"              sell copies of the Software, and to permit persons to whom the
"              Software is furnished to do so, subject to the following
"              conditions: The above copyright notice and this permission
"              notice shall be included in all copies or substantial portions
"              of the Software.  THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT
"              WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
"              LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
"              PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"              AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
"              OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
"              OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"              SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function! easysession#remove(...) abort
  if len(a:000) > 0
    let l:session_name = s:strip(a:1)
  else
    let l:session_name = easysession#name()
  endif

  let l:session_file = s:easysession_get_session_path(l:session_name)
  if filereadable(l:session_file)
    let l:session_dir = fnamemodify(l:session_file, ':p:h')
    call delete(l:session_dir, 'rf')
    return
  else
    throw 'The session "' . l:session_name . '" does not exist.'
  endif
endfunction

function! easysession#load(...) abort
  if len(a:000) > 0
    let l:session_name = s:strip(a:1)
  else
    let l:session_name = easysession#name()
  endif

  let l:force_create = 1
  if len(a:000) > 1
    let l:force_create = a:2
  endif

  if !l:force_create && !filereadable(s:easysession_get_session_path(l:session_name))
    echoerr printf("The session '%s' does not exist", l:session_name)
  endif

  if l:session_name !=# easysession#name()
    " Switch the session
    call easysession#save()
    call easysession#name(l:session_name)

    let l:session_file = s:easysession_get_session_path(easysession#name())
    if ! filereadable(l:session_file)
      call s:empty_vim()
      " Save the new session if it does not exist
      call easysession#save()
    endif
  endif

  " Load
  let l:session_file = s:easysession_get_session_path(easysession#name())
  if ! filereadable(l:session_file)
    return
  endif

  call s:empty_vim()
  execute 'silent! source ' . fnameescape(l:session_file)
  redraw!
endfunction

function! easysession#save(...) abort
  if len(a:000) > 0
    let l:session_name = s:strip(a:1)
  else
    let l:session_name = easysession#name()
  endif

  let l:session_path = s:easysession_get_session_path(l:session_name)

  let l:session_dir = fnamemodify(l:session_path, ':p:h')
  if ! isdirectory(l:session_dir)
    call mkdir(l:session_dir, 'p', 0700)
  endif

  " Create the session
  let l:sessionoptions = &sessionoptions
  try
    set sessionoptions-=options

    execute 'mksession! ' . fnameescape(l:session_path)
    let l:mksession_lines = []
    let l:mksession_add_lines = []

    let l:session_load_post_index = -1
    let l:index = 0
    let l:save_restore_shortmess = 1

    for l:line in readfile(l:session_path)
      if match(l:line, '\C\v\sSessionLoadPost') !=# -1
        let l:session_load_post_index = l:index
      endif

      if match(l:line, '\C\vlet\s+s:shortmess_save\s+\=') !=# -1
        let l:save_restore_shortmess = 0
      endif

      if !g:easysession_save_argument_list && match(l:line, '\C\v\$argadd\s') !=# -1
        continue
      endif

      if ! has('patch-8.2.4566')
        " Fix: https://github.com/vim/vim/pull/9945
        " mksession: the conditions 'if bufexists("~/file")' are always false #9945
        " The 'patch-8.2.1978' adds the '<cmd>' feature
        let l:prefix = 'if bufexists("~'
        if l:line[0:len(l:prefix)-1] ==# l:prefix
          let l:line = substitute(l:line,
                \ '\C\v\s*(if\s*bufexists\s*\()(.*)(\s*\)\s*\|\s*buffer\s*)',
                \ '\1fnamemodify(\2, '':p'')\3',
                \ '')
        endif
      endif

      call add(l:mksession_lines, l:line)
      let l:index += 1
    endfor

    " Insert before
    if l:save_restore_shortmess
      " Fix: mksession shortmess issue
      call insert(l:mksession_lines, 'let s:shortmess_save = &shortmess', 0)
    endif

    call insert(l:mksession_lines, '" Created by the Vim plugin Easysession: https://github.com/jamescherti/vim-easysession', 0)

    " Insert after
    if l:session_load_post_index < 0
      let l:session_load_post_index = l:index
    endif

    if l:save_restore_shortmess
      " Fix: mksession shortmess issue
      call insert(l:mksession_lines, 'let &shortmess = s:shortmess_save', l:session_load_post_index)
    endif

    " Save color scheme
    if g:easysession_save_colorscheme && exists('g:colors_name') && g:colors_name !=# ''
      call insert(l:mksession_lines, 'endif', l:session_load_post_index)
      call insert(l:mksession_lines, '  syntax on', l:session_load_post_index)
      call insert(l:mksession_lines, "if has('syntax') && exists('g:syntax_on') && g:syntax_on", l:session_load_post_index)
      call insert(l:mksession_lines, 'silent colorscheme ' . fnameescape(g:colors_name), l:session_load_post_index)
    endif

    if g:easysession_save_colorscheme && exists('&background') && &background !=# ''
      call insert(l:mksession_lines, 'silent set background=' .
        \         fnameescape(&background), l:session_load_post_index)
      call insert(l:mksession_lines, "let g:colors_name=''",
        \         l:session_load_post_index)
    endif

    " Save gui font
    if g:easysession_save_guifont && has('gui_running') && exists('&guifont')
      let g:easysession_guifont = &guifont
    endif

    if g:easysession_save_guifont && exists('g:easysession_guifont')
      call insert(l:mksession_lines,
        \         'silent set guifont=' . escape(g:easysession_guifont, '\ "'),
        \          l:session_load_post_index)

      call insert(l:mksession_lines,
        \         'let g:easysession_guifont = ' . "'" .
        \         substitute(g:easysession_guifont, "'", "''", 'g') . "'",
        \         l:session_load_post_index)
    endif

    " Save
    call writefile(l:mksession_lines, l:session_path)
  catch
    echoerr string(v:exception)
    throw 'Unable to save the Vim session: "' . l:session_path . '".'
  finally
    let &sessionoptions = l:sessionoptions
  endtry
endfunction

function! easysession#list() abort
  let l:session_dir = s:easysession_dir()

  let l:result = []
  for path in sort(split(globpath(l:session_dir, '*'), '\n'))
      let l:item = fnamemodify(path, ':p:h:t')
      call add(l:result, item)
  endfor
  return l:result
endfunction

function! easysession#name(...) abort
  if len(a:000) > 0
    let s:easysession_name = a:1
  endif

  if ! exists('s:easysession_name')
    let s:easysession_name = g:easysession_default_session
  endif

  return s:strip(s:easysession_name)
endfunction

function! s:easysession_dir(...) abort
  if len(a:000) > 0
    let s:easysession_dir = a:1
  endif

  if ! exists('s:easysession_dir')
    let s:easysession_dir = g:easysession_dir
  endif

  return s:easysession_dir
endfunction

function! s:easysession_get_session_path(session_name) abort
  if has('win32') && !has('win32unix')
    let l:path_sep = '\'
  else
    let l:path_sep = '/'
  endif

  let l:session_name = s:strip(a:session_name)
  if l:session_name ==# ''
    throw 'Error with the session path: "' . l:session_dir . '".'
  endif

  let l:session_dir = s:easysession_dir() . l:path_sep . l:session_name

  return l:session_dir . l:path_sep . 'session.vim'
endfunction

function! s:strip(input_string) abort
  if exists('*trim')
    return trim(a:input_string)
  else
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
  endif
endfunction

function! s:empty_vim() abort
  tabnew
  tabonly
  enew
endfunction
