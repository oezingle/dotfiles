
# Lua-bundler

A command-line application to turn lua project directories into portable,
self-contained libraries, with any dependencies. This repository is bootstrapped
from
[oezingle/dotfiles](https://github.com/oezingle/dotfiles/tree/master/lib/bundler).

## configuration

The script supports CLI configuration, and a basic object-based configuration
file syntax.

### CLI configuration
Check the options using `lua bundler/bundler -h`

### JSON/LUA configuration
The bundler supports both .json configuration files and .lua files that return a
configuration table. Check out `default_config` in `init.lua`

### Command-line handler
Bundled code that uses differences in `arg` and `...` to determine if it's being
run as a library or from the command line will fail to work as expected.
However, you may export a function called `__from_cli` from your module, which
will be called if the bundler detects that `arg[1] == table.pack(...)[1]`
