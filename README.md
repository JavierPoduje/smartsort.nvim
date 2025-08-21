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


## Installation

### Requirements<a name="requirements"></a>

- Neovim
- Treesitter
- Plenary

### Setup using lazy<a name="lazy"></a>

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "smartsort.nvim",
    config = function ()
        require('smartsort').setup({
            non_sortable_behavior = "preserve", -- options: "preserve", "above", "below"
            single_line_separator = ",", -- use as the default separator for single line sorting
        })

        vim.keymap.set("v", "<leader>s", ":Smartsort")
    end
}
```


## How does it work?

**Important**: Smartsort requires you to visually select the code you want to sort. The plugin doesn't sort everything in your file by default - you need to highlight the specific region you want to organize.

### Multiple lines
- Multiple lines don't require a separator.
- Blocks of code are sorted based on their "identifier", which is the "name" or "label" that a block of code has.
- For example, a function like `const foo = () => {}` in JavaScript will be sorted based on the name `foo`, because that's their identifier.

#### Multi line sorting examples

**Sorting Functions and Classes**

When you have multiple functions or classes in a file, Smartsort can organize them alphabetically:

```typescript
// ===== Before sorting =====
const foo = () => {
  console.log("foo");
};

function bar() {
  console.log("bar");
}

// ===== After sorting =====
function bar() {
  console.log("bar");
}

const foo = () => {
  console.log("foo");
};
```

**Sorting Classes**

```typescript
// ===== Before sorting =====
class BClass {
  b: number;
  constructor(b: number) {
    this.b = b;
  }
}

class AClass {
  a: number;
  constructor(x: number, y: number) {
    this.a = x;
  }
}

// ===== After sorting =====
class AClass {
  a: number;
  constructor(x: number, y: number) {
    this.a = x;
  }
}

class BClass {
  b: number;
  constructor(b: number) {
    this.b = b;
  }
}
```

**Sorting Interfaces**

```typescript
// ===== Before sorting =====
export interface B {
  b: number;
}

export interface C {
  c: boolean;
}

interface A {
  a: string;
}

// ===== After sorting =====
interface A {
  a: string;
}

export interface B {
  b: number;
}

export interface C {
  c: boolean;
}
```

**Handling Comments with Different Behaviors**

Smartsort can handle comments in different ways based on the `non_sortable_behavior` setting:

```typescript
// ===== Before sorting =====
/**
 * This is a comment
 */
const foo = () => {
  console.log("foo");
};

// this is a comment

// this comment "belongs" to the function
function bar() {
  console.log("bar");
}
```

With `non_sortable_behavior = "above"` (comments stay at the top):
```typescript
// ===== After sorting =====
/**
 * This is a comment
 */
// this is a comment
// this comment "belongs" to the function
function bar() {
  console.log("bar");
}

const foo = () => {
  console.log("foo");
};
```

With `non_sortable_behavior = "below"` (comments stay at the bottom):
```typescript
// ===== After sorting =====
function bar() {
  console.log("bar");
}

const foo = () => {
  console.log("foo");
};

/**
 * This is a comment
 */
// this is a comment
// this comment "belongs" to the function
```

With `non_sortable_behavior = "preserve"` (comments keep their relative positions):
```typescript
// ===== After sorting =====
function bar() {
  console.log("bar");
}

// this is a comment

const foo = () => {
  console.log("foo");
};
```

**Custom Queries for Specific Patterns**

You can also sort specific patterns using custom Treesitter queries. For example, sorting console.log statements:

```typescript
// ===== Before sorting =====
console.log('ddd');
console.log('fff');
console.log('aaa');
console.log('eee');
console.log('bbb');
console.log('ccc');

// ===== After sorting =====
console.log('aaa');
console.log('bbb');
console.log('ccc');
console.log('ddd');
console.log('eee');
console.log('fff');
```

To enable this functionality, you need to configure a custom Treesitter query in your setup:

```lua
require('smartsort').setup({
    non_sortable_behavior = "preserve",
    single_line_separator = ",",
    treesitter = {
        javascript = {
            expression_statement = [[
                (expression_statement
                  (call_expression
                    function: (member_expression
                      object: (identifier) @object (#eq? @object "console")
                      property: (property_identifier) @property (#eq? @property "log")
                    )
                    (arguments
                      (string (string_fragment) @identifier)
                    )
                  )
                ) @block
            ]]
        },
    }
})
```

This query specifically targets `console.log()` statements and sorts them based on the string content within the parentheses.


### Single line

You can visually select a single line and sort items within it using a separator. By default, the `single_line_separator` from your configuration is used, but you can override it by passing a different separator to the command.

**Using the default separator (comma):**

```typescript
// ===== Before sorting =====
import { bb, dd, aa, cc, hola } from "somewhere.js";

// ===== After sorting =====
import { aa, bb, cc, dd, hola } from "somewhere.js";
```

**Overriding the separator with a custom one:**

You can override the default separator by passing it to the `:Smartsort` command:

```typescript
// ===== Before sorting =====
type greetings = "hi |" | "bye" | "| goodbye";

// ===== After sorting =====
type greetings = "bye" | "hi |" | "| goodbye";
```

To sort this, you would use:
```sh
:Smartsort |
```

> Notice that the plugin is smart enough to ignore separators that appear inside strings, so you don't need to worry about commas or other characters within quoted text.

## Rationale

Understanding how Smartsort handles different types of code blocks helps you make the most of the plugin. Here's how it works:

### How Code Blocks Are Identified

Smartsort uses Treesitter to parse your code and identify different types of nodes. Sortable blocks are calculated dynamically based on the queries defined for each language (like functions, classes, interfaces). These queries determine what constitutes a sortable block and what can be "linked" to other blocks (like comments).

### Handling Non-Sortable Blocks

**Standalone blocks** (like comments, blank lines, or other code that doesn't have a clear identifier) are handled in two ways:

1. **Ignored blocks**: If a block is not matched by any query and is not defined as `linkable` in the language definition, it will be ignored during sorting and maintain its original position while other blocks are sorted around it.

2. **Linked blocks**: If a block is defined as `linkable`, its behavior depends on its relationship to nearby code:
   - **Attached**: If there's no blank line between the block and the next sortable node, it "attaches" to that node and moves with it during sorting
   - **Standalone**: If there's a blank line separating it from the next node, it remains in place (like ignored blocks)

### Example: Comments and Their Behavior

Here's a practical example showing how comments are handled:

```typescript
// ===== Before sorting =====
// This is a comment
const foo = () => {};

// This is another comment

const bar = () => {};
```

After sorting, the result depends on the comment placement:

```typescript
// ===== After sorting =====
const bar = () => {};

// This is another comment

// This is a comment
const foo = () => {};
```

**Why does this happen?**

- The function `foo` is **attached** to its comment (no blank line between them), so they move together as a unit
- The function `bar` is **not attached** to any comment, so it sorts independently
- The comment `// This is another comment` is **standalone** (has blank lines on both sides), so it stays in place
- Since `bar` comes before `foo` alphabetically, it appears first in the sorted result

### Benefits of This Approach

This design provides several advantages:

- **Preserves code structure**: Comments stay with their related code
- **Maintains readability**: Standalone comments don't jump around unexpectedly
- **Flexible behavior**: You can control comment placement using blank lines
- **Language-aware**: Different languages can define their own queries for what's sortable and linkable
