" vim-plug
" we can install plug using this command:
" curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'	" gruvbox color theme
Plug 'vim-airline/vim-airline' " airline status and bufferlines
Plug 'machakann/vim-sandwich' " sandwich :S
" Plug 'mhinz/vim-signify'
" Plug 'tpope/vim-fugitive'
" Plug 'editorconfig/editorconfig-vim' " editor config is great for collaboration
" Plug 'w0rp/ale'		" Async Lint Engine

" These can be used to run unittest from within vim
"Plug 'janko/vim-test'
"Plug 'kassio/neoterm'

call plug#end()

" -----------------------------------------------------------------------------
" PLUGIN CONFIG - gruvbox
let g:gruvbox_italic = 1
let g:gruvbox_undercurl = 1
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'soft'

" -----------------------------------------------------------------------------
" PLUGIN CONFIG - airline
let g:airline_highlighting_cache = 1		" cache highlighting on redraw
let g:airline#extensions#tabline#enabled = 1	" tabline shows open buffers
let g:airline#extensions#ale#enabled = 1	" use powerline custom delimeters
if $TERM =~? '\vkitty'
	let g:airline_powerline_fonts = 1
	let g:airline_skip_empty_sections = 1
endif

" -----------------------------------------------------------------------------
" PLUGIN CONFIG - ale
" let g:ale_fixers = {'typescript': ['prettier', 'tslint', 'tslint']}
" let g:ale_fix_on_save = 1
" let g:ale_sign_error = '✘'
" let g:ale_sign_warning = '●'

" =============================================================================
" Config Proper
set title			" set the teminal title (useful for identiying open terminals)
"set cursorline			" show line of cursor
set lazyredraw			" only redraw when neccessary
set scrolloff=9 sidescrolloff=1	" padding for vertical and horizontal scroll
set hidden			" allow hiding buffers (can open a new buffer without writing)
set ignorecase smartcase	" search is only case sensetive if searchstring contains caps
"set omnifunc=syntaxcomplete#Complete	" turn on omni complete (use ^X^O to activate)

" -----------------------------------------------------------------------------
" place backup files
set directory=./.backup,.,/tmp backupdir=./.backup,.,/tmp	" directories to try for swap/backup files (respectively)
" set nobackup nowb noswapfile					" don't use swapfiles WARNING: this should only be used in conjuction with version control

" -----------------------------------------------------------------------------
" setup 'list' (diplay whitespace)
set list listchars=tab:>\ ,nbsp:%,trail:~,precedes:<,extends:>
" set listchars=tab:»\ ,nbsp:␣,trail:•,precedes:«,extends:»,eol:¶	" unicode symbols

" -----------------------------------------------------------------------------
" setup wildmenu (filename tab completion)
"et wildmenu wildmode=list:longest	" wildmenu on (bash mode)
" set wildmode=longest:full		" wildmenu zsh mode
set wildignore+=*.pyc,*/__pycache__/,*~,*/.svn/	" files to ignore from wildmenu

" -----------------------------------------------------------------------------
" setup folding (hiding code sections)
" set foldcolumn=1 foldmethod=syntax			" force showing fold column, fold on syntax
" set foldmarker={,}		"set to fold around {} blocks
set foldmethod=syntax		" fold on syntax

" -----------------------------------------------------------------------------
"  Line Numbering
set number relativenumber	" Hyrbid numbers - current line has number, others are relative
augroup numbertoggle		" Mode switching
	autocmd!
	autocmd TermOpen * setlocal nonumber norelativenumber
	autocmd BufEnter,FocusGained,InsertLeave * setlocal relativenumber	" Absolute numbers - Insert mode/Unfocused
	autocmd BufLeave,FocusLost,InsertEnter   * setlocal norelativenumber	" Hyrbrid numbers - Normal/Visual modes
augroup END

" -----------------------------------------------------------------------------
" Colourscheme
" native: torte, ron, elflord
" custom: gruvbox, candycode, jellybeans
set bg=dark
colorscheme gruvbox
if $TERM =~? '\vkitty'
	set termguicolors	" truecolor colouring
	let &t_Co = 256
endif

" -----------------------------------------------------------------------------
" maps using leader
let mapleader = ","
map <silent> <leader>p		:set paste! list!<CR>
map <silent> <leader>l		:set bg=light<CR>
map <silent> <leader>d		:set bg=dark<CR>
map <silent> <leader>s		:set spell!<CR>

" -----------------------------------------------------------------------------
" 'normal' mode keymaps
nmap <silent> <backspace>	:nohlsearch<CR>
nmap <silent> <space>		za

" -----------------------------------------------------------------------------
" terminal mode keymaps
tnoremap <silent> <esc> <C-\><C-n>

" -----------------------------------------------------------------------------
" command keymaps
" map w!! to hack for write as sudo
cabbrev w!!	w !sudo tee > /dev/null "%"

