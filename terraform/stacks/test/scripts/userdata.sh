#!/bin/bash
cat >> /etc/systemd/system/foundry.service <<EOL
[Service]
ExecStart=/home/ec2-user/run-foundry.sh
Restart=always
SyslogIdentifier=Foundry
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOL

systemctl enable foundry.service
systemctl start foundry.service

cat >> /etc/systemd/system/shutdown.service <<EOL
[Unit]
Description=S3 backup on shutdown
Before=shutdown.target reboot.target halt.target
Requires=network-online.target network.target

[Service]
KillMode=none
ExecStart=/bin/true
ExecStop=/home/ec2-user/backup-data.sh
RemainAfterExit=yes
Type=oneshot

[Install]
WantedBy=multi-user.target
EOL

systemctl enable shutdown.service
systemctl start shutdown.service


cat >> /home/ec2-user/run-foundry.sh <<EOL
#!/bin/sh

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_BIN=foundryvtt-0.8.8.zip

FOUNDRY_PATH=/home/ec2-user/foundryvtt
FOUNDRY_DATA=/home/ec2-user/foundrydata

yum update -y && yum install -y openssl-devel
curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -
yum install -y nodejs

# If Foundry not installed - install and sync data folder
if [ ! -d $FOUNDRY_PATH ]; then
  echo "FoundryVTT not found. Syncing..."

  mkdir -p $FOUNDRY_PATH
  mkdir -p $FOUNDRY_DATA

  aws s3 cp s3://${FOUNDRY_BUCKET}/foundry/${FOUNDRY_BIN} /home/ec2-user/foundryvtt.zip
  unzip /home/ec2-user/foundryvtt.zip -d $FOUNDRY_PATH

  echo "Syncing data folder from S3..."
  aws s3 sync --delete s3://${FOUNDRY_BUCKET}/foundry/data $FOUNDRY_DATA
fi

/usr/bin/node $FOUNDRY_PATH/resources/app/main.js --dataPath=$FOUNDRY_DATA > $FOUNDRY_PATH/fvtt.out 2>&1 &
echo $! > $FOUNDRY_PATH/fvtt.pid
EOL

chmod +x /home/ec2-user/run-foundry.sh
