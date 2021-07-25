[Unit]
Description=FoundryVTT
After=network.target

[Service]
User=ec2-user
Group=ec2-user
Type=simple
ExecStart=/home/ec2-user/run.sh
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
