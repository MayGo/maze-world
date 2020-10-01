#!/bin/sh

PLUGIN_FILE="./MazeGenerator.rbxmx"
LOCAL_PLUGIN_FILE="/Users/$USER/Documents/Roblox/Plugins/MazeGenerator.rbxmx"


rojo build build.project.json -o "$PLUGIN_FILE"
rojo build build.project.json -o "$LOCAL_PLUGIN_FILE"

remodel run script/mark-plugin-as-dev.lua "$LOCAL_PLUGIN_FILE" "$LOCAL_PLUGIN_FILE" 



echo "Plugin saved to: $LOCAL_PLUGIN_FILE"