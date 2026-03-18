# GEMINI.md - Neovim Configuration (Kickstart Modular)

This directory contains a modular Neovim configuration based on [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim). It is designed to be a starting point that is easy to understand, extend, and customize.

## Project Overview

*   **Core:** Neovim (v0.10+) configured with Lua.
*   **Plugin Manager:** `lazy.nvim` - Handles installation and lazy-loading of plugins.
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
    *   `lazy-bootstrap.lua`: Automatically installs `lazy.nvim` if missing.
    *   `lazy-plugins.lua`: Defines and configures the plugin list.
    *   `kickstart/plugins/`: Contains pre-configured core plugins (Telescope, LSP, etc.).
    *   `custom/`: **This is where user-specific changes should live.**
        *   `options.lua` & `keymaps.lua`: User overrides for defaults.
        *   `plugins/`: Drop `.lua` files here to add new plugins automatically.
        *   `overrides.lua`: General Lua overrides.

## Building and Running

Since this is a configuration, "building" typically involves Neovim installing plugins on the first run.

*   **Launch Neovim:** `nvim`
*   **Manage Plugins:** `:Lazy` (Check status, update, or install).
*   **Manage LSPs/Tools:** `:Mason` (Install/uninstall language servers, formatters, linters).
*   **System Health:** `:checkhealth` (Crucial for debugging issues with dependencies like `ripgrep` or compilers).

## Development Conventions

*   **Plugin Configuration:** Prefer adding new plugins as separate files in `lua/custom/plugins/`. Follow the `lazy.nvim` spec format.
*   **Keybindings:** Use `<leader>` (set to Space) for custom mappings. Document them using `which-key.nvim` (built-in).
*   **LSP Setup:** Add new language servers to the `servers` table in `lua/kickstart/plugins/lspconfig.lua` or configure them in a custom plugin file.
*   **Formatting:** Triggered automatically or via specific keybinds defined in `lua/kickstart/plugins/conform.lua`.

## External Dependencies

Ensure these are installed on your system:
*   `git`, `make`, `unzip`, `gcc` (or another C compiler).
*   `ripgrep` (for Telescope search).
*   `fd` (for finding files).
*   A [Nerd Font](https://www.nerdfonts.com/) for icons (set `vim.g.have_nerd_font = true` in `init.lua` if installed).
