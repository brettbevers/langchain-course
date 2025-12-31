# DB Subnet Group
resource "aws_db_subnet_group" "airbyte" {
  name_prefix = "${local.name_prefix}-db-"
  subnet_ids  = aws_subnet.private[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-subnet-group"
    }
  )
}

# Random password for RDS
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "${local.name_prefix}-db-password-"
  description = "RDS master password for Airbyte"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.airbyte.address
    port     = aws_db_instance.airbyte.port
    dbname   = var.db_name
  })
}

# RDS Instance
resource "aws_db_instance" "airbyte" {
  identifier_prefix = "${local.name_prefix}-db-"

  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432

  multi_az               = var.db_multi_az
  db_subnet_group_name   = aws_db_subnet_group.airbyte.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  skip_final_snapshot       = local.env != "prod"
  final_snapshot_identifier = local.env == "prod" ? "${local.name_prefix}-db-final-snapshot" : null

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db"
    }
  )
}
