<div align="center">
    <h1>smartsort.nvim</h1>

![tests-badge](https://github.com/JavierPoduje/smartsort.nvim/actions/workflows/ci.yml/badge.svg)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
</div>

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
    - [Requirements](#requirements)
    - [Setup using Lazy](#lazy)
- [Usage](#usage)

## Description<a name="description"></a>

Smarsort.nvim is a neovim plugin that provides enhanced sorting functionality, leveraging Treesitter for more intelligent and context-aware sorting operations.

By extracting and processing nodes from a Treesitter parse tree within a given region of a buffer, this little thing can identify code structures (like functions, classes, etc.) and sort them based on their content or other criteria. The use of Treesitter allows the plugin to understand the code's syntax and semantics, leading to more accurate and reliable sorting results compared to simple text-based sorting.

## Features<a name="features"></a>

- *Multi-Line Sorting*: Sort blocks of code based on their identifiers (e.g., function names, class names).

  https://github.com/user-attachments/assets/04c842c7-1f92-477b-ae2d-ddf3d244da6f

- *Single-Line Sorting*: Sort items in a single line (e.g., `import { foo, bar, baz }`) using a user-specified separator.

  https://github.com/user-attachments/assets/609e751a-2b90-40ec-b8b7-3b5ead32e90c

- *Non-sortable blocks*: Describe where the non-sortable blocks should be placed (e.g. `{ non_sortable_behavior = "preserve" | "above" | "below" }`).

  https://github.com/user-attachments/assets/968049c4-bc8c-4767-a776-ce2a591c5a34


## Installation<a name="installation"></a>

### Requirements<a name="requirements"></a>

- Neovim
- Treesitter
- Plenary

### Setup using lazy<a name="lazy"></a>

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "smartsort.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function ()
        require('smartsort').setup({
            non_sortable_behavior = "preserve", -- options: "preserve", "above", "below"
            single_line_separator = ",", -- use as the default separator for single line sorting
        })

        vim.keymap.set("v", "<leader>s", ":Smartsort")
    end
}
```

## Usage<a name="usage"></a>

1. Select a region of text in visual mode.
2. Execute the `:Smartsort` command.
3. The selected text will be sorted based on the defined rules.

