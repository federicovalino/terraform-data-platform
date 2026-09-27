# -----------------------------------------------------------------------------
# locals.tf
# Valores derivados: convencin de nombres y tags comunes en un solo lugar.
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  # Prefijo estándar: <project>-<env>   ej: segmentacion-dev
  name_prefix = "${var.project_name}-${var.environment}"

  account_id = data.aws_caller_identity.current.account_id

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
  }
}
