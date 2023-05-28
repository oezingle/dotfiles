
# Lua-bundler

A command-line application to turn lua project directories into portable, self-contained libraries, with any dependencies. This repository is bootstrapped from [oezingle/dotfiles](https://github.com/oezingle/dotfiles/tree/master/lib/bundler).

## configuration

The script supports CLI configuration, and a basic object-based configuration file syntax.

### CLI configuration
Check the options using `lua bundler/bundler -h`

### JSON/LUA configuration
The bundler supports both .json configuration files and .lua files that return a configuration table. Check out `default_config` in `init.lua`