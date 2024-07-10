#!/bin/bash

# Step 1: SCP the Go files to the EC2 instance, I have to do this because sqlite requires gcc compile localized for ubuntu
# and it was more straightforward to do this rather than try to set up local docker container ubuntu just for building this artifact
# though perhaps I will revisit this in the future...
echo "Copying Go files to EC2 instance..."
scp -i $EC2_PEM_PATH -r migrator ubuntu@$EC2_PUBLIC_IP:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }
scp -i $EC2_PEM_PATH -r server ubuntu@$EC2_PUBLIC_IP:/home/ubuntu/.temp || { echo "SCP failed"; exit 1; }

# Step 3: SSH into the EC2 instance and move the file
echo "Connecting to EC2 instance and moving the file..."
ssh -i $EC2_PEM_PATH ubuntu@$EC2_PUBLIC_IP << EOF
  cd ./.temp/server
  GOOS=linux GOARCH=amd64 CGO_ENABLED=1 /usr/local/go/bin/go build  -o ./../../sqlite_wrapper ./server.go|| { echo "Go build failed for server"; exit 1; }
  cd ../migrator

  GOOS=linux GOARCH=amd64 CGO_ENABLED=1 /usr/local/go/bin/go build  -o ../../run_migrations ./run_migrations.go || { echo "Go build failed for migraitons"; exit 1; }
  cd ../../
  rm -rf ./.temp/migrator || { echo "remove migrations failede"; exit 1; }
  rm -rf ./.temp/server || { echo "remove server failede"; exit 1; }
 
  chmod +x ./sqlite_wrapper || { echo "Failed to change permissions for server"; exit 1; }
  chmod +x ./run_migrations || { echo "Failed to change permissions for migrations"; exit 1; }
  ./run_migrations || { echo "Failed to run migrations"; exit 1; }
  rm ./run_migrations
  sudo systemctl restart sqlite_wrapper || { echo "Failed to restart"; exit 1; }
EOF

echo "Script completed successfully."
