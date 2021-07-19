#!/bin/sh

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_BIN=foundryvtt-0.8.8.zip

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

yum install -y openssl-devel
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
yum install -y nodejs

mkdir -p $FOUNDRY_PATH
mkdir -p $FOUNDRY_DATA

aws s3 cp s3://${FOUNDRY_BUCKET}/foundry/${FOUNDRY_BIN} $HOME/foundryvtt.zip
unzip $HOME/foundryvtt.zip -d $FOUNDRY_PATH
aws s3 sync --delete s3://${FOUNDRY_BUCKET}/foundry/data $FOUNDRY_DATA

# Start running the server
cd $FOUNDRY_PATH
node resources/app/main.js --port 80 --dataPath=$FOUNDRY_DATA
