colorscheme evening
execute pathogen#infect()
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab

autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

