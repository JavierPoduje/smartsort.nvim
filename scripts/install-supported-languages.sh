#!/bin/bash

lang_files=(typescript)

for lang in "${languages[@]}"
do
    echo -e "\nInstalling $lang"
    nvim --headless --clean \
        -u scripts/ci.vim \
        -c "TSInstallSync $lang" -c "q"
done

