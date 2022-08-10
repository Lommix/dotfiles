echo "overwriting dotfiles"

#tmux
rm -f "${HOME}"/.tmux.conf
ln -sr .tmux.conf "${HOME}"/.tmux.conf


#nvim

rm -f "${HOME}"/.config/nvim/init.vim
rm -f "${HOME}"/.config/nvim/plugin/coc.vim

ln -sr nvim/init.vim "${HOME}"/.config/nvim/init.vim
ln -sr nvim/plugin/coc.vim "${HOME}"/.config/nvim/plugin/coc.vim
