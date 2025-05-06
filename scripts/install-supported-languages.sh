#!/bin/bash

languages=(typescript lua css scss)

for lang in "${languages[@]}"
do
    echo -e "\nInstalling $lang"
    nvim --headless --clean \
        -u scripts/ci.vim \
        -c "TSInstallSync $lang" -c "q"
done
