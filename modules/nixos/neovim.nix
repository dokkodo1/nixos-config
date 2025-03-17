{ config, pkgs, lib, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          ctrlp

        ];
        opt = [

        ];
      };
    };
    customRC = ''
      set noncompatible
      syntax on
      set history=500
      nmap <leader> = ","
      nmap <leader>s :w!<cr>
      command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

      set so=7
      set wildmenu

      set ruler
      set cmdheight=1
      set backspace=eol,start,indent
      set whichwrap+=<,>,h,l
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set lazyredraw
      set showmatch
      set mat=2
      set noerrorbells
      set novisualbell
      set t_vb=
      set tm=500
      set foldcolumn=1
      set expandtab
      set smarttab
      set shiftwidth=2
      set tabstop=2
      set ai
      set si
      set wrap

      map <leader>tn :tabnew<cr>
      map <leader>to :tabonly<cr>
      map <leader>tc :tabclose<cr>
      map <leader>tm :tabmove
      map <leader>t<leader> :tabnext
      let g:lasttab = 1
      nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
      au TabLeave * let g:lasttab = tabpagenr()
      
      set laststatus=2
      set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
    '';
  };
}
