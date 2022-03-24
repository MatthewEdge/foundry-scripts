#!/bin/sh

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_BIN=foundryvtt-9.255.zip

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

if [ ! -d $FOUNDRY_PATH ]; then
  echo "FoundryVTT not found. Syncing..."

  mkdir -p $FOUNDRY_PATH
  mkdir -p $FOUNDRY_DATA

  aws s3 cp s3://${FOUNDRY_BUCKET}/foundry/${FOUNDRY_BIN} $HOME/foundryvtt.zip
  unzip $HOME/foundryvtt.zip -d $FOUNDRY_PATH

  echo "Syncing data folder from S3..."
  aws s3 sync --delete s3://${FOUNDRY_BUCKET}/foundry/data $FOUNDRY_DATA
fi

nohup node $FOUNDRY_PATH/resources/app/main.js --dataPath=$HOME/foundrydata > fvtt.out 2>&1 &
echo $! > fvtt.pid
echo "Done"

# Start running the server
# TODO systemctl??
# node resources/app/main.js --dataPath=$HOME/foundrydata
