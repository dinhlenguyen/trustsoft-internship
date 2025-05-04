resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group_internship_dinh"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "rds_subnet_group_internship_dinh"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg_internship_dinh"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.vpc_internship_dinh.id

  ingress {
    description     = "MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_internship_dinh.id]
    }

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_internship_dinh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg_internship_dinh"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "grayscale-metadata-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "grayscaledb"
  username               = "admin"
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  apply_immediately      = true

  tags = {
    Name = "rds_mysql_internship_dinh"
  }
}
