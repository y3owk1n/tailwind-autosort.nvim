> [!IMPORTANT]
> This plugin is a community project and is **NOT** officially supported by [Tailwind Labs](https://github.com/tailwindlabs).

# tailwind-autosort.nvim

Format tailwind classes without `prettier-plugin-tailwindcss` in `class`, `className`, `cn`, `cva`, `clsx` and `twMerge`

## Motivation

This project is originated, inspired and copied (yes, i copied) some of the functionality from [tailwind-tools.nvim](https://github.com/luckasRanarison/tailwind-tools.nvim). Please please please support the actual creator instead.

To me, I uses prettier and biome differently in different projects or maybe none of it are used in a project, but i still want to have the sorting capabilities regardless of the project formatting setup. For prettier, there is `prettier-plugin-tailwindcss`, but if you're not using that. For biome, there is `useSortedClass`, where it is still WIP, Hence, this is one of the way to achieve the same functionality.

At the moment I do not need the full suite of tailwind-tools but just class sorting. Also I have extended the sorting to work with `cn`, `cva`, `clsx` and `twMerge` and also include sort and save.

## Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Related projects](#related-projects)
- [Contributing](#contributing)

## Features

The plugin works with tsx treesitter grammars and provides the following features:

> Technically this should work with any other html inherited languages, but need to include relevant treesitter .scm files for it to work.
> For now, i am using tsx, so it will work with tsx only. Feel free to contribute for more treesitter .scm matching for various filetype like astro, vue, ...

- Class sorting (without [prettier-plugin](https://github.com/tailwindlabs/prettier-plugin-tailwindcss))
- Autosave after sorting
- Trim leading spaces
- Trim intermediate spaces within class string
- Works with `class`, `className`, `cn`, `cva`, `clsx` and `twMerge`

> [!NOTE]
> Language services like autocompletion, diagnostics and hover are already provided by [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server).

## Prerequisites

- Neovim v0.9 or higher (v0.10 is recommended)
- [tailwindcss-language-server](https://github.com/tailwindlabs/tailwindcss-intellisense/tree/master/packages/tailwindcss-language-server) >= `v0.0.14` (can be installed using [Mason](https://github.com/williamboman/mason.nvim))
- `tsx` and your other languages treesitter grammars (using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter))
- [ripgrep](https://github.com/BurntSushi/ripgrep) to find `prettier-plugin-tailwindcss` in tailwind config

> [!TIP]
> If you are not familiar with neovim LSP ecosystem check out [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) to learn how to setup the LSP.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- tailwind-autosort.lua
return {
  "y3owk1n/tailwind-autosort.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {} -- your configuration
}
```

If you are using other package managers you need to call `setup`:

```lua
require("tailwind-autosort").setup({
  -- your configuration
})
```

## Configuration

Here is the default configuration:

```lua
---@type TailwindAutoSort.Option
{
    autosort_on_save = {
        enabled = true, -- You can toggle this later with :TailwindSortEnable or :TailwindSortDisable
    },
}
```

## Commands

Available commands:

- `TailwindAutoSortRun`: sorts all classes in the current buffer without saving.
- `TailwindAutoSortGetState`: get the current autosave state.
- `TailwindAutoSortEnable`: enable autosave after sorting.
- `TailwindAutoSortDisable`: disable autosave after sorting.

## Related projects

Here are some related projects:

- [tailwindcss-intellisense](https://github.com/tailwindlabs/tailwindcss-intellisense) (official vscode extension)
- [tailwind-sorter.nvim](https://github.com/laytan/tailwind-sorter.nvim) (uses external scripts)
- [tailwind-tools.nvim](https://github.com/luckasRanarison/tailwind-tools.nvim)

## Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.

