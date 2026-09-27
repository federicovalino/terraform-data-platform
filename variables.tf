# -----------------------------------------------------------------------------
# variables.tf
# Inputs del proyecto. Todas tienen type + description, y validacion donde aplica.
# -----------------------------------------------------------------------------

variable "region" {
  description = "Región de AWS donde se despliega la plataforma (ej: us-east-1, sa-east-1)."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "La región debe tener formato AWS válido, ej: us-east-1."
  }
}

variable "project_name" {
  description = "Nombre corto del proyecto. Se usa como prefijo en todos los recursos."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name: 3-21 caracteres, minúsculas, números o guiones, empezando con letra."
  }
}

variable "environment" {
  description = "Entorno de despliegue."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser uno de: dev, staging, prod."
  }
}

variable "owner" {
  description = "Equipo o persona responsable de los recursos (tag Owner)."
  type        = string
}

variable "cost_center" {
  description = "Centro de costos para imputar el gasto de la plataforma (tag CostCenter)."
  type        = string
}
