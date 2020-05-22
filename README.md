## ![aze World](https://github.com/MayGo/maze-world/raw/master/assets/logo.png "Maze World")

This is a Roblox project where all the code is version controlled and synced to Roblox Studio with Rojo.
Project tries to cover most of the aspects of Roblox games.

### Roblox Rojo Roact boilerplate

Code is written so it can be used boilerplate project. If some important model is removed then warnings are outputted in Roblox Studio, but game still runs.

### Note

- Project was started with https://github.com/LPGhatguy/rdc-project taken as base

### Used libraries

- [Datastore2](https://github.com/Kampfkarren/Roblox/)
- - NOTE: Make sure you enabled: “Enabled Studio Access to API Services” and insert a boolvalue called
- [Moses](https://github.com/Yonaba/Moses/blob/master/doc/tutorial.md) for filtering and mapping (and more)
- [Roact-Animate](https://github.com/AmaranthineCodices/roact-animate)
- [Roact-Material](https://github.com/MayGo/roact-material)
- [Roact](https://github.com/Roblox/roact)
- [Rodux](https://github.com/Roblox/rodux)
  SaveInStudio in ServerStorage to true to test if your datastore saves!
- [Roact-Rodux](https://github.com/Roblox/roact-rodux.git)
- [Rojo](https://github.com/rojo-rbx/rojo)
- [GameAnalytics](https://gameanalytics.com/docs/item/roblox-sdk)
- Algoritm for labyrinth generation taken from https://github.com/shironecko/LuaMaze

### Game functionality

- [x] Money system - money is saved to server. Earn by winning.
- [x] Shop system. Spend earned money on pets with abilities.
- [x] Statistics system. Top money earned. Top times visited. Top games won.
- [x] Pet system. Equipped pets and maximum pet slots are saved on server. Pets give abilities.
- [x] Dynamically generated labyrinths.
- [x] Waiting rooms with waiting and playing lists.
- [x] Awards system. eg: Daily visit bonus, 10 times visit bonus
- [x] Collectable Coins
- [x] Inventory, collectable items. eg: Cherries

### TODO

- [ ] Add tabs to inventory and shop
- [ ] Add more collectable item: eggs
- [ ] Add Chests, Treasures (more coins)
- [ ] Notifications system

### Assets/Images

Faces are created with [Inkscape](https://inkscape.org/). Project file is `cartoon-faces.svg`.
From there each face is saved as png and imported to Roblox assets from RobloxStudio's Game Explorer window (Game needs to be published first)

### Assets/Meshes

Meshes are created with [Blender](https://www.blender.org/).
Coin object project file is `coin.blend`. From there coin is exported as `Wavefront .obj` and imported to Roblox assets from RobloxStudio's Game Explorer window. And then that model/mesh can be used by right clicking and selecting Insert. Added
Cherry object project file is `cherry.blend`. It is texture painted that using ([tutorial](https://www.youtube.com/watch?v=lmbAs9jE1vI)). Exported model as `fbx`. Added as MeshPart to Roblox. Added textureId to uploaded `Cherry_correct.png`
There is also unfinished chest model `box.blend`.

### Other games that have sources available

- [Minershaven](https://github.com/berezaa/minershaven)
- [Roblox World](https://github.com/gtraines/roblox-world)
- [Outyards]https://github.com/Nimblz/outyards
- [VintageCube]https://github.com/VintageCube/VintageCube

### How do I get set up?

- `npm i` - to load prettier and prettier-lua
- Open laburinthRunner2020.rbxl
- Configure VS Code and start Rojo (from VS Code footer)
- From Roblox Studio->Plugins->Rojo click connect

#### Code checkout with Sourcetree app

- Download and install [Sourctree](https://www.sourcetreeapp.com/)
- Check "Perform submodule actions recursively" from Preferences->Git window
- Checkout code (now it should also download submodules into modules folder)

#### VS Code Configuration

- [VS Code Rojo plugin](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
- - note macOS needs cargo installed
- - let Rojo Manage Roblox Studio plugin
- - VS Code restart might be needed so Rojo to start properly
- - enable Allow HTTP requests from Roblox studio Game Settings->Options
- [VS Code Prettier plugin](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [VS Code Lua plugin](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)