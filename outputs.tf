# -----------------------------------------------------------------------------
# outputs.tf
# Valores expuestos para otros proyectos Terraform, orquestadores (Airflow) o CI.
# -----------------------------------------------------------------------------

output "raw_bucket_name" {
  description = "Nombre del bucket raw del data lake."
  value       = aws_s3_bucket.raw.bucket
}

output "raw_bucket_arn" {
  description = "ARN del bucket raw (para políticas IAM de Flink/Glue)."
  value       = aws_s3_bucket.raw.arn
}

output "name_prefix" {
  description = "Prefijo de nombres aplicado a los recursos de este entorno."
  value       = local.name_prefix
}
