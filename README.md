# neo-presence.lua

A neovim rich presence plugin for discord using luajit FFI.

## Usage

The plugin automatically downloads the [Discord GameSDK](https://discord.com/developers/docs/game-sdk/sdk-starter-guide), you just have to run `build.sh`:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'davawen/neo-presence.lua', build = "./build.sh" }
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'davawen/neo-presence.lua', { 'do': './build.sh' }
```
