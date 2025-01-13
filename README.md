# smartsort.nvim

## Description

Smartsort.nvim is a plugin that allows you to sort text in smart way by visually selecting the text and calling the sort function.

- You can sort a single line
- You can sort multiple blocks of text, like functions or classes

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
