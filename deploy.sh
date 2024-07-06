#!/bin/bash

# Step 1: SCP the Go files to the EC2 instance, I have to do this because sqlite requires gcc compile localized for ubuntu
# and it was more straightforward to do this rather than try to set up local docker container ubuntu just for building this artifact
# though perhaps I will revisit this in the future...
echo "Copying Go files to EC2 instance..."
scp -i /Users/jacksonstone/Desktop/Jackson\ Personal\ Site\ Key.pem -r migrations ubuntu@3.19.146.227:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }
scp -i /Users/jacksonstone/Desktop/Jackson\ Personal\ Site\ Key.pem go.mod ubuntu@3.19.146.227:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }
scp -i /Users/jacksonstone/Desktop/Jackson\ Personal\ Site\ Key.pem go.sum ubuntu@3.19.146.227:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }
scp -i /Users/jacksonstone/Desktop/Jackson\ Personal\ Site\ Key.pem server.go ubuntu@3.19.146.227:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }

# Step 3: SSH into the EC2 instance and move the file
echo "Connecting to EC2 instance and moving the file..."
ssh -i /Users/jacksonstone/Desktop/Jackson\ Personal\ Site\ Key.pem ubuntu@3.19.146.227 << EOF
    cd .temp/
  GOOS=linux GOARCH=amd64 CGO_ENABLED=1 /usr/local/go/bin/go build  -o ./sqlite_wrapper ./server.go|| { echo "Go build failed"; exit 1; }
  cd ~
  mv ./.temp/sqlite_wrapper . || { echo "Failed to move the file"; exit 1; }
  mv ./.temp/migrations . || { echo "Failed to move the file"; exit 1; }
  rm ./.temp/go.mod
  rm ./.temp/go.sum
  rm ./.temp/server.go
  chmod +x sqlite_wrapper || { echo "Failed to change permissions"; exit 1; }
  echo "File moved successfully"
  sudo systemctl restart sqlite_wrapper || { echo "Failed to restart"; exit 1; }
EOF

echo "Script completed successfully."
