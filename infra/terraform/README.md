# FitLyfe Infrastructure (Terraform)

Provisions the AWS side of the FitLyfe production setup in `us-east-1`:

- VPC (`10.0.0.0/16`), 1 public subnet (AZ-A), 2 private subnets (AZ-A/B)
- **fck-nat** (`t4g.nano`, ~$3/mo) instead of a managed NAT Gateway (~$32/mo)
- **2x K3s nodes** (`t4g.small`, one per AZ) with K3s bootstrapped via `user_data`
- **2x Postgres 16 + Valkey nodes** (`t4g.small`, one per AZ) with a data disk each
- **Encrypted S3 bucket** for WAL archives (pgBackRest) and DB dumps, with lifecycle expiry
- Security groups: DB/Valkey reachable only from K3s nodes

Expected cost: **~$46/mo** (see cost notes in the app repo).

## Usage

```bash
cd infra/terraform
terraform init

# Required: an EC2 key pair for SSH
terraform plan -var="key_name=fitlyfe-key"

terraform apply -var="key_name=fitlyfe-key"
```

Tighten `admin_ssh_cidr` to your IP in `terraform.tfvars`:

```hcl
key_name       = "fitlyfe-key"
admin_ssh_cidr = "203.0.113.10/32"
```

## After `terraform apply`

1. **K3s**: node B joins node A automatically (token via `random_password`).
   Copy kubeconfig: `scp -i <key> ubuntu@<k3s-a-ip>:/home/ubuntu/.kube/config ~/.kube/fitlyfe`
2. **Install cluster services** (via Helm):
   `ingress-nginx`, `argocd`, `kube-prometheus-stack`, `cloudflared` (tunnel token from Cloudflare)
3. **Postgres/Valkey replication** (not yet automated): on `db-a`, create a
   replication role; on `db-b`, `pg_basebackup` from `db-a` and configure
   `primary_conninfo`. Point Valkey on `db-b` at `db-a` as replica and add
   Sentinel. Move `/var/lib/postgresql` and Valkey data to `/data`.
4. **Secrets**: `kubectl -n fitlyfe create secret generic fitlyfe-db --from-literal=...`
   (see `k8s/secret.README` in the repo root)
5. **ArgoCD**: `kubectl apply -f argocd/app.yaml -n argocd` (update `repoURL` if
   your GitHub repo name differs), then the pipeline owns deploys from there.
6. **DNS**: point your domain at Cloudflare; the tunnel routes to ingress-nginx.

## Tear down

```bash
terraform destroy -var="key_name=fitlyfe-key"
```

Note: the S3 bucket must be emptied before destroy (versioning is on).
