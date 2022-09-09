SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

#tmux
rm -f "${HOME}"/.tmux.conf
ln -s "$BASEDIR"/.tmux.conf "${HOME}"/.tmux.conf

#nvim
rm -rf "${HOME}"/.config/nvim
ln -s "$BASEDIR"/nvim "${HOME}"/.config/nvim

echo "cloning tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
