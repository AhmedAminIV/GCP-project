#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt install git -y

# clone the app repo
git clone https://github.com/AhmedAminIV/simple-node-app.git
cd simple-node-app

# Set docker repo
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


# add docker file in the app directory
DOCKERFILE_CONTENT=$(cat <<EOL
FROM node:18 AS build

# Create and set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy your application code into the container
COPY . .

FROM gcr.io/distroless/nodejs:18

COPY --from=build /app /app

WORKDIR /app

EXPOSE 3000

# Start your Node.js application
CMD ["index.js"]

EOL
)

# Create the Dockerfile
echo "$DOCKERFILE_CONTENT" > Dockerfile


# Build the node.js app image
sudo docker build -t node-app:latest .


# Save the service account key on the vm
cd /tmp
wget --header="Metadata-Flavor: Google" -O key.json http://metadata.google.internal/computeMetadata/v1/instance/attributes/service-account-key

# decrypt the key to its json format
cat key.json | base64 -d > key1.json

# Activate service account with key
gcloud auth activate-service-account --key-file=key1.json

# Authenticate to Docker
gcloud auth configure-docker us-central1-docker.pkg.dev -y

# Login
cat key.json | docker login -u _json_key_base64 --password-stdin \
https://us-central1-docker.pkg.dev

# Tag Docker Image
sudo docker tag node-app:latest us-central1-docker.pkg.dev/gcp-amin/project-repo/node-app:latest

# Push Docker Image to Artifact Registry
sudo docker push us-central1-docker.pkg.dev/gcp-amin/project-repo/node-app:latest

# Pull mongodb image
sudo docker pull bitnami/mongodb:4.4.4

# Tag Docker Image
sudo docker tag bitnami/mongodb:4.4.4 us-central1-docker.pkg.dev/gcp-amin/project-repo/bitnami/mongodb:4.4.4

# Push Docker Image to Artifact Registry
sudo docker push us-central1-docker.pkg.dev/gcp-amin/project-repo/bitnami/mongodb:4.4.4

# Deploy the proxy 
sudo apt install tinyproxy -y

# Open the Tinyproxy configuration file with sudo and append 'Allow localhost' to it
sudo sh -c "echo 'Allow localhost' >> /etc/tinyproxy/tinyproxy.conf"

# Restart tinyproxy
sudo service tinyproxy restart

# Install the kubernetes commandline client
sudo apt-get install kubectl
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

# Get cluster credentials and set kubectl to use internal ip
gcloud container clusters get-credentials cluster --zone us-east1-b --project gcp-amin --internal-ip

# Enabling control plane private endpoint global access
gcloud container clusters update cluster --zone us-east1-b  --enable-master-global-access