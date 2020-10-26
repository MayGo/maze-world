## ![Maze World](https://github.com/MayGo/maze-world/raw/master/raw-assets/brand/logo.png 'Maze World')

This is a Roblox project where all the code is version controlled and synced to Roblox Studio with Rojo.
Project tries to cover most of the aspects of Roblox games.

### Roblox Rojo Roact boilerplate

Code is written so it can be used boilerplate project. If some important model is removed then warnings are outputted in Roblox Studio, but game still runs.

### Note

-   Project was started with https://github.com/LPGhatguy/rdc-project taken as base and refactored later with https://github.com/Roblox/desert-bus-2077 taken as an example.

# Game Description

You can play this game by running this project (need to publish also) or open in in Roblox: [Maze World](https://www.roblox.com/games/3376915546/Maze-World-Dynamic).
You can select from easy, medium or hard maze to play. All mazes are dynamically created, so every time you play it is new. For easier maze solving you can buy trail or speed pets. You earn coins by finishing mazes. Bigger mazes and better place in finishing gives more coins.

## Screenshots

![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-loading.gif 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-1.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-2.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-3.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-4.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-5.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-6.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-7.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-8.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-9.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-world-10.png 'Maze World')
![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-generator.png 'Maze World')

# Used libraries

-   [Datastore2](https://github.com/Kampfkarren/Roblox/)
-   -   NOTE: Make sure you enabled: “Enabled Studio Access to API Services” and insert a boolvalue called
-   [Moses](https://github.com/Yonaba/Moses/blob/master/doc/tutorial.md) for filtering and mapping (and more)
-   [Roact-Animate](https://github.com/AmaranthineCodices/roact-animate)
-   [Roact-Material](https://github.com/MayGo/roact-material)
-   [Roact](https://github.com/Roblox/roact)
-   [Rodux](https://github.com/Roblox/rodux)
    SaveInStudio in ServerStorage to true to test if your datastore saves!
-   [Roact-Rodux](https://github.com/Roblox/roact-rodux.git)
-   [Rojo](https://github.com/rojo-rbx/rojo)
-   [GameAnalytics](https://gameanalytics.com/docs/item/roblox-sdk)
-   Algoritm for maze generation taken from https://github.com/shironecko/LuaMaze
-   https://github.com/Sleitnick/Knit/blob/b1321acc92660b0dda59a724c54825973656338e/docs/util.md

# Game functionality

-   [x] Money system - money is saved to server. Earn by winning.
-   [x] Shop system. Spend earned money on pets with abilities.
-   [x] Game Pass shop item
-   [x] Statistics system. Top money earned. Top times visited. Top games won.
-   [x] Pet system. Equipped pets and maximum pet slots are saved on server. Pets give abilities.
-   [x] Dynamically generated mazes. Generate random items inside of maze
-   [x] Waiting rooms with waiting and playing lists.
-   [x] Awards system. eg: Daily visit bonus, 10 times visit bonus
-   [x] Collectable Coins
-   [x] Inventory, collectable items. eg: Cherries
-   [x] GameAnalytics scripts (gameKey and secretKey in GameAnalyticsServerInit.server.lua)
-   [x] Notifications system
-   [x] Sounds for coin collecting, daily reward notification, button click
-   [x] Trails to pets
-   [x] Locked rooms, unlock for coins
-   [x] Add clickable E indicator/button to workspace
-   [x] Uses StreamingEnabled, content is loaded as needed.
-   [x] Custom loading screen

# TODO

-   [ ] player died registered in playing list? Yes, but not while Game is starting.
-   [ ] to long wait time when timer goes to 00:00
-   [ ] Mobile, is there leaderboard
-   [ ] Mazes have two short times
-   [ ] Make prizes a bit bigger
-   [ ] Don't add coinpacks too oftern to mazes
-   [ ] Add tabs to inventory and shop
-   [ ] Add more collectable item: eggs
-   [ ] Add Chests, Treasures (more coins)
-   [ ] Fullscreen messages
-   [ ] Add avatar icon to player lists
-   [ ] Developer Product to shop items (eg: buy coins for Robux)
-   [ ] Add Badges, reward when completing some milestone

# Assets/Images

Faces are created with [Inkscape](https://inkscape.org/). Project file is `cartoon-faces.svg`.
From there each face is saved as png and imported to Roblox assets from RobloxStudio's Game Explorer window (Game needs to be published first)

# Assets/Meshes

Meshes are created with [Blender](https://www.blender.org/).

Coin object project file is `coin.blend`. From there coin is exported as `Wavefront .obj` and imported to Roblox assets from RobloxStudio's Game Explorer window. And then that model/mesh can be used by right clicking and selecting Insert.

Added Cherry object project file is `cherry.blend`. It is texture painted that using ([tutorial](https://www.youtube.com/watch?v=lmbAs9jE1vI)). Exported model as `fbx`. Added as MeshPart to Roblox. Added textureId to uploaded `Cherry_correct.png`

There is also unfinished chest model `box.blend`.

# Other games that have sources available

-   [Minershaven](https://github.com/berezaa/minershaven)
-   [Roblox World](https://github.com/gtraines/roblox-world)
-   [Outyards](https://github.com/Nimblz/outyards)
-   [roactplayground](https://github.com/Nimblz/roactplayground)
-   [VintageCube](https://github.com/VintageCube/VintageCube)
-   [World Messages](https://github.com/two-moons/world-messages/blob/master/src/Components/Thumbnail.lua) Nice user thunbnails

# Code checkout with Sourcetree app

When checking out this repo, submodules should also downloaded.

-   Download and install [Sourctree](https://www.sourcetreeapp.com/)
-   Check "Perform submodule actions recursively" from Preferences->Git window
-   Checkout code (now it should also download submodules into modules folder)

# How do I get set up?

-   `npm i` - to load prettier and prettier-lua (needed for VS Code)
-   run script `./script/build-and-open.sh`. Game.rbxlx is built using rojo. Currently every model is inside `raw-assets/game-models-and-place.rbxlx`. And after editing and saving you need to run `remodel run get-models.lua`, that saves every model to separate file. And rojo syncs it to your running Game.rblx.
-   Configure VS Code and start Rojo (from VS Code footer)
-   From Roblox Studio->Plugins->Rojo click connect

# Tools

-   [Rojo](https://github.com/Roblox/rojo), a build system
-   [Foreman](https://github.com/Roblox/foreman), a toolchain manager
-   [Remodel](https://github.com/Roblox/remodel), a deployment manager and multitool
-   [Tarmac](https://github.com/Roblox/tarmac), an asset manager
-   -   `tarmac sync --target roblox --auth ROBLOSECURITY`
-   -   Real timesaver. eg: sync, find out you png-s are to big. Use https://tinypng.com/ to make files a lot smaller. Resync. Done.

Tools installed using cargo. See each repo Readme for details.

# VS Code Configuration

-   [VS Code Rojo plugin](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
-   -   note macOS needs cargo installed
-   -   let Rojo Manage Roblox Studio plugin
-   -   VS Code restart might be needed so Rojo to start properly
-   -   enable Allow HTTP requests from Roblox studio Game Settings->Options
-   [VS Code Prettier plugin](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
-   [VS Code Lua plugin](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
-   [Roblox Lua Autocompletes](https://marketplace.visualstudio.com/items?itemName=Kampfkarren.roblox-lua-autofills)
-   [RBX lua plugin](https://marketplace.visualstudio.com/items?itemName=AmaranthineCodices.vscode-rbxlua)

There is nice tutorial in medium also: [Roblox Development in Visual Studio Code](https://medium.com/@OverHash/roblox-development-in-visual-studio-code-b3010c3d0181)

# Editing/ Fixing data in Datastore

-   Use Datastore Editor plugin. Play game in Studio
-   https://devforum.roblox.com/t/how-to-use-datastore2-data-store-caching-and-data-loss-prevention/136317/287
-   eg datastore key DATA/612741472
