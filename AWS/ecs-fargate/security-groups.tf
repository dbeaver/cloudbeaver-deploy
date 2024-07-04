resource "aws_security_group" "cloudbeaver_alb" {
  name   = "cloudbeaver-sg-alb"
  vpc_id = aws_vpc.cloudbeaver_net.id
  description = "Cloudbeaver ECS Default SG"

  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.common_tags, { Name = "Cloudbeaver ALB SG" })
}

resource "aws_security_group" "cloudbeaver_te_private" {
  name   = "ecs-cloudbeaver-service-postgres"
  vpc_id = aws_vpc.cloudbeaver_net.id
  description = "Cloudbeaver ECS Postgres SG"

  ingress {
    protocol         = "tcp"
    from_port        = 5432
    to_port          = 5432
    cidr_blocks = var.private_subnet_cidrs
  }

   ingress {
    protocol         = "tcp"
    from_port        = 9092
    to_port          = 9093
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cloudbeaver_efs" {
  name   = "ecs-Cloudbeaver-efs-sg"
  vpc_id = aws_vpc.cloudbeaver_net.id
  description = "Cloudbeaver EFS SG"

  ingress {
   protocol         = "tcp"
   from_port        = 2049
   to_port          = 2049
   cidr_blocks = var.private_subnet_cidrs
   description = "Allow NFS traffic - TCP 2049"
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "Cloudbeaver EFS SG" })
}

resource "aws_security_group" "cloudbeaver" {
  name   = "ecs-cloudbeaver-service-sg"
  vpc_id = aws_vpc.cloudbeaver_net.id
  description = "Cloudbeaver ECS SG"

  ingress {
   protocol         = "tcp"
   from_port        = 8970
   to_port          = 8980
   cidr_blocks = concat(var.private_subnet_cidrs, var.public_subnet_cidrs)
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.common_tags, { Name = "Cloudbeaver service SG" })
}