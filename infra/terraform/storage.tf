# ---------------------------------------------------------------------------
# S3: encrypted bucket for Postgres WAL archives (pgBackRest) and DB dumps
# ---------------------------------------------------------------------------

resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "backups" {
  bucket = var.backup_bucket_name != "" ? var.backup_bucket_name : "${var.project}-db-backups-${random_pet.bucket_suffix.id}"

  tags = { Name = "${var.project}-db-backups" }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Expire old WAL archives; keep DB dumps for 90 days
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "expire-wal"
    status = "Enabled"

    filter {
      prefix = "wal/"
    }

    expiration {
      days = 30
    }
  }

  rule {
    id     = "expire-dumps"
    status = "Enabled"

    filter {
      prefix = "dumps/"
    }

    expiration {
      days = 90
    }
  }
}
