# Terraform Data Platform — Scaffolding

Esqueleto de un proyecto Terraform para una plataforma de datos en AWS que eventualmente incluirá **Kinesis** (ingesta), **Apache Flink** (procesamiento en ventanas) y **Redshift** (analítica). Hoy despliega solo un bucket S3 "raw" como recurso de ejemplo.

## Estructura

```
.
├── provider.tf        # Versión de Terraform (>= 1.5), provider AWS (~> 6.0), default_tags, backend (comentado)
├── variables.tf       # Inputs tipados, con descripción y validaciones
├── locals.tf          # Convención de nombres y tags comunes
├── main.tf            # Recursos: bucket S3 raw + placeholders de Kinesis y Flink
├── outputs.tf         # Valores expuestos (nombre/ARN del bucket, prefijo)
├── terraform.tfvars   # Valores de ejemplo para dev (sin secretos)
├── .gitignore         # Excluye .terraform/, *.tfstate, planes y overrides
└── README.md
```

## Requisitos

- Terraform >= 1.5
- Credenciales de AWS configuradas (`aws configure`, `AWS_PROFILE` o SSO). **Nunca** en el código ni en `.tfvars`.

## Cómo inicializar y usar

```bash
git clone <url-del-repo> && cd terraform-data-platform

terraform init        # descarga el provider de AWS y genera .terraform.lock.hcl
terraform fmt -check  # verifica formato
terraform validate    # valida sintaxis y tipos

terraform plan -out=tfplan   # revisar SIEMPRE el diff (+ ~ -) antes de aplicar
terraform apply tfplan

terraform destroy     # solo para entornos efímeros (dev / pruebas)
```

Para otro entorno, se pasa un archivo de variables distinto:

```bash
terraform plan -var-file=prod.tfvars
```

> El `.terraform.lock.hcl` **sí** se commitea: fija las versiones exactas de los providers para todo el equipo.

## Convención de nombres

Todos los recursos siguen el patrón:

```
<project>-<environment>-<componente>[-<sufijo>]
```

| Recurso | Ejemplo (dev) |
|---|---|
| Bucket S3 raw | `segmentacion-dev-raw-123456789012` |
| Kinesis stream | `segmentacion-dev-ingesta-stream` |
| App de Flink | `segmentacion-dev-segmentacion-flink` |

- Solo minúsculas, números y guiones (compatible con las reglas de S3 y del resto de servicios).
- El prefijo `<project>-<environment>` se calcula una sola vez en `locals.tf` (`local.name_prefix`), así nadie lo arma a mano.
- Los buckets S3 llevan el **account ID** como sufijo porque sus nombres son globales en AWS; se obtiene con `data.aws_caller_identity`, sin hardcodear.
- `project_name` y `environment` tienen validaciones: un typo (`prd`, `Produccion`) falla en `plan`, no en producción.

### Tags obligatorios

Aplicados a **todos** los recursos vía `default_tags` del provider: `Project`, `Environment`, `Owner`, `CostCenter`, `ManagedBy = terraform`. En streaming los costos escalan rápido; esto permite imputarlos por equipo y entorno.

## Por qué varios archivos y no un único `main.tf`

Terraform lee todos los `.tf` del directorio como un solo módulo, así que la división no cambia el comportamiento: es una decisión **de mantenimiento**.

1. **Separación de responsabilidades.** Cada archivo responde una sola pregunta: *¿con qué se conecta?* (`provider.tf`), *¿qué se puede configurar?* (`variables.tf`), *¿qué se crea?* (`main.tf`), *¿qué expone?* (`outputs.tf`).
2. **Interfaz clara del módulo.** `variables.tf` + `outputs.tf` son el "contrato": quien consume el proyecto (otro equipo, Airflow, un pipeline de CI) no necesita leer los recursos.
3. **Código igual en todos los entornos.** Los valores viven en `.tfvars`; dev, staging y prod despliegan exactamente el mismo código con distinto tamaño (ej. 1 vs 50 shards). Esto ataca directamente la inconsistencia y el drift del Click-Ops.
4. **Code reviews más simples.** Un PR que solo cambia `provider.tf` (subir versión del provider) es fácil de aislar y revisar, y genera menos conflictos de merge.
5. **Convención estándar.** Es la estructura que recomienda HashiCorp; cualquier ingeniero nuevo sabe dónde buscar.
6. **`locals.tf` aparte** centraliza nombres y tags, evitando que cada recurso los repita (y los escriba distinto).

A medida que crezca, el siguiente paso es separar en **estados pequeños** por dominio (red, IAM, Kinesis, Flink, Redshift) o en módulos reutilizables, para reducir el *blast radius*.

## Buenas prácticas aplicadas

- `*.tfstate` y `.terraform/` excluidos de git (el state puede contener secretos en texto plano).
- Referencias entre recursos (`aws_s3_bucket.raw.id`) en vez de ARNs hardcodeados → Terraform infiere dependencias.
- Bucket con versionado, cifrado y bloqueo de acceso público.
- `lifecycle { prevent_destroy }` preparado en el bucket: activarlo en prod.

## Próximos pasos

- [ ] Backend remoto en S3 con locking (bloque ya preparado en `provider.tf`).
- [ ] Descomentar el stream de Kinesis en `main.tf`.
- [ ] Rol IAM + aplicación de Managed Service for Apache Flink.
- [ ] `staging.tfvars` y `prod.tfvars` (región distinta por cumplimiento).
