# Fit Lyfe | Smart Calorie & Nutrition Tracker ðŸ¥—ðŸ“Š

**Fit Lyfe** is a feature-rich, privacy-focused mobile application built with **Flutter** designed to make calorie tracking, meal planning, and health monitoring effortless, engaging, and lightning-fast. 

Whether your goal is to lose weight, build muscle, or maintain a balanced lifestyle, Fit Lyfe provides all the tools you need right on your device.

---

## Key Features

* **Calorie Tracker & Food Log:** Effortlessly log daily meals, snacks, and drinks with dynamic smart group emojis (automatically adapting for Breakfast, Lunch, Dinner, Protein, and Drinks) across your logs and screens.
* **Extensive Food Library:** Browse and search a robust database of food items powered by the USDA API to quickly find nutritional breakdowns and add your favorite meals.
* **Macro Counter:** Seamlessly monitor proteins, carbohydrates, and fats to stay precisely on target with your health and fitness goals.
* **Gamified Ranking System:** Stay motivated throughout your health journey by tracking your progress and leveling up through an engaging rank structure.
* **Daily Quick Tips:** Access bite-sized, actionable health, nutrition, and wellness tips right when you need them to build sustainable habits.
* **Persistent Undo & Local Backup:** Safeguard your data with local storage handling and a reliable 2-hour reset "undo" window that survives app restarts.
* **Built-in Feedback Mechanism:** Easily submit in-app feedback to help continuously improve the app experience.
* **Local Privacy First:** All personal health logs, custom meal lists, and user data remain stored securely right on your device.

---

## Tech Stack & Architecture

* **Framework:** Flutter & Dart
* **Data Management:** Local storage handling with robust state management and backup protocols
* **API Integration:** USDA API injected securely during builds via `--dart-define`
* **UI/UX:** Clean, distraction-free design with responsive layouts and dynamic visual indicators

---

## Getting Started (Development Setup)

To run this project locally, make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

1. **Clone the repository:**
       ```bash
     git clone [https://github.com/your-username/fit-lyfe.git](https://github.com/your-username/fit-lyfe.git)
     cd fit-lyfe
     Run the app (injecting your USDA API key):
     flutter run --dart-define=USDA_API_KEY=your_actual_api_key_here
   
3. Install dependencies:
     flutter pub get

4. Build & Release
     To generate an optimized Android App Bundle (.aab) for testing or deployment:
     flutter build appbundle --dart-define=USDA_API_KEY=your_actual_api_key_here

---

## DevOps Deployment

This project is deployed on AWS with a full CI/CD pipeline.

### Architecture

![FitLyfe Deployment Flow](docs/screenshots/fitlyfe-deployment-flow.png)

### App Screenshots

### Add Meal
<img src="docs/screenshots/02-add-meal-enhanced.jpg" width="300" alt="Add Meal">

### My Meals
<img src="docs/screenshots/03-meals-list-enhanced.jpg" width="300" alt="My Meals">

### Activity Logs
<img src="docs/screenshots/04-activity-logs-enhanced.jpg" width="300" alt="Activity Logs">

### CI/CD Pipeline

GitHub Actions builds the Docker image, scans it with Trivy, and pushes to GHCR. ArgoCD syncs the manifests to the K3s cluster.

![CI Runs](docs/screenshots/ci-runs-list.png)

![CI Job Details](docs/screenshots/ci-job-details.png)

### ArgoCD GitOps

ArgoCD syncs the Kubernetes manifests from GitHub to the K3s cluster automatically on every push.

![ArgoCD Dashboard](docs/screenshots/argocd-dashboard.png)

### Infrastructure

- **Cloud:** AWS (us-east-1)
- **Kubernetes:** K3s on EC2 (ARM64 Graviton)
- **Database:** PostgreSQL 14 + Redis
- **CI/CD:** GitHub Actions + ArgoCD GitOps
- **IaC:** Terraform
- **Access:** Cloudflare Tunnel

### Cost Breakdown

Monthly cost comparison (us-east-1, 730 hours/month):

| Cost Line Item | Right-Sized On-Demand |
|----------------|----------------------|
| K3s Cluster Compute | 2x t4g.small : $16.35 |
| DB / Cache Compute | 2x t4g.small : $16.35 |
| Egress NAT Compute | 1x t4g.nano (fck-nat) : $3.07 |
| Public IPv4 Allocation | 1x Elastic IP : $3.65 |
| EBS Disks (gp3) | 5x 15GB (75GB) : $6.00 |
| AWS S3 Backups | pgBackRest + Valkey : ~- **Access:** Cloudflare Tunnel.50 |
| Cloudflare Ingress | Zero-Trust Tunnel : - **Access:** Cloudflare Tunnel.00 |
| CI Runner Compute | GitHub Actions Free Tier : - **Access:** Cloudflare Tunnel.00 |
| **Total Monthly Spend** | **~$45.92 / mo** |

**Cost-saving decisions:**
- ARM64 Graviton (t4g) instances instead of x86
- fck-nat (self-managed) instead of AWS NAT Gateway
- K3s instead of EKS (no control plane fee)
- Self-hosted PostgreSQL/Redis instead of RDS
- Cloudflare Tunnel instead of AWS Load Balancer

---

## Running in Production

### Prerequisites

- AWS account with IAM credentials
- Terraform >= 1.0
- kubectl
- GitHub account (for CI/CD)

### 1. Provision Infrastructure

```bash
cd infra/terraform
terraform init
terraform apply
```

This creates:
- VPC with public/private subnets across 2 AZs
- 2x K3s nodes (t4g.small, ARM64)
- 2x Database nodes (t4g.small, PostgreSQL + Redis)
- NAT instance (fck-nat)
- S3 backup bucket
- Security groups and IAM roles

### 2. Configure Database

SSH into the primary DB node and run:

```bash
sudo -u postgres psql
CREATE USER fitlyfe WITH PASSWORD 'your-secure-password';
CREATE DATABASE fitlyfe OWNER fitlyfe;
```

Update `postgresql.conf`:
```
listen_addresses = 'your-db-private-ip'
```

Add to `pg_hba.conf`:
```
host all all 10.0.0.0/16 md5
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### 3. Create Kubernetes Secret

```bash
kubectl create namespace fitlyfe
kubectl create secret generic fitlyfe-db -n fitlyfe \
  --from-literal=host=10.0.11.20 \
  --from-literal=port=5432 \
  --from-literal=database=fitlyfe \
  --from-literal=username=fitlyfe \
  --from-literal=password='your-secure-password'
```

### 4. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 5. Deploy via ArgoCD

Apply the ArgoCD application manifest:

```bash
kubectl apply -f argocd/app.yaml
```

ArgoCD will automatically sync the Kubernetes manifests from the `k8s/` directory.

### 6. CI/CD Pipeline

Push to `main` branch to trigger GitHub Actions:
1. Builds ARM64 Docker image
2. Scans with Trivy for vulnerabilities
3. Pushes to GitHub Container Registry
4. ArgoCD detects new image and deploys

### 7. Expose via Cloudflare Tunnel

```bash
kubectl apply -f k8s/cloudflared.yaml
```

This creates a secure tunnel for public access without a load balancer.

### Architecture Summary

```
GitHub â†’ Actions (build/scan/push) â†’ GHCR
   â†“
ArgoCD â†’ K3s Cluster (2 AZs)
   â†“
ingress-nginx â†’ Cloudflare Tunnel â†’ Internet
   â†“
PostgreSQL + Redis (2 nodes, S3 backups)
```

### Cost

~$46/month on AWS (see Cost Breakdown section above).