<div align="center">
    <h1>smartsort.nvim</h1>

![tests-badge](https://github.com/JavierPoduje/smartsort.nvim/actions/workflows/ci.yml/badge.svg)
![lua-badge](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white)
</div>

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
    - [Setup using Lazy](#lazy)
- [Usage](#usage)

## Description<a name="description"></a>

Smarsort.nvim is a neovim plugin that provides enhanced sorting functionality, leveraging Treesitter for more intelligent and context-aware sorting operations.

By extracting and processing nodes from a Treesitter parse tree within a given region of a buffer, this little thing can identify code structures (like functions, classes, etc.) and sort them based on their content or other criteria. The use of Treesitter allows the plugin to understand the code's syntax and semantics, leading to more accurate and reliable sorting results compared to simple text-based sorting.

More about how the plugin works can be found in [the wiki](https://github.com/JavierPoduje/smartsort.nvim/wiki/Sorting-Mechanics).

## Features<a name="features"></a>

- *Multi-Line Sorting*: Sort blocks of code based on their identifiers (e.g., function names, class names).

  https://github.com/user-attachments/assets/27ebf19f-1abe-4ed3-99e5-e4ac3bf4e6e8

- *Single-Line Sorting*: Sort items in a single line (e.g., `import { foo, bar, baz }`) using a user-specified separator.

  https://github.com/user-attachments/assets/0c4e24fe-87f8-49c0-b245-3d9b737c4dd2

  > Use `:Smartsort <separator>` to specify a separator different from the one defined in `single_line_separator` (e.g. `:Smartsort |`).

- *Non-sortable blocks*: Describe where the non-sortable blocks should be placed (e.g. `{ non_sortable_behavior = "preserve" | "above" | "below" }`).

  https://github.com/user-attachments/assets/9ddcf253-f3a7-4fae-80a7-0b85e1424f4e


## Requirements<a name="requirements"></a>

- Neovim 0.7 or higher (needs treesitter support)

## Installation<a name="installation"></a>

### Lazy<a name="lazy"></a>

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

## Configuration Options

### `non_sortable_behavior`
The `non_sortable_behavior` option controls where non-sortable nodes (e.g., comments) are placed in multi-line sorting. Options are:
- "above": places before sorted blocks
- "below": places after sorted blocks
- "preserve": keeps original position

#### Examples
- `non_sortable_behavior` = "above":
```lua
-- ===== Before sorting =====
function foo()
    return 1
end

-- standalone comment

function bar()
    return 2
end

-- ===== After sorting =====
-- standalone comment

function bar()
    return 2
end

function foo()
    return 1
end
```

- `non_sortable_behavior` = "below":
```lua
-- ===== Before sorting =====
function foo()
    return 1
end

-- standalone comment

function bar()
    return 2
end

-- ===== After sorting =====
function bar()
    return 2
end

function foo()
    return 1
end

-- standalone comment
```

- `non_sortable_behavior` = "preserve":
```lua
-- ===== Before sorting =====
function foo()
    return 1
end

-- standalone comment

function bar()
    return 2
end

-- ===== After sorting =====
function bar()
    return 2
end

-- standalone comment

function foo()
    return 1
end
```

### `single_line_separator`
Sets the default separator for single-line sorting (e.g., commas in import `{ foo, bar, baz }`). Override it by passing a separator to `:Smartsort <separator>`.
```javascript
// ===== Before sorting =====
import { foo, bar, baz } from 'module';

// Execute
// - `:Smartsort ,`
// - `:Smartsort` if `single_line_separator` is set to `,` in the `smartsort.nvim` setup

// ===== After sorting =====
import { bar, baz, foo } from 'module';
```

## Usage<a name="usage"></a>

1. Select a region of text in visual mode.
2. Execute the `:Smartsort` command.
    - For single-line sorting, you can also provide a separator as an argument (e.g., `:Smartsort ,`). Otherwise, the `single_line_separator` defined in the setup will be used.
3. The selected text will be sorted based on the defined rules.

