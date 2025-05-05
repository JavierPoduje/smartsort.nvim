#!/bin/bash

languages=(typescript vue css)

for lang in "${languages[@]}"
do
    echo -e "\nInstalling $lang"
    nvim --headless --clean \
        -u scripts/ci.vim \
        -c "TSInstallSync $lang" -c "q"
done
