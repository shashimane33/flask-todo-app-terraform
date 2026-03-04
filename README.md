# AWS Infrastructure Deployment with Terraform

This repository contains the Infrastructure as Code (IaC) required to deploy a Node.js (Express) frontend and a Python (Flask) backend across three progressively complex AWS architectures.

---

## 🏗️ Project Structure

The project is divided into three distinct deployment configurations:

* **`part1_single_ec2/`**: Deploys both the Frontend and Backend onto a single AWS EC2 instance.
* **`part2_separate_ec2/`**: Deploys the Frontend and Backend onto two separate AWS EC2 instances within the same VPC.
* **`part3_ecs_fargate/`**: Deploys the Frontend and Backend as highly available Docker containers using AWS ECS (Fargate), ECR, and an Application Load Balancer (ALB). This part utilizes S3 Remote State for stateless infrastructure management.

---

## ⚙️ Prerequisites

Before executing any Terraform scripts, ensure the following are installed and configured on your local machine:

1. **Terraform:** (v1.0.0 or higher)
2. **AWS CLI:** Authenticated with an IAM User/Role that possesses sufficient permissions (`AdministratorAccess` or full permissions for:
 * VPC, EC2, ECS, ECR, ALB, and IAM).
 * S3 (AmazonS3FullAccess): Required for Remote State Management in Part 3.
3. **Docker:** Required locally to build and push images for Part 3.

---

## 🚀 Deployment Instructions

### Part 1: Single EC2 Instance

* **Architecture:** default VPC & Subnet, 1 EC2 Instance, Security Group (Ports 22, 3000, 5000).
* **Execution:**

```bash
cd part1_single_ec2
terraform init
terraform plan
terraform apply -auto-approve
```

* **Output:** The terminal will output the EC2 Public IP. Access the frontend at `http://<PUBLIC_IP>:3000` & backend at `http://<PUBLIC_IP>:5000/task`.

### Part 2: Separate EC2 Instances

* **Architecture:** 1 VPC, 2 Public Subnets, 2 EC2 Instances (Frontend & Backend), configured Security Groups allowing cross-communication.
* **Execution:**

```bash
cd part2_separate_ec2
terraform init
terraform plan
terraform apply -auto-approve
```

* **Output:** The terminal will output two Public IPs (one for the Frontend, one for the Backend). Access the frontend at `http://<FRONTEND_PUBLIC_IP>:3000` & backend at `http://<BACKEND_PUBLIC_IP>:5000/task`.

### Part 3: ECS Fargate with ALB & Docker (Stateless deployment)

* **Architecture:** 1 VPC, 2 Public Subnets, Application Load Balancer, ECS Cluster, 2 Fargate Services, IAM Task Execution Roles, CloudWatch Logs.

**Step 3.1: Prepare Remote State**
1. Log into the AWS Console and create an S3 bucket (e.g., flask-todo-app-bucket).

2. nsure your IAM user has s3:PutObject and s3:GetObject permissions for this bucket.

**Step 3.2: Push Docker Images to ECR**
Before running the main infrastructure, you must manually push the application images to AWS ECR.

1. Authenticate Docker to AWS ECR.
2. Build the Flask and Express images locally.
3. Tag and push both images to your ECR repositories.

**Step 3.3: Deploy Infrastructure**
Update the `variables.tf` file in this directory with your newly created ECR Image URIs. Then run:

```bash
cd part3_ecs_fargate
terraform init
terraform plan
terraform apply -auto-approve
```

* **Output:** The terminal will output the DNS Name of the Application Load Balancer (e.g., `http://my-alb-123...elb.amazonaws.com`). Access frontend at `http://my-alb-123...elb.amazonaws.com:80` & backend at `http://my-alb-123...elb.amazonaws.com:5000`

> **Note:** Allow 3-5 minutes for the Fargate containers to provision and pass Target Group health checks before accessing the URL.

---

## 🧹 Cleanup / Teardown

To avoid incurring AWS charges, destroy the infrastructure for any given part when testing is complete. Navigate to the respective directory and run:

```bash
terraform destroy -auto-approve
```
