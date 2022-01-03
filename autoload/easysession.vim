" Name:        easysession.vim
" Description: Manage your Vim sessions effortlessly.
"
" Maintainer:  James Cherti
" URL:         https://github.com/jamescherti/vim-easysession
"
" Licence:     Copyright (c) James Cherti
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
    echo 'Deleted: ' . l:session_dir
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

function! easysession#save() abort
  let l:session_path = s:easysession_get_session_path(easysession#name())

  let l:session_dir = fnamemodify(l:session_path, ':p:h')
  if ! isdirectory(l:session_dir)
    call mkdir(l:session_dir, 'p', 0700)
  endif

  " Create the session
  let sessionoptions = &sessionoptions
  try
    set sessionoptions+=tabpages
    set sessionoptions-=options
    set sessionoptions-=blank

    execute 'mksession! ' . fnameescape(l:session_path)
    if has('gui_running') && &guifont !=# ''
      call writefile(['set guifont=' . escape(&guifont, ' ')], l:session_path, 'a')
    endif
  catch
    echoerr string(v:exception)
    throw 'Unable to save the Vim session: "' . l:session_path . '".'
  finally
    let &sessionoptions = sessionoptions
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
