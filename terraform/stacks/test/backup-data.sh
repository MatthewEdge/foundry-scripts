#!/bin/sh
set -e

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

aws s3 sync --delete $FOUNDRY_DATA s3://${FOUNDRY_BUCKET}/foundry/data
