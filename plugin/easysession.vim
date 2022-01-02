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

if exists("loaded_easysession")
  finish
endif
let g:loaded_easysession = 1

let g:easysession_register_autocmd = get(g:, 'easysession_register_autocmd', 1)
let g:easysession_dir = get(g:, 'easysession_dir', expand('~/.vim_easysession'))
let g:easysession_default_name = get(g:, 'easysession_default_name', 'main')  " default session

if g:easysession_register_autocmd
  augroup EasySession
    autocmd!
    autocmd VimEnter * nested :call easysession#load()
    autocmd VimLeavePre * :call easysession#save()
    autocmd BufWritePost * :call easysession#save()
  augroup END
endif

function! s:CompleteEasySession(arglead, cmdline, cursorpos) abort
  return easysession#list()
endfunction

command! -nargs=* -range -complete=customlist,s:CompleteEasySession EasySessionLoad
  \ try |
  \   call easysession#load(<f-args>) |
  \   echo 'Vim session loaded successfully: "' . easysession#name() . '".' |
  \ catch |
  \   echoerr 'Error: ' . string(v:exception) |
  \ endtry

command! -nargs=* -range -complete=customlist,s:CompleteEasySession EasySessionRemove
  \ try |
  \   call easysession#remove(<f-args>) |
  \   echo 'Vim session deleted successfully.' |
  \ catch |
  \   echoerr 'Error: ' . string(v:exception) |
  \ endtry

command! -nargs=0 EasySessionSave
  \ try |
  \   call easysession#save() |
  \   echo 'Vim session saved successfully: "' . easysession#name() . '".' |
  \ catch |
  \   echoerr 'Error: ' . string(v:exception) |
  \ endtry

command! -nargs=0 EasySessionList
  \ try |
  \   for item in easysession#list() |
  \   echo item |
  \   endfor |
  \ catch |
  \   echoerr 'Error: ' . string(v:exception) |
  \ endtry

command! -nargs=0 EasySessionName
  \ echo easysession#name()
