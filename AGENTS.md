# Neovim Configuration (Kickstart Modular)

This directory contains a modular Neovim configuration based on [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim). It is designed to be a starting point that is easy to understand, extend, and customize.

## Project Overview

*   **Core:** Neovim (v0.10+) configured with Lua.
*   **Plugin Manager:** Neovim's built-in `vim.pack`.
*   **Architecture:** Modular design with settings split across several files in the `lua/` directory.
*   **Key Features:**
    *   **LSP:** Managed via `nvim-lspconfig`, `mason.nvim`, and `mason-lspconfig.nvim`.
    *   **Completion:** Powered by `blink-cmp`.
    *   **Fuzzy Finding:** Using `telescope.nvim`.
    *   **Syntax Highlighting:** Provided by `nvim-treesitter`.
    *   **File Exploration:** `neo-tree.nvim`.
    *   **Formatting:** `conform.nvim`.

## Directory Structure

*   `init.lua`: The main entry point that orchestrates loading the configuration.
*   `lua/`:
    *   `options.lua`: Default Neovim options (line numbers, mouse, etc.).
    *   `keymaps.lua`: Global keybindings (split navigation, terminal exit, etc.).
    *   `pack.lua`: Configures Neovim's built-in package manager.
    *   `plugins.lua`: Loads upstream plugin modules and contains the single `require 'custom'` integration hook.
    *   `kickstart/plugins/`: Upstream-owned plugin configuration; do not customize these files.
    *   `custom/`: **All user-specific behavior belongs here.**
        *   `init.lua`: Explicitly orchestrates the personal configuration.
        *   `options.lua`, `keymaps.lua`, and `commands.lua`: User options, mappings, and commands.
        *   `plugins/`: Personal plugin installation and setup.
        *   `config/`: Overrides for plugins initialized by upstream.
        *   `helpers/`: Focused helper modules.
        *   `overrides.lua`: General Lua overrides.

## Building and Running

Since this is a configuration, "building" typically involves Neovim installing plugins on the first run.

*   **Launch Neovim:** `nvim`
*   **Manage Plugins:** `:PackUpdate` or `:lua vim.pack.update()`.
*   **Manage LSPs/Tools:** `:Mason` (Install/uninstall language servers, formatters, linters).
*   **System Health:** `:checkhealth` (Crucial for debugging issues with dependencies like `ripgrep` or compilers).

## Development Conventions

*   **Upstream Boundary:** Keep upstream-owned files byte-for-byte identical to `upstream/master`, except for the single `require 'custom'` hook in `lua/plugins.lua`.
*   **Plugin Configuration:** Add personal plugins as focused modules in `lua/custom/plugins/` using `vim.pack.add()`.
*   **Keybindings:** Put custom mappings in `lua/custom/keymaps.lua` and use `<leader>` (Space).
*   **LSP Setup:** Configure personal language servers in `lua/custom/config/lsp.lua`; do not edit `lua/kickstart/plugins/lspconfig.lua`.
*   **Formatting:** Configure personal formatters in `lua/custom/config/formatting.lua`.
*   **Formatting Style:** Follow the root `.editorconfig`; do not add per-file Vim modelines to custom files.

## External Dependencies

Ensure these are installed on your system:
*   `git`, `make`, `unzip`, `gcc` (or another C compiler).
*   `ripgrep` (for Telescope search).
*   `fd` (for finding files).
*   A [Nerd Font](https://www.nerdfonts.com/) for icons (set `vim.g.have_nerd_font = true` in `init.lua` if installed).
