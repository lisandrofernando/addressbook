#!/bin/bash

# Build and push Docker image
echo "Building Docker image..."
docker build -t addressbook:latest .

# Tag for ECR (replace with your ECR repository URI)
ECR_REPO="your-account-id.dkr.ecr.your-region.amazonaws.com/addressbook"
docker tag addressbook:latest $ECR_REPO:latest

# Push to ECR
echo "Pushing to ECR..."
aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin $ECR_REPO
docker push $ECR_REPO:latest

# Update deployment with ECR image
sed -i "s|image: addressbook:latest|image: $ECR_REPO:latest|g" k8s-deployment.yaml

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-ingress.yaml

echo "Deployment complete!"
echo "Check status with: kubectl get pods,svc,ingress"