#!/bin/bash

echo "Installing parsers..."
nvim --headless --clean \
    -u scripts/minimal_init.vim \
    -c "q"
