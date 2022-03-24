#!/bin/sh

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

# Start running the server
cd $FOUNDRY_PATH
node resources/app/main.js --port 80 --dataPath=$FOUNDRY_DATA
