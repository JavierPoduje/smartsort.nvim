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

Smarsort.nvim is a neovim plugin that provides enhanced sorting functionality, potentially leveraging Treesitter for more intelligent and context-aware sorting operations.

By extracting and processing nodes from a Treesitter parse tree within a given region of a buffer, this little thing can identify code structures (like functions, classes, etc.) and sort them based on their content or other criteria. The use of Treesitter allows the plugin to understand the code's syntax and semantics, leading to more accurate and reliable sorting results compared to simple text-based sorting.

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

- You can visually select a single line and pass a "separator" to `Smartsort.nvim` to do it's thing.
- For instance, if you have a line like this:
```javascript
import { foo, bar, baz } from 'module';
```
- You can select it and run `Smartsort` with the separator `,`:
```sh
:Smartsort ,
```
- This will sort the line and give you:
```javascript
import { bar, baz, foo } from 'module';
```

#### Multiple lines
- Multiple lines don't require a separator.
- Blocks of code are sorted based on their "identifier", which is the "name" or "label" that a block of code has.
- For example, a function like `const foo = () => {}` in JavaScript will be sorted based on the name `foo`, because that's their identifier.

#### What happens with blocks of code that don't have an identifier? for example, comments?
- If they are not defined neither in `sortable` nor `linkable` in the language definition inside `Smartsort.nvim`, they will be ignored and not sorted. In other words, They will keep their original position while other blocks of code are sorted around them.
- If they are defined as `linkable`, there are two possibilities:
    - If the node is not "attached" to any other node after it, meaning, there's a newline between them, it'll be ignroed just like the previous case.
    - Otherwise, it will be "attached" to the next node and sorted with it. This is useful for comments that are attached to a block of code, like:
    ```javascript
    // This is a comment
    const foo = () => {};

    // This is another comment

    const bar = () => {};
    ```
    - If we `Samartsort` this, the result will be:
    ```javascript
    const bar = () => {};

    // This is another comment

    // This is a comment
    const foo = () => {};
    ```
    - Why?
        - The function `foo` is attached to it's comment, so it will be sorted with it.
        - The function `bar` is not attached to any comment, so it will be sorted by itself.
        - The comment `// This is another comment` is not attached to any block of code, so it will be ignored and not sorted.
        - Since the function `bar` has a name (or "identifier") that's "smaller" than `foo`, it will be sorted before it.
