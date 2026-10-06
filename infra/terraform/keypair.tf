# ---------------------------------------------------------------------------
# EC2 key pair, imported from the local public key (fitlyfe-key.pub).
# The private key (fitlyfe-key) is gitignored and stays on your machine.
# ---------------------------------------------------------------------------

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file("${path.module}/fitlyfe-key.pub")

  tags = { Name = "${var.project}-keypair" }
}
