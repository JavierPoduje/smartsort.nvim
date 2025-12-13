# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Run all tests
make test

# Run a single test file
nvim --headless --clean -u scripts/minimal_init.vim -c "PlenaryBustedFile tests/chadnodes/sort_lua_spec.lua"

# Install treesitter parsers for CI
make ci-install-deps
```

## Architecture Overview

smartsort.nvim is a Neovim plugin that provides intelligent, treesitter-aware sorting of code blocks. It sorts multi-line code structures (functions, classes, etc.) by their identifiers and single-line items by a configurable separator.

### Core Modules

- **`lua/smartsort.lua`** - Main entry point. Orchestrates sorting by detecting single-line vs multi-line selections and delegating to appropriate handlers.

- **`lua/chadnode.lua`** - Represents a single treesitter node wrapped with sorting metadata (`sort_key`), region info, and attached prefix/suffix nodes (for handling comments and special characters).

- **`lua/chadnodes.lua`** - Collection of `Chadnode` objects. Handles node extraction from a region, merging sortable nodes with adjacent comments, calculating gaps, and producing sorted output.

- **`lua/chadquery.lua`** - Builds treesitter queries for extracting sortable nodes. Handles query construction per language and manages embedded language contexts.

- **`lua/treesitter/language_query.lua`** - Maps languages to their sortable node definitions. Each language config (in `lua/treesitter/<lang>.lua`) defines:
  - `query_by_node`: treesitter queries keyed by node type
  - `linkable`: non-sortable nodes that can attach to sortable ones (e.g., comments)
  - `handy_sortables`: wrapper nodes whose children determine sort keys
  - `end_chars`: special end characters (e.g., commas) with gap/attachment rules

### Language Support

Supported languages are defined in `lua/config.lua`. Each language has a configuration file in `lua/treesitter/` that defines which AST node types are sortable and the treesitter queries to extract identifiers.

### Testing

Tests use plenary.nvim's busted-style framework. Test files are in `tests/` with mocks in `tests/mocks/`. Language-specific sorting tests are in `tests/chadnodes/sort_<lang>_spec.lua`.

### Key Concepts

- **Sortable nodes**: AST nodes with an extractable identifier used as sort key
- **Linkable nodes**: Non-sortable nodes (like comments) that attach to adjacent sortable nodes
- **End characters**: Special characters (like commas) that may attach to preceding nodes based on gap rules
- **`non_sortable_behavior`**: Config option controlling where non-sortable nodes end up after sorting ("preserve", "above", "below")
