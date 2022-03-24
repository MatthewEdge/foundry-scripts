#!/bin/sh

set -e

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

START_DIR=$PWD
cd terraform/foundryvtt

export ACCESS_KEY=$(cat $HOME/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
export SECRET_KEY=$(cat $HOME/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)
docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
OUTPUT=$(docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light output)
KEY=$(echo "$OUTPUT" | grep instance_key_name | cut -d '=' -f2 | cut -d ' ' -f2 | sed 's/"//g')
IP_ADDR=$(echo "$OUTPUT" | grep instance_ip_addr | cut -d '=' -f2 | cut -d ' ' -f2 | sed 's/"//g')

# Copy server data out to S3
scp -i $HOME/.ssh/$KEY.pem -o 'StrictHostKeyChecking no' ./backup-data.sh ec2-user@$IP_ADDR:/home/ec2-user/backup.sh
ssh -i $HOME/.ssh/$KEY.pem -o 'StrictHostKeyChecking no' ec2-user@$IP_ADDR '/home/ec2-user/backup.sh'

docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light destroy --auto-approve
