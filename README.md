<div align="center">
    <h1>smartsort.nvim</h1>

![tests-badge](https://github.com/JavierPoduje/smartsort.nvim/actions/workflows/ci.yml/badge.svg)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
</div>

## Table of Contents

- [Description](#description)
- [Installation](#installation)
    - [Requirements](#requirements)
    - [Setup using Lazy](#lazy)

## Description<a name="description"></a>

Smartsort.nvim is a plugin that allows you to sort text in smart way by visually selecting the text and calling the sort function.

- Sort a single line
- Sort multiple blocks of text, like functions or classes

## Installation

### Requirements<a name="requirements"></a>

- **Neovim**
- Treesitter
- Plenary

### Setup using lazy<a name="lazy"></a>

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "smartsort.nvim",
    config = function ()
        require('smartsort')
    end
}
```


### How does it work?

#### Single line

- It's main use case is to sort imports, like this one:
```javascript
// before
import { foo, bar, baz } from 'module';

// after
import { bar, baz, foo } from 'module';
```
- For now, it sorts the line using `space` as the delimiter
    - It respect commas at the end of words
- sort the line in ascending order

#### Functions

- It's main use case is to sort functions in a file by their name
- It respects the space between the functions, even if it's inconsistent
- Except for the comments, it'll ignore blocks of code that are not functions and treat them as empty lines


## Usage

### Using lua:

- Sort single line in visual mode:
```lua
vim.keymap.set("v", "<leader>s", vim.cmd.Smartsort)
```

## WIP

- [x] Sort single lines
    - [ ] Support complex imports like:
    ```js
    import { foo as bar, baz } from 'module';
    ```
- [ ] Sort functions
