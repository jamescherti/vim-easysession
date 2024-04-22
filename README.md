# vim-easysession - Manage Vim sessions effortlessly

The Vim plugin **EasySession** offers a convenient and effortless way to persist and restore Vim editing sessions. It can significantly increase productivity and save a lot of time for users who frequently switch between different projects and those who frequently open and close the Vim editor.

In addition to its automatic session management capabilities, the EasySession Vim plugin also offers a variety of useful Vim commands that allow users to save, load, list and delete sessions manually.

## Author and license

Copyright (c) [James Cherti](https://www.jamescherti.com).

Distributed under terms of the MIT license.

## Features

- Automatically save and restore the Vim editing session (It can be activated by setting `g:easysession_auto_load` and `g:easysession_auto_save` to 1),
- Automatically save the current editing session when Vim is closed or when a file is saved (a few additional options are added to the session file that is generated by `mksession`: the font `&guifont`, the `&background`, and the color scheme).
- Manually save the current Vim editing session: `:EasySessionSave`,
- Switch to a different session: `:EasySessionLoad SESSION_NAME`,
- List the available sessions: `:EasySessionList`,
- Delete the current Vim session: `:EasySessionDelete SESSION_NAME`,
- Rename the current Vim session: `:EasySessionRename SESSION_NAME`,
- Auto-complete the Vim commands (e.g. `:EasySessionLoad`, `:EasySessionDelete`...),
- Specify the directory where all the saved sessions are located with: `let g:easysession_dir = expand('~/.my_vim_sessions')`.

For more information about the commands and options:
```viml
:help easysession
```

## How to make EasySession automatically load and save the session?

Add to `~/.vimrc`:
```viml
let g:easysession_auto_load = 1
let g:easysession_auto_save = 1

" Configure session options in Vim to include blank windows,current
" directory, folds, help windows, tab pages, Unix line endings, and use
" slashes for paths. You can also add to it: buffers,options,localoptions...
" Check `:help sessionoptions`.
set sessionoptions=blank,curdir,folds,help,tabpages,unix,slash,winsize
```

## Do you like vim-easysession?

Please [star vim-easysession on GitHub](https://github.com/jamescherti/vim-easysession).

You can also follow the author on [Github @jamescherti](https://github.com/jamescherti) and [Twitter @jamescherti](https://twitter.com/jamescherti).

## Installation

### Installation with Vim's built-in package manager (Vim 8 and above)

```bash
mkdir -p ~/.vim/pack/jamescherti/start
cd ~/.vim/pack/jamescherti/start
git clone --depth 1 https://github.com/jamescherti/vim-easysession
vim -u NONE -c "helptags vim-easysession/doc" -c q
```

### Installation with a third-party plugin manager

You can also install this Vim plugin with any third-party plugin manager such as Pathogen or Vundle.
