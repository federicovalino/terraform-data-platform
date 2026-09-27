# -----------------------------------------------------------------------------
# main.tf
# Recursos principales de la plataforma de datos.
# -----------------------------------------------------------------------------

# =============================================================================
# Storage: bucket "raw" del data lake (destino de la ingesta)
# Nombre: <project>-<env>-raw-<account_id>  (los buckets S3 son globales,
# el account_id garantiza unicidad sin hardcodear nada)
# =============================================================================
resource "aws_s3_bucket" "raw" {
  bucket = "${local.name_prefix}-raw-${local.account_id}"

  tags = {
    DataDomain = "raw"
  }

  # En prod conviene cambiarlo a true para proteger datos históricos.
  # (prevent_destroy no acepta variables: debe ser un literal)
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id # referencia, no ARN/nombre hardcodeado

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "raw" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
