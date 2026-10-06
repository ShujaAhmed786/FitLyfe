output "nat_public_ip" {
  description = "Public IP of the fck-nat instance (egress IP, also SSH jump host)"
  value       = aws_eip.nat.public_ip
}

output "k3s_node_a_private_ip" {
  description = "Private IP of K3s node A (AZ-A)"
  value       = aws_instance.k3s_a.private_ip
}

output "k3s_node_b_private_ip" {
  description = "Private IP of K3s node B (AZ-B)"
  value       = aws_instance.k3s_b.private_ip
}

output "db_node_a_private_ip" {
  description = "Private IP of Postgres/Valkey node A (primary)"
  value       = aws_instance.db_a.private_ip
}

output "db_node_b_private_ip" {
  description = "Private IP of Postgres/Valkey node B (standby)"
  value       = aws_instance.db_b.private_ip
}

output "backup_bucket" {
  description = "S3 bucket for WAL archives and DB dumps"
  value       = aws_s3_bucket.backups.id
}

# ---------------------------------------------------------------------------
# SSH access. Nodes sit in private subnets, so connections hop through the
# fck-nat instance (which doubles as the jump host). Run these from the
# infra/terraform directory so -i fitlyfe-key resolves.
# ---------------------------------------------------------------------------

output "ssh_nat" {
  description = "SSH directly to the NAT/jump host"
  value       = "ssh -i fitlyfe-key ec2-user@${aws_eip.nat.public_ip}"
}

output "ssh_k3s_a" {
  description = "SSH to K3s node A via the jump host"
  value       = "ssh -i fitlyfe-key -J ec2-user@${aws_eip.nat.public_ip} ubuntu@${aws_instance.k3s_a.private_ip}"
}

output "ssh_k3s_b" {
  description = "SSH to K3s node B via the jump host"
  value       = "ssh -i fitlyfe-key -J ec2-user@${aws_eip.nat.public_ip} ubuntu@${aws_instance.k3s_b.private_ip}"
}

output "ssh_db_a" {
  description = "SSH to Postgres/Valkey node A via the jump host"
  value       = "ssh -i fitlyfe-key -J ec2-user@${aws_eip.nat.public_ip} ubuntu@${aws_instance.db_a.private_ip}"
}

output "ssh_db_b" {
  description = "SSH to Postgres/Valkey node B via the jump host"
  value       = "ssh -i fitlyfe-key -J ec2-user@${aws_eip.nat.public_ip} ubuntu@${aws_instance.db_b.private_ip}"
}
