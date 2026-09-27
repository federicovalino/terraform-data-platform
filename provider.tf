# -----------------------------------------------------------------------------
# provider.tf
# Versiones de Terraform y providers + configuración del provider de AWS.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # acepta 6.x, bloquea un salto automático a 7.0
    }
  }

}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
