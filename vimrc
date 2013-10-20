colorscheme evening
filetype plugin indent on " filetype detection[ON] plugin[ON] indent[ON]
syntax enable             " enable syntax highlighting (previously syntax on).
filetype indent on        " activates indenting for files
set ignorecase            " Make searches case-insensitive.
set autoindent            " auto-indent
set tabstop=2             " tab spacing
set softtabstop=2         " unify
set shiftwidth=2          " ident/outdent by 2 columns
set expandtab             " use spaces instead of tabs
set list listchars=tab:»·,trail:· "Nice display of tabs and trailing spaces

execute pathogen#infect() " Enable pathogen

"Some nerdtree stuff
autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

