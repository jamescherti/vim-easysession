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

if exists('loaded_easysession')
  finish
endif
let g:loaded_easysession = 1

let g:easysession_dir = get(g:, 'easysession_dir', expand('~/.vim_easysession'))
let g:easysession_default_session = get(g:, 'easysession_default_session', 'main')  " default session

let g:easysession_auto_load = get(g:, 'easysession_auto_load', 0)
let g:easysession_auto_save = get(g:, 'easysession_auto_save', 0)

let g:easysession_auto_save_on_write = get(g:, 'easysession_auto_save_on_write', 1)
let g:easysession_auto_save_on_quit = get(g:, 'easysession_auto_save_on_quit', 1)

let g:easysession_save_argument_list = get(g:, 'easysession_save_argument_list', 0)
let g:easysession_save_guifont = get(g:, 'easysession_save_guifont', 1)
let g:easysession_save_colorscheme = get(g:, 'easysession_save_colorscheme', 1)

if get(g:, 'easysession_register_autocmd', 1)
  augroup EasySession
    autocmd!
    autocmd VimEnter * nested
      \ if g:easysession_auto_load |
      \   call easysession#load(easysession#name(), 1) |
      \ endif
    autocmd VimLeavePre *
      \ if g:easysession_auto_save_on_quit && g:easysession_auto_save && !v:dying |
      \   call easysession#save() |
      \ endif
    autocmd BufWritePost *
      \ if g:easysession_auto_save_on_write && g:easysession_auto_save |
      \   call easysession#save() |
      \ endif
  augroup END
endif

function! s:complete_easy_session(arglead, cmdline, cursorpos) abort
  let l:list_sessions = easysession#list()

  if a:arglead ==# ''
    return l:list_sessions
  endif

  let l:result = []
  for l:item in l:list_sessions
    if l:item[0:len(a:arglead)-1] ==# a:arglead
      call add(l:result, l:item)
    endif
  endfor
  return l:result
endfunction

function! s:cmd_easysession_generic(func, msg, ...) abort
  let l:session_name = (len(a:000) > 0) ? a:1 :  easysession#name()
  try
    call a:func(l:session_name)
    echo printf(a:msg, l:session_name)
  catch
    echoerr 'Error: ' . string(v:exception)
  endtry
endfunction

function! s:cmd_easysession_rename(new_name) abort
  let l:old_name = easysession#name()
  try
    call easysession#save(a:new_name)
    call easysession#remove(l:old_name)
    call easysession#name(a:new_name)
    echo 'Vim session renamed successfully: ' . a:new_name
  catch
    echoerr 'Error: ' . string(v:exception)
  endtry
endfunction

function! s:cmd_easysession_list() abort
  try
    for item in easysession#list()
      echo item
    endfor
  catch
    echoerr 'Error: ' . string(v:exception)
  endtry
endfunction

command! -nargs=* -range -complete=customlist,s:complete_easy_session EasySessionDelete call <SID>cmd_easysession_generic(function('easysession#remove'), 'Vim session removed successfully: %s', <f-args>)
command! -nargs=* -range -complete=customlist,s:complete_easy_session EasySessionLoad call <SID>cmd_easysession_generic(function('easysession#load'), 'Vim session loaded successfully: %s', <f-args>)
command! -nargs=* -complete=customlist,s:complete_easy_session EasySessionSave call <SID>cmd_easysession_generic(function('easysession#save'), 'Vim session saved successfully: %s', <f-args>)
command! -nargs=* -complete=customlist,s:complete_easy_session EasySessionRename call <SID>cmd_easysession_rename(<f-args>)
command! -nargs=0 EasySessionName echo easysession#name()
command! -nargs=0 EasySessionList call <SID>cmd_easysession_list()
