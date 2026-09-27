# Terraform Data Platform — Scaffolding

Base scaffolding for a Terraform project that provisions an AWS data platform, which will eventually include **Kinesis** (ingestion), **Apache Flink** (windowed stream processing) and **Redshift** (analytics). For now it deploys a single S3 "raw" bucket as an example resource.

## Project structure

```
.
├── provider.tf        # Terraform version (>= 1.5), AWS provider (~> 6.0), default_tags, backend (commented out)
├── variables.tf       # Typed inputs with descriptions and validation rules
├── locals.tf          # Naming convention and common tags
├── main.tf            # Resources: raw S3 bucket + Kinesis and Flink placeholders
├── outputs.tf         # Exposed values (bucket name/ARN, name prefix)
├── terraform.tfvars   # Example values for dev (no secrets)
├── .gitignore         # Excludes .terraform/, *.tfstate, saved plans and overrides
└── README.md
```

## Requirements

- Terraform >= 1.5
- AWS credentials configured (`aws configure`, `AWS_PROFILE` or SSO). **Never** in the code or in `.tfvars` files.

## Getting started

```bash
git clone <repo-url> && cd terraform-data-platform

terraform init        # downloads the AWS provider and creates .terraform.lock.hcl
terraform fmt -check  # checks formatting
terraform validate    # validates syntax, types and references

terraform plan -out=tfplan   # ALWAYS review the diff (+ ~ -) before applying
terraform apply tfplan

terraform destroy     # only for ephemeral environments (dev / testing)
```

To target a different environment, pass a different variables file:

```bash
terraform plan -var-file=prod.tfvars
```

> `.terraform.lock.hcl` **should** be committed: it pins the exact provider versions for the whole team.

## Naming convention

Every resource follows this pattern:

```
<project>-<environment>-<component>[-<suffix>]
```

| Resource | Example (dev) |
|---|---|
| Raw S3 bucket | `segmentacion-dev-raw-123456789012` |
| Kinesis stream | `segmentacion-dev-ingesta-stream` |
| Flink application | `segmentacion-dev-segmentacion-flink` |

- Lowercase letters, numbers and hyphens only (compatible with S3 naming rules and every other service).
- The `<project>-<environment>` prefix is computed once in `locals.tf` (`local.name_prefix`), so nobody builds it by hand.
- S3 buckets get the **AWS account ID** as a suffix because bucket names are globally unique; it is read through `data.aws_caller_identity`, never hardcoded.
- `project_name` and `environment` have validation rules: a typo (`prd`, `Production`) fails at `plan` time, not in production.

### Mandatory tags

Applied to **every** resource through the provider's `default_tags`: `Project`, `Environment`, `Owner`, `CostCenter`, `ManagedBy = terraform`. Streaming costs can grow fast; these tags make it possible to allocate spend by team and environment.

## Why multiple files instead of a single `main.tf`

Terraform loads every `.tf` file in the directory as a single module, so splitting them does not change behavior. It is a **maintainability** decision:

1. **Separation of concerns.** Each file answers one question: *what do we connect to?* (`provider.tf`), *what can be configured?* (`variables.tf`), *what gets created?* (`main.tf`), *what is exposed?* (`outputs.tf`).
2. **A clear module interface.** `variables.tf` + `outputs.tf` act as the project's contract: consumers (another team, Airflow, a CI pipeline) don't need to read the resources.
3. **Same code across environments.** Values live in `.tfvars` files; dev, staging and prod deploy exactly the same code with different sizing (e.g. 1 vs 50 shards). This directly addresses the inconsistency and drift caused by Click-Ops.
4. **Simpler code reviews.** A PR that only touches `provider.tf` (e.g. a provider version bump) is easy to isolate and review, and produces fewer merge conflicts.
5. **Standard convention.** This is the layout recommended by HashiCorp; any new engineer knows where to look.
6. **A separate `locals.tf`** centralizes names and tags, so resources don't repeat them (or spell them differently).

As the platform grows, the next step is splitting it into **smaller states** per domain (network, IAM, Kinesis, Flink, Redshift) or into reusable modules, to reduce the *blast radius*.

## Best practices applied

- `*.tfstate` and `.terraform/` are excluded from git (state can contain secrets in plain text).
- References between resources (`aws_s3_bucket.raw.id`) instead of hardcoded ARNs, so Terraform infers dependencies.
- Bucket with versioning, encryption and public access blocked.
- `lifecycle { prevent_destroy }` ready on the bucket: enable it in prod.

## Next steps

- [ ] Remote backend on S3 with state locking (block already prepared in `provider.tf`).
- [ ] Uncomment the Kinesis stream in `main.tf`.
- [ ] IAM role + Managed Service for Apache Flink application.
- [ ] `staging.tfvars` and `prod.tfvars` (different region for compliance).
