# vim-easysession - Manage your Vim sessions effortlessly.

**Easysession** is a Vim plugin that will help you to persist and restore your Vim editing sessions easily and effortlessly.

## Features

- Automatically restore the default session "main" when Vim is opened,
- Automatically save the current editing session when Vim is closed or when a file is saved (a few additional options are added to the session file that is generated blines y `mksession`: the font `&guifont`, the `&background`, and the color scheme).
- Manually save the current Vim editing session with `:EasySessionSave`,
- Switch to a different session with `:EasySessionLoad SESSION_NAME`,
- List the available sessions `:EasySessionList`,
- Delete a session with `:EasySessionRemove SESSION_NAME`,
- Auto-complete the Vim commands `:EasySessionLoad` and `:EasySessionRemove`,
- Specify the directory where all the saved sessions are located with: `let g:easysession_dir = expand('~/.my_vim_sessions')`.

For more information about the commands and options:
```viml
:help easysession
```

## Do you like vim-easysession?

Please [star vim-easysession on GitHub](https://github.com/jamescherti/vim-easysession).

You can also follow the author on [Github @jamescherti](https://github.com/jamescherti) and [Twitter @jamescherti](https://twitter.com/jamescherti).

## License

Copyright (c) [James Cherti](https://www.jamescherti.com).

Distributed under terms of the MIT license.

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
