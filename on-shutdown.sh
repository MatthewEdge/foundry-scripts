#!/bin/sh

set -e

FOUNDRY_BUCKET=medgelabs-foundry

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

# Copy server data out to S3
aws s3 sync --delete $FOUNDRY_DATA s3://${FOUNDRY_BUCKET}/foundry/data
