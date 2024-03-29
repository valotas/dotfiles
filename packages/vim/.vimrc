colorscheme darkblue

" load the plugins placed in .vim/pack/*/opt/[name]
if &loadplugins
  if has('packages')
    packadd! nerdtree
  endif
endif

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

" Setup vim-airline
set guifont=Droid\ Sans\ Mono\ for\ Powerline\ 10 "Set the right fonts
let g:airline_powerline_fonts=1
set laststatus=2

" Enable pathogen
execute pathogen#infect()

"Some nerdtree stuff
autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


autocmd FileType javascript set list listchars=tab:\|¬,trail:· "Nice display of tabs and trailing spaces
