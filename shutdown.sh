#!/bin/sh

set -e

FOUNDRY_BUCKET=medgelabs-foundry

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

# Copy server data out to S3
aws s3 sync --delete $FOUNDRY_DATA s3://${FOUNDRY_BUCKET}/foundry/data

## TODO check for success

START_DIR=$PWD
cd terraform/stacks/test

export ACCESS_KEY=$(cat $HOME/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
export SECRET_KEY=$(cat $HOME/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light destroy --auto-approve
