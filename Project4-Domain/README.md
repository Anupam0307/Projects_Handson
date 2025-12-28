This project demonstrates a production-style three-tier application on AWS EKS, built using modular Terraform, Helm, and GitOps best practices.

- Reusable Terraform modules for infrastructure
- Single codebase supporting multiple environments
- Dev and Prod deployed independently via environment-specific configs

#### Architecture ####

- Route53 manages DNS for a domain hosted on Hostinger
- Traffic enters via an Application Load Balancer (ALB)
- Kubernetes Ingress (ALB Ingress Controller) exposes services
- Web layer: public subnets
- App layer: private subnets
- Database: Amazon RDS in private subnets
- HTTPS intentionally excluded to stay within AWS Free Tier limits
- Ingress routes external traffic to the web service; internal Kubernetes networking connects application layers.

#### CI/CD & GitOps ####

- CI: GitHub Actions builds and pushes Docker images
- CD: Argo CD deploys Helm charts using GitOps
      - Dev auto-syncs
      - Prod requires manual approval
- Ensures controlled, auditable releases

#### Prerequisites (One-Time Manual Setup) ####

Before running Terraform:

- Create an S3 bucket for remote state
- Create a DynamoDB table for state locking

S3 Bucket      : <terraform-state-bucket>
DynamoDB Table: terraform-locks

#### Required GitHub Secrets ####

DOCKERHUB_USERNAME
DOCKERHUB_PASSWORD
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

#### Security Notes ####

- No hardcoded credentials
- IRSA used for pod-level AWS access
- Database credentials stored in AWS Secrets Manager

###########################################
########## Architecture Diagram ###########
###########################################

Private subnets for app & database

                   ┌──────────────────────────┐
                   │        Route53 DNS        │
                   │  dev.anupamghai.shop      │
                   │  prod.anupamghai.shop     │
                   └────────────┬─────────────┘
                                │
                   ┌────────────▼─────────────┐
                   │   ALB (Ingress - HTTP)    │
                   │   Internet Facing         │
                   └────────────┬─────────────┘
                                │
        ┌───────────────────────┴───────────────────────┐
        │                   EKS Cluster                  │
        │                                                │
        │  ┌──────────────┐        ┌─────────────────┐  │
        │  │  Web Pods     │        │   App Pods      │  │
        │  │  (Public)    │  --->  │  (Private)      │  │
        │  │  Nginx/UI    │        │  FastAPI        │  │
        │  └──────────────┘        └─────────┬───────┘  │
        │                                      │          │
        └──────────────────────────────────────┼──────────┘
                                               │
                                   ┌───────────▼───────────┐
                                   │        Amazon RDS       │
                                   │     (Private Subnet)    │
                                   │   Credentials via SM    │
                                   └────────────────────────┘
