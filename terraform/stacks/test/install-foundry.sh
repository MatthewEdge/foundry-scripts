#!/bin/sh

FOUNDRY_BUCKET=medgelabs-foundry
FOUNDRY_BIN=foundryvtt-0.8.8.zip

FOUNDRY_PATH=$HOME/foundryvtt
FOUNDRY_DATA=$HOME/foundrydata

sudo yum update -y && sudo yum install -y openssl-devel
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs
sudo amazon-linux-extras install nginx1 -y

# TODO: Add this back in when certbot setup is configured
# sudo mdkir -p /etc/letsencrypt/live/foundry.medgelabs.io/

sudo cat >> /etc/nginx/sites-enabled/foundry.medgelabs.io <<EOL
server {

    # Enter your fully qualified domain name or leave blank
    server_name             foundry.medgelabs.io;

    # Listen on port 80 without SSL certificates
    listen                  80;

    # Sets the Max Upload size to 300 MB
    client_max_body_size 300M;

    # Proxy Requests to Foundry VTT
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_pass http://localhost:30000;
    }
}
EOL

if [ ! -d $FOUNDRY_PATH ]; then
  echo "FoundryVTT not found. Syncing..."

  mkdir -p $FOUNDRY_PATH
  mkdir -p $FOUNDRY_DATA

  aws s3 cp s3://${FOUNDRY_BUCKET}/foundry/${FOUNDRY_BIN} $HOME/foundryvtt.zip
  unzip $HOME/foundryvtt.zip -d $FOUNDRY_PATH

  echo "Syncing data folder from S3..."
  aws s3 sync --delete s3://${FOUNDRY_BUCKET}/foundry/data $FOUNDRY_DATA

  cat >> $HOME/foundrydata/Config/options.json <<EOL
    {
      "port": 30000,
      "upnp": true,
      "fullscreen": false,
      "hostname": foundry.medgelabs.io,
      "localHostname": null,
      "routePrefix": null,
      "sslCert": null,
      "sslKey": null,
      "awsConfig": null,
      "dataPath": "/home/ec2-user/foundrydata",
      "passwordSalt": null,
      "proxySSL": true,
      "proxyPort": 80,
      "minifyStaticFiles": false,
      "updateChannel": "release",
      "language": "en.core",
      "upnpLeaseDuration": null,
      "world": null
    }
EOL
fi

sudo systemctl enable nginx

nohup node $FOUNDRY_PATH/resources/app/main.js --dataPath=$HOME/foundrydata > fvtt.out 2>&1 &
echo $! > fvtt.pid
echo "Done"

# Start running the server
# TODO systemctl??
# node resources/app/main.js --dataPath=$HOME/foundrydata

