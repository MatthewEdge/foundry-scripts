#!/bin/bash
cat >> /etc/systemd/system/foundry.service <<EOL
[Service]
ExecStart=/home/ec2-user/start-foundry.sh
Restart=always
StandardOutput=stdout
StandardError=stderr
SyslogIdentifier=Foundry
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOL

systemctl enable foundry.service
systemctl start foundry.service

cat >> /etc/systemd/system/shutdown.service <<EOL

mkdir /etc/systemd/system/shutdown.service

[Service]
ExecStart=/usr/bin/node resources/app/main.js --dataPath=${HOME}/foundrydata
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=Foundry
User=ec2-user
Group=ec2-user
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL

systemctl enable shutdown.service
systemctl start shutdown.service
