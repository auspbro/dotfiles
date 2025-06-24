set nocompatible " Not Vi compatible, enables Vim-specific features and improvements

"------------------
" Syntax and indent
"------------------
syntax on " Turn on syntax highlighting
set showmatch " Show matching braces when the text indicator is over them

filetype plugin indent on " Enable file type detection and load plugins/indentation rules for specific file types
set autoindent " Keep the same indent as the previous line when starting a new line
set smartindent " Each line has the same indent amount as the previous line (provides more context-aware indentation)

"---------------------
" Basic editing config
"---------------------
set background=dark " Assume a dark background, helps with color schemes
set encoding=utf-8 nobomb " Set default encoding to UTF-8 and disable Byte Order Mark (BOM)
set ttyfast " Optimize for fast terminal connections

" ## No backup file
set nobackup " Do not create backup files
" set noshowmode " Hide mode (e.g., -- INSERT --) - This is commented out
set showmode " Show the current mode (e.g., -- INSERT --) - This is active
set laststatus=2 " Always show the status line (0=never, 1=only if more than one window, 2=always)
set backspace=indent,eol,start " Allow backspacing over everything in insert mode (autoindent, end of line, start of insert)
set timeout timeoutlen=1000 ttimeoutlen=50 " Fix slow <Esc> in insert mode with mappings, and mapping timeout
                                          " timeoutlen: time in ms to wait for a mapped sequence
                                          " ttimeoutlen: time in ms to wait for a key code sequence
set nu " Display line numbers
set rnu " Display relative line numbers (current line is 0, others relative to it)
set hls " Highlight all occurrences of the last searched pattern
set history=8192 " Keep more command-line history
set incsearch " Incremental search: show matches as the search string is being typed
set showcmd " Display (partial) commands in the last line of the screen
set ruler " Show the cursor position (row, col) in the status line
set cursorline " Highlight the current line where the cursor is

" set cursorcolumn " Highlight the current column where the cursor is - Commented out, can be distracting for some
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_ " Define how to display listchars:
                                 " tab: right-pointing triangle then a space
                                 " trail: trailing whitespace as a middle dot
                                 " eol: end of line character as a not sign (¬)
                                 " nbsp: non-breaking space as an underscore
set list " Display characters defined by 'listchars'

" Smart case-sensitive search
set ignorecase " Ignore case when searching
set smartcase " Override 'ignorecase' if the search pattern contains uppercase letters

" Tab completion for files/buffers
set wildmode=longest:list,full " Completion mode for wildmenu:
                               " first longest common string, then list matches, then complete to full match
" set wildmode=list:full " Alternative wildmode - Commented out
set wildmenu " Display a command-line completion menu
set mouse+=a " Enable mouse mode in all modes (scrolling, selection, window resizing, etc.)

if &term =~ '^screen' || &term =~ '^tmux' " Check if running inside screen or tmux
    " tmux/screen knows the extended mouse mode
    set ttymouse=xterm2 " Use xterm2 mouse reporting for better mouse support in tmux/screen
endif
set nofoldenable " Disable code folding by default

" Use spaces instead of tabs
set expandtab " Insert spaces when Tab key is pressed
set tabstop=4 " Number of spaces that a Tab in the file counts for
set shiftwidth=4 " Number of spaces to use for autoindent and shifting commands (<<, >>)
set softtabstop=4 " Number of spaces that Tab_key inserts/deletes in insert mode
                  " (if expandtab is off, it tries to use a mix of tabs and spaces)

" Clipboard integration
" Recommendation: Use 'unnamedplus' if you want to integrate with the system's primary selection (often used with Ctrl+C/Ctrl+V outside Vim).
" Use 'unnamed' if you want to integrate with the X11 primary selection (middle-mouse paste).
" Having both set sequentially means the last one takes effect. You probably want only one of them.
" Let's assume you want the system clipboard (Ctrl+C/Ctrl+V style)
set clipboard=unnamedplus " Use the system clipboard for all yank, delete, change, and put operations.
                          " This uses the '+' register.
" set clipboard=unnamed   " Use the '*' register (X11 primary selection) for yanks/puts.
                          " If you uncomment this, it will override the 'unnamedplus' setting above.

" For leader shortcut
let mapleader = " " " Set the leader key to Space
nnoremap <Leader>q :q<CR> " Normal mode: <Space>q to quit
nnoremap <Leader>w :w<CR> " Normal mode: <Space>w to write (save)
nnoremap <Leader>wq :wq<CR> " Normal mode: <Space>wq to write and quit

map <C-K> <C-V> " Map Ctrl-K to start visual block mode (Ctrl-V)
                " Note: Some terminals might use Ctrl-K for other purposes.
inoremap jk <Esc> " Map 'jk' in insert mode to Escape
inoremap vv <Esc> " Map 'vv' in insert mode to Escape

" Set cursor shape and color based on mode (for xterm-compatible terminals)
if &term =~ '^xterm' || &term =~ ' gnome ' || &term =~ ' alacritty ' || &term =~ ' kitty ' " Added more modern terminals
  " VimEnter: When Vim starts
  autocmd VimEnter * silent !echo -ne "\e[1 q" " Set cursor to steady block on Vim enter (2 is steady block)
                                              " Original was \e[1 q (blinking block)

  " t_EI: Termcap/Terminfo entry for cursor shape in Normal mode (EI = End Insert)
  let &t_EI = "\e[1 q" " Normal mode: steady block cursor
                      " (Original had .= which appends, direct set is usually fine)

  " t_SI: Termcap/Terminfo entry for cursor shape in Insert mode (SI = Start Insert)
  let &t_SI = "\e[5 q" " Insert mode: steady vertical bar cursor
                      " (Original had .= and \e[5 q for blinking bar)

  " t_SR: Termcap/Terminfo entry for cursor shape in Replace mode (SR = Start Replace)
  let &t_SR = "\e[3 q" " Replace mode: steady underscore cursor
                      " (Original had blinking underscore and green color change)
                      " Note: Setting color via t_SR might not be universally supported or desired.
                      " It's often better to let the terminal/colorscheme handle colors.
                      " Removed "\<Esc>]12;green\x7" for simplicity and broader compatibility.

  " Cursor shape codes for many terminals (e.g., xterm, urxvt, konsole, alacritty, kitty):
  " 0 -> blinking block (implementation-defined, often default)
  " 1 -> blinking block
  " 2 -> steady block
  " 3 -> blinking underscore
  " 4 -> steady underscore
  " 5 -> blinking vertical bar (I-beam)
  " 6 -> steady vertical bar (I-Beam)

  " VimLeave: When Vim exits
  autocmd VimLeave * silent !echo -ne "\e[ q" " Reset cursor to default (often blinking block) on Vim exit
                                             " \e[ q (with a space) is often the DECSCUSR command to restore default.
                                             " Or \e[0 q or \e[1 q depending on desired default.
endif
