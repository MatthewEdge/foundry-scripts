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

