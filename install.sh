#!/bin/bash

# Sets up GitHub Codespaces

rm -f ~/.nanorc ~/.screenrc ~/.gitconfig ~/.bashrc

sed -r -i gitconfig -e 's/^( +)signingkey/\1# signingkey/'

ln -s ${PWD}/nanorc ~/.nanorc
ln -s ${PWD}/screenrc ~/.screenrc
ln -s ${PWD}/gitconfig ~/.gitconfig
ln -s ${PWD}/bashrc ~/.bashrc

gpg --locate-external-keys github@stwalkerster.co.uk
