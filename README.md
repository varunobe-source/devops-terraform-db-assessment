# DevOps Assessment – Terraform + Database Reliability

This repository contains a DevOps assessment implementation covering AWS infrastructure provisioning with Terraform, containerized PostgreSQL, database migrations and seed data, backup/restore, and Terraform validation through GitHub Actions.

## Architecture

```text
Internet
   |
   v
Application Load Balancer
   |
   v
ECS Fargate
Private Subnets
   |
   v
Amazon RDS PostgreSQL
Private Subnets
```

### Network Design

* One VPC per environment
* Two public subnets across two Availability Zones
* Two private subnets across two Availability Zones
* Internet Gateway for public subnets
* NAT Gateway for private subnet outbound access
* ALB deployed in public subnets
* ECS Fargate tasks deployed in private subnets
* RDS PostgreSQL deployed in private subnets

### Security Groups

Traffic is restricted between application layers:

* **ALB SG:** Allows HTTP traffic from the internet.
* **ECS SG:** Allows application traffic only from the ALB security group.
* **RDS SG:** Allows PostgreSQL traffic only from the ECS security group.

RDS is not publicly accessible.

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── database/
│   ├── migrations/
│   │   └── 001_schema.sql
│   └── seed/
│       ├── 002_seed.sql
│       └── 003_booking_events.sql
│
├── infra/
│   ├── modules/
│   │   ├── network/
│   │   ├── ecs/
│   │   └── rds/
│   │
│   └── envs/
│       ├── dev/
│       └── prod/
│
├── scripts/
│   ├── backup.sh
│   └── restore.sh
│
├── docker-compose.yml
├── .gitignore
└── README.md
```

---

# Terraform

Terraform is organized using reusable modules.

### Modules

* `network` – VPC, subnets, routing, Internet Gateway and NAT Gateway
* `ecs` – ALB, ECS cluster, task definition, service, security groups and logging
* `rds` – PostgreSQL RDS instance, subnet group and database security group

### Environments

Dev and Prod have separate Terraform configurations and state files.

| Setting             | Dev         | Prod        |
| ------------------- | ----------- | ----------- |
| ECS desired count   | 1           | 2           |
| RDS instance        | db.t3.micro | db.t3.small |
| Storage             | 20 GB       | 50 GB       |
| Backup retention    | 1 day       | 7 days      |
| Deletion protection | Disabled    | Enabled     |
| Multi-AZ RDS        | Disabled    | Enabled     |

The environment-specific values are provided through `terraform.tfvars` locally. Example configuration is available as:

```text
infra/envs/dev/terraform.tfvars.example
infra/envs/prod/terraform.tfvars.example
```

Real `terraform.tfvars` files are excluded from Git to prevent credentials/secrets from being committed.

---

# Terraform Validation

Run from each environment directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan -refresh=false -var-file="terraform.tfvars"
```

For the assessment repository, the example variable files can be used for plan validation:

```bash
terraform plan -refresh=false -var-file="terraform.tfvars.example"
```

No AWS infrastructure deployment is required for the assessment.

---

# GitHub Actions

The workflow is located at:

```text
.github/workflows/terraform.yml
```

It runs Terraform checks for both `dev` and `prod` on pull requests and pushes to `main`.

The workflow performs:

1. Checkout
2. Terraform setup
3. Terraform formatting check
4. Terraform initialization
5. Terraform validation
6. Terraform plan

The workflow is plan-only and does not deploy AWS resources.

---

# Local PostgreSQL

PostgreSQL 16 is provided through Docker Compose.

Start the database:

```bash
docker compose up -d
```

Verify the database:

```bash
docker exec -it hotel-bookings-db psql -U postgres -d hotel_booking -c "SELECT version();"
```

Database:

```text
Database: hotel_booking
User: postgres
Port: 5432
```

---

# Database Schema

## hotel_bookings

Stores hotel booking information.

Important fields include:

* `id`
* `org_id`
* `hotel_id`
* `city`
* `checkin_date`
* `checkout_date`
* `amount`
* `status`
* `created_at`

## booking_events

Stores booking-related events.

Important fields include:

* `id`
* `booking_id`
* `event_type`
* `payload`
* `created_at`

`booking_events.booking_id` has a foreign key relationship with `hotel_bookings.id`.

---

# Migration and Seed Data

Run the schema migration:

```bash
Get-Content .\database\migrations\001_schema.sql | docker exec -i hotel-bookings-db psql -U postgres -d hotel_booking
```

Seed 100 bookings:

```bash
Get-Content .\database\seed\002_seed.sql | docker exec -i hotel-bookings-db psql -U postgres -d hotel_booking
```

Seed booking events:

```bash
Get-Content .\database\seed\003_booking_events.sql | docker exec -i hotel-bookings-db psql -U postgres -d hotel_booking
```

The seed data contains multiple organizations, cities and booking statuses.

---

# Query Optimization

The assessment query filters by `city` and `created_at`:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

The following composite index was added:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
ON hotel_bookings (city, created_at);
```

This index supports the filtering pattern used by the query by allowing PostgreSQL to efficiently locate rows based on city and creation time.

An index was also added on:

```text
booking_events.booking_id
```

to improve lookups of events belonging to a booking.

---

# Backup and Restore

Backup script:

```text
scripts/backup.sh
```

It creates timestamped PostgreSQL SQL dumps under:

```text
backups/
```

Example:

```bash
./scripts/backup.sh
```

Restore script:

```text
scripts/restore.sh
```

Usage:

```bash
./scripts/restore.sh <backup-file>
```

The restore process creates a fresh database named:

```text
hotel_booking_restore
```

and imports the backup into it.

The backup/restore process was verified locally by restoring the database and confirming the seeded booking and event counts.

---

# Reliability Considerations

The implementation includes several reliability controls:

* RDS automated backups
* Different backup retention for Dev and Prod
* RDS deletion protection enabled in Prod
* Multi-AZ RDS enabled in Prod
* Private RDS networking
* Security-group based database access
* Timestamped database backups
* Restore into a separate database for verification
* Terraform validation through CI

For a production deployment, the Terraform state backend could be moved from the local backend used in this assessment to a remote, encrypted backend such as Amazon S3 with appropriate locking/state-management controls.

---

# Validation Summary

The following checks were completed successfully:

* Terraform formatting
* Terraform initialization
* Terraform validation
* Dev Terraform plan
* Prod Terraform plan
* Docker Compose PostgreSQL startup
* Database schema creation
* 100 booking records seeded
* Booking events seeded
* Query/index implementation
* PostgreSQL backup creation
* Backup restoration
* Restored database verification
* GitHub Actions Terraform workflow

## Notes

This repository is designed as an assessment implementation. AWS infrastructure is not deployed as part of the submission; Terraform plans are used to validate the infrastructure configuration.
