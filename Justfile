doc:
    vimcats -t -f -c -a \
    lua/tailwind-autosort/init.lua \
    lua/tailwind-autosort/config.lua \
    lua/tailwind-autosort/types.lua \
    > doc/tailwind-autosort.nvim.txt

set shell := ["bash", "-cu"]

fmt-check:
    stylua --config-path=.stylua.toml --check lua

fmt:
    stylua --config-path=.stylua.toml lua

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
