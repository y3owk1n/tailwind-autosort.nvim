doc:
	panvimdoc --project-name tailwind-autosort.nvim --input-file ./README.md --demojify true --vim-version "Neovim >= 0.10.0"

set shell := ["bash", "-cu"]

test:
	@echo "Running tests in headless Neovim using test_init.lua..."
	nvim -l tests/minit.lua --minitest
