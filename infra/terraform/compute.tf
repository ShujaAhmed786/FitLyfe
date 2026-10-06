# ---------------------------------------------------------------------------
# Compute: 2x K3s nodes (AZ-A/B) + 2x Postgres/Valkey nodes (AZ-A/B)
# ---------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# Shared cluster token for K3s node join
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

# --- K3s node A (AZ-A): cluster init ---------------------------------------
resource "aws_instance" "k3s_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.k3s_instance_type
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname fitlyfe-k3s-a
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
      --cluster-init \
      --token ${random_password.k3s_token.result} \
      --disable traefik" sh -
    # Kubeconfig for admin use
    mkdir -p /home/ubuntu/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
    chown -R ubuntu:ubuntu /home/ubuntu/.kube
  EOF

  tags = { Name = "${var.project}-k3s-a" }
}

# --- K3s node B (AZ-B): joins node A ---------------------------------------
resource "aws_instance" "k3s_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.k3s_instance_type
  subnet_id              = aws_subnet.private_b.id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname fitlyfe-k3s-b
    # Wait for node A API to come up before joining
    for i in $(seq 1 60); do
      curl -sk https://${aws_instance.k3s_a.private_ip}:6443/readyz && break
      sleep 10
    done
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
      --server https://${aws_instance.k3s_a.private_ip}:6443 \
      --token ${random_password.k3s_token.result} \
      --disable traefik" sh -
  EOF

  depends_on = [aws_instance.k3s_a]

  tags = { Name = "${var.project}-k3s-b" }
}

# --- DB/cache nodes ---------------------------------------------------------
# Postgres 16 + Valkey installed; data disk mounted at /data.
# NOTE: primary/standby replication (pg_basebackup + replication slot) and
# Valkey replica/sentinel config are finished as a post-apply step (see README).

resource "aws_ebs_volume" "db_data_a" {
  availability_zone = var.az_a
  size              = var.db_data_volume_size
  type              = "gp3"

  tags = { Name = "${var.project}-db-data-a" }
}

resource "aws_ebs_volume" "db_data_b" {
  availability_zone = var.az_b
  size              = var.db_data_volume_size
  type              = "gp3"

  tags = { Name = "${var.project}-db-data-b" }
}

resource "aws_instance" "db_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname fitlyfe-db-a
    apt-get update -qq
    apt-get install -y -qq postgresql-16 valkey
    # Mount data disk
    mkfs.ext4 -F /dev/sdh || true
    mkdir -p /data
    grep -q /dev/sdh /etc/fstab || echo "/dev/sdh /data ext4 defaults,nofail 0 2" >> /etc/fstab
    mount -a || true
    systemctl enable --now postgresql valkey-server || true
  EOF

  tags = { Name = "${var.project}-db-a" }
}

resource "aws_instance" "db_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private_b.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    hostnamectl set-hostname fitlyfe-db-b
    apt-get update -qq
    apt-get install -y -qq postgresql-16 valkey
    mkfs.ext4 -F /dev/sdh || true
    mkdir -p /data
    grep -q /dev/sdh /etc/fstab || echo "/dev/sdh /data ext4 defaults,nofail 0 2" >> /etc/fstab
    mount -a || true
    systemctl enable --now postgresql valkey-server || true
  EOF

  tags = { Name = "${var.project}-db-b" }
}

resource "aws_volume_attachment" "db_data_a" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.db_data_a.id
  instance_id = aws_instance.db_a.id
}

resource "aws_volume_attachment" "db_data_b" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.db_data_b.id
  instance_id = aws_instance.db_b.id
}
