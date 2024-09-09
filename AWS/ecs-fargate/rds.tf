variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 20
}

resource "aws_db_subnet_group" "rds_dbeaver_db_subnet" {

  depends_on = [
    aws_vpc.cloudbeaver_net,
    aws_subnet.private_subnets
  ]
  name       = "rds_dbeaver_db_subnet"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id] 

  tags = merge(var.common_tags, { Name = "Cloudbeaver Database subnet" })
}

resource "aws_db_instance" "rds_dbeaver_db" { 

  depends_on = [
    aws_vpc.cloudbeaver_net,
    aws_subnet.private_subnets
  ]

  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp2"
  engine               = var.rds_db_type
  engine_version       = var.rds_db_version
  instance_class       = var.db_instance_class
  db_name              = var.cloudbeaver-db-env[2].value
  username             = var.cloudbeaver-db-env[1].value
  password             = var.cloudbeaver-db-env[0].value
  db_subnet_group_name = aws_db_subnet_group.rds_dbeaver_db_subnet.name
  vpc_security_group_ids = [aws_security_group.cloudbeaver_te_private.id]
  skip_final_snapshot  = true

  tags = merge(var.common_tags, { Name = "Cloudbeaver Database" })
}
