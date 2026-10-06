output "nat_public_ip" {
  description = "Public IP of the fck-nat instance (egress IP)"
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

output "ssh_command_k3s_a" {
  description = "SSH into K3s node A via the NAT/bastion path (use SSM or VPN; example assumes direct routing)"
  value       = "ssh -i <key.pem> ubuntu@${aws_instance.k3s_a.private_ip}"
}
