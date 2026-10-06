variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for tagging"
  type        = string
  default     = "fitlyfe"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_a" {
  description = "First availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "az_b" {
  description = "Second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "k3s_instance_type" {
  description = "K3s node instance type (Graviton). Diagram showed t4g.medium; rightsized to t4g.small per cost review."
  type        = string
  default     = "t4g.small"
}

variable "db_instance_type" {
  description = "Postgres/Valkey node instance type (Graviton)"
  type        = string
  default     = "t4g.small"
}

variable "nat_instance_type" {
  description = "fck-nat instance type"
  type        = string
  default     = "t4g.nano"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB (gp3) for all instances"
  type        = number
  default     = 15
}

variable "db_data_volume_size" {
  description = "Dedicated data EBS volume size in GB (gp3) for DB nodes"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "admin_ssh_cidr" {
  description = "CIDR allowed to SSH to instances. Restrict this to your IP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "backup_bucket_name" {
  description = "S3 bucket name for DB backups. Leave empty to auto-generate."
  type        = string
  default     = ""
}
