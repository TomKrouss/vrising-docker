#!/bin/bash

function updateServer() {
    echo "Updating VRising Server"
    cd $STEAMCMDDIR
    ./steamcmd.sh +force_install_dir $SERVERDIR +login anonymous +app_update $STEAMAPPID +quit
}

function copySettingFiles() {
    echo "Copying server setting files to persistent data path if necessary"
    mkdir -p "$SETTINGSDIR"
    if [ ! -f "$SETTINGSDIR/ServerGameSettings.json" ]; then
        echo "ServerGameSettings.json not found. Copying default file."
        cp "$SERVERDIR/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" $SETTINGSDIR
    fi
    if [ ! -f "$SETTINGSDIR/ServerHostSettings.json" ]; then
        echo "ServerHostSettings.json not found. Copying default file."
        cp "$SERVERDIR/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" $SETTINGSDIR
    fi
}

function createAdminAndBanList() {
    echo "Creating adminlist.txt and banlist.txt if necessary"
    mkdir -p "$SETTINGSDIR"
    if [ ! -f "$SETTINGSDIR/adminlist.txt" ]; then
        echo "adminlist.txt not found. Creating empty file"
        touch "$SETTINGSDIR/adminlist.txt"
    fi
    if [ ! -f "$SETTINGSDIR/banlist.txt" ]; then
        echo "banlist.txt not found. Creating empty file."
        touch "$SETTINGSDIR/banlist.txt"
    fi
}

function startVirtualScreen() {
    echo "Starting virtual screen buffer"
    echo "Removing xvfb lock"
    rm /tmp/.X0-lock 2>&1
    echo "Starting xvfb screen"
    Xvfb :0 -screen 0 1024x768x16 -nolisten unix &
}

function startServer() {
    echo "Starting VRising Server"
    cd $SERVERDIR
    DISPLAY=:0.0 wine64 VRisingServer.exe -persistentDataPath $DATADIR
}

updateServer
copySettingFiles
createAdminAndBanList
startVirtualScreen
startServer
