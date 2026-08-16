colorscheme darkblue

filetype plugin indent on " filetype detection[ON] plugin[ON] indent[ON]
syntax enable             " enable syntax highlighting (previously syntax on).
filetype indent on        " activates indenting for files
set ignorecase            " Make searches case-insensitive.
set autoindent            " auto-indent
set tabstop=2             " tab spacing
set softtabstop=2         " unify
set shiftwidth=2          " ident/outdent by 2 columns
set expandtab             " use spaces instead of tabs
set noswapfile            " do not write annoying intermediate swap files,
                          "    who did ever restore from swap files
                          "    anyway?
                          "
set directory=~/tmp,/tmp  " if swapfile is needed keep it here
set nobackup              " do not keep backup files, git is here
set nowritebackup         " do not create backup files while editing
if v:version >= 730
  set undofile                " keep a persistent backup file
  set undodir=~/tmp,/tmp
endif

set laststatus=2

autocmd FileType javascript set list listchars=tab:\|¬,trail:· "Nice display of tabs and trailing spaces
