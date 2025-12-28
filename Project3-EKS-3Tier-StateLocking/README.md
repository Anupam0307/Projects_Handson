This project demonstrates a basic 3-tier application on AWS EKS, provisioned using Terraform and deployed with Helm, following real-world networking and security practices.

#### Architecture Summary ####

- Web Layer
  - Internet-facing
  - Exposed using Kubernetes Service type: LoadBalancer

- App Layer
  - Private, internal service
  - Exposed via ClusterIP

- DB Layer
  - Private, internal service
  - Exposed via ClusterIP

Only the web layer is publicly accessible.The app and database layers remain isolated inside the cluster.

#### Tech Stack ####

- AWS EKS
- Terraform (with S3 backend + DynamoDB state locking)
- Helm (web, app, db charts)
- GitHub Actions (CI/CD)
- Docker
- Kubernetes

#### Key Highlights ####

- Remote Terraform state with DynamoDB locking
- Proper 3-tier separation
- LoadBalancer used only for web
- App & DB are private by design

#### Testing ####

After deployment: kubectl get svc
Access the application via the web LoadBalancer endpoint.