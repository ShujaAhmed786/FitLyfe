# ---------------------------------------------------------------------------
# fck-nat: $3/mo NAT instance replacing the $32/mo managed NAT Gateway
# AMI resolved via data source (owner 568608671756, arm64, AL2023)
# ---------------------------------------------------------------------------

data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["568608671756"]

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "${var.project}-nat-eip" }
}

resource "aws_network_interface" "nat" {
  subnet_id         = aws_subnet.public_a.id
  security_groups   = [aws_security_group.nat.id]
  source_dest_check = false # required: instance routes traffic for others

  tags = { Name = "${var.project}-nat-eni" }
}

resource "aws_eip_association" "nat" {
  allocation_id        = aws_eip.nat.id
  network_interface_id = aws_network_interface.nat.id
}

resource "aws_instance" "nat" {
  ami           = data.aws_ami.fck_nat.id
  instance_type = var.nat_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.nat.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = { Name = "${var.project}-fck-nat" }
}

# Private subnets route egress through the fck-nat instance
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat.id

  depends_on = [aws_instance.nat]
}
