#!/bin/bash

PLUGINS_PATH="$HOME/Library/Application Support/xbar/plugins"
CURRENT_DIR=$(pwd)

# Ensure the plugins directory exists before copying into it
mkdir -p "${PLUGINS_PATH}"

# Copy & make it executable
cp "${CURRENT_DIR}/weather.10m.rb" "${PLUGINS_PATH}/weather.10m.rb"
chmod +x "${PLUGINS_PATH}/weather.10m.rb"
