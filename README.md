# 🚀 Simple Node.js App with MongoDB on GCP Cluster using Terraform and Kubernetes

## Description
This project sets up a fully functional Node.js application with MongoDB as the database on Google Cloud Platform (GCP). It deploys the application to a private GKE cluster, secures it, and exposes it via a load balancer. MongoDB is configured with one primary and two secondary instances using a StatefulSet.

## 🛠️ Installation
Before deploying this app, make sure you have the following prerequisites:
- Linux OS
- Git installed
- Terraform installed
- kubectl installed

### Step-by-Step Installation
1. Clone the repository:

```bash
git clone https://github.com/AhmedAminIV/GCP-project.git
```

2. Change directory to the Terraform files:

```bash
cd GCP-project/terraform
```

3. Initialize Terraform:

```bash
terraform init
```

4. Apply Terraform to build the required infrastructure:

```bash
terraform apply -var-file=terraform.tfvars
```

This process takes around 12 minutes for Terraform to provision the infrastructure.

5. Once Terraform has finished provisioning, you can execute the following commands to set up your GKE cluster and deploy the application.

### 🌐 Connecting to GKE Cluster and Deploying the App
```bash
# Get cluster credentials and set kubectl to use internal IP
gcloud container clusters get-credentials <cluster name> --zone <any cluster zone> --project <your project name> --internal-ip

# Tunnel to the VM host using IAP with proxy
gcloud compute ssh <private VM name> \
  --tunnel-through-iap \
  --project=<project id> \
  --zone=<VM zone> \
  --ssh-flag="-4 -L8888:localhost:8888 -N -q -f"

# Specify the proxy
export HTTPS_PROXY=localhost:8888
```

6. After connecting to your GKE private cluster, you can deploy the MongoDB backend and the Node.js frontend.

```bash
# Change directory to Kubernetes files
cd ../k8s

# Deploy MongoDB backend
kubectl apply -f ./backend

# Check if the backend is running
kubectl get pods -o wide -n backend

# Deploy Node.js frontend
kubectl apply -f ./frontend

# Check if the Node.js app is running
kubectl get pods -o wide -n frontend
```

7. To access the Node.js app, you need to know the IP of the load balancer. Retrieve the external IP using:

```bash
kubectl get svc -n frontend
```

Copy the external IP and paste it in your browser or use `curl <external ip>`. If you see the output "Visits: 1," everything is working correctly.

## 🧹 Clean Up
To clean up and delete all resources:

```bash
# Delete all pods by deleting namespaces
kubectl delete ns backend frontend

# Stop listening on the remote client
netstat -lnpt | grep 8888 | awk '{print $7}' | grep -o '[0-9]\+' | sort -u | xargs sudo kill

# Change directory to Terraform
cd ../terraform

# Destroy all provisioned infrastructure
terraform destroy
```

While destroying, you'll need to delete the disks used by the databases from the Google Cloud Console. Go to Compute Engine, select Disks, and press Delete for all disks.

## Acknowledgments
For assistance or questions, please feel free to contact me via [LinkedIn](https://www.linkedin.com/in/ahmed-amin-samey/).

Thanks for using this project!
