# -----------------------------------------------------------------------------
# terraform.tfvars — valores de ejemplo para el entorno dev.
# Terraform lo carga automáticamente en plan/apply.
# NO poner secretos acá (credenciales, passwords): usar variables de entorno
# o AWS Secrets Manager.
# -----------------------------------------------------------------------------

region              = "us-east-1"
project_name        = "segmentacion"
environment         = "dev"
owner               = "data-engineering"
cost_center         = "cc-data-001"
