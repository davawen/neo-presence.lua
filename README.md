# neo-presence.lua

A neovim rich presence plugin for discord using luajit FFI.

## Installation

The plugin automatically downloads the [Discord GameSDK](https://discord.com/developers/docs/game-sdk/sdk-starter-guide), you just have to run `build.sh`.  
You need `gcc`, `curl`, `unzip`, and `cpp` (C Preprocessor) to build the library.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'davawen/neo-presence.lua',
    build = "./build.sh",
    config = function()
        require('neo-presence').setup {}
    end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'davawen/neo-presence.lua', { 'do': './build.sh' }
```

```lua
require('neo-presence').setup {}
```

## Usage

Setup options:
```lua
{
	autostart = true, -- automatically load plugin on setup, otherwise call `require('neo-presence.presence').start` or `:Neopresence`
	autostop = true -- automatically create an autocommand on "VimLeave" to quit plugin, otherwise call `require('neo-presence.presence).stop` or `NeopresenceQuit`
}
```

## For [WebCord](https://github.com/SpacingBat3/WebCord) or Discord Web users

WebCord doesn't support Rich Presence by default. If you want it, you either need to manually connect it to [arRPC](https://github.com/OpenAsar/arrpc), or use another Discord client that supports Rich Presence out of the box, like the official client or [Vesktop](https://github.com/Vencord/Vesktop#vencord-desktop).
