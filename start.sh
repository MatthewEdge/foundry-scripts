#!/bin/sh

START_DIR=$PWD
cd terraform/stacks/test

export ACCESS_KEY=$(cat $HOME/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
export SECRET_KEY=$(cat $HOME/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

echo "Creating infra..."
docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light apply -auto-approve
OUTPUT=$(docker run --rm -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light output)

KEY=$(echo "$OUTPUT" | grep instance_key_name | cut -d '=' -f2 | cut -d ' ' -f2 | sed 's/"//g')
IP_ADDR=$(echo "$OUTPUT" | grep instance_ip_addr | cut -d '=' -f2 | cut -d ' ' -f2 | sed 's/"//g')

echo "To connect:"
echo "ssh -i $HOME/.ssh/$KEY.pem ec2-user@$IP_ADDR -o 'StrictHostKeyChecking no'"

scp -i $HOME/.ssh/$KEY.pem ./install-foundry.sh ec2-user@$IP_ADDR:/home/ec2-user/install.sh
ssh -i $HOME/.ssh/$KEY.pem ec2-user@$IP_ADDR -o 'StrictHostKeyChecking no' -f '/home/ec2-user/install.sh'

cd $START_DIR
