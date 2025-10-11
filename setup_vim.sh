#!/bin/bash

#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./vimrc ~/.vim/vimrc
ln -s ~/.vim/vimrc ~/.vimrc
#vim +PluginInstall +qall

#echo "dont forget to install / update YoucompleteMe"
#echo "https://github.com/j1z0/dotfiles.git"

vim -es -u ~/.vimrc -i NONE -c "PlugInstall" -c "qa"
