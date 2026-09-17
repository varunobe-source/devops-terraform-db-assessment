output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}