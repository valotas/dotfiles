colorscheme evening

execute pathogen#infect()

"Set the default tab to 2
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab

"Nice display of tabs and trailing spaces
set list listchars=tab:»·,trail:·

"Some nerdtree stuff
autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

