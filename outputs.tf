# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db-sample.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.db-sample.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.db-sample.username
  sensitive   = true
}
output "rds_password" {
  description = "RDS instance root username"
  value       = aws_db_instance.db-sample.password
  sensitive   = true
}


