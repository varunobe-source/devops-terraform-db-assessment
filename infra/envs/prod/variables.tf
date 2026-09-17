variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "ecs_desired_count" {
  type = number
}

variable "rds_instance_class" {
  type = string
}

variable "rds_allocated_storage" {
  type = number
}

variable "rds_backup_retention_period" {
  type = number
}

variable "rds_deletion_protection" {
  type = bool
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}