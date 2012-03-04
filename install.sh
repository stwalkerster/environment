#!/bin/bash

cd

echo "####################################################"
echo "# Environment installation script for new machines #"
echo "####################################################"

if [ -e .bashrc ]
	then
		echo "bashrc already exists, moving"
		mv .bashrc .bashrc-old
fi

ln -s environment/bashrc .bashrc



