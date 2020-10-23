## ![Maze Generator](https://github.com/MayGo/maze-world/raw/master/raw-assets/brand/logo.png 'Maze World')

This is a Roblox plugin where you can generate maze with configurable size, materials and options. It will be generated to selected part or workspace if nothing is selected. You can even rotate object and maze is generated at a angle.

## Screenshots

![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-generator-controls.png 'Maze World')

![Maze World](https://github.com/MayGo/maze-world/raw/master/screenshots/maze-generator-result.png 'Maze World')

# Build plugin

-   run script `./script/build.sh`. To create `plugin`.rbxm file to current dir and to Roblox Studio plugins folder

# Publish plugin

-   drag created .rbxm file to empty project Explorer. Right click and 'Publish as plugin'

# Development

### Option 1

-   Open new place and start up Rojo.
-   Right click on ServerStorage.MazeGenerator folder and 'Save as Local plugin'
-   Now local plugin reloads on code change.

### Option 2

-   run `yarn build` or `npm build` or `./script/build.sh`
-   Open new place and start up Rojo.
-   Now local plugin reloads on code change.
