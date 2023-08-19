
resource "aws_instance" "project-webserver" {
    ami = var.ec2-ami
    instance_type = "t2.micro"
    key_name = "tf-ec2"
    security_groups = [var.sg-name]
    tags = {
      Name = "project-webserver"
    }
  
}


resource "aws_db_instance" "project-rds-mysql" {
  name = "project_rds_mysql"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.33"
  vpc_security_group_ids = ["${aws_security_group.project_rds_sg.id}"]
  publicly_accessible = true
  skip_final_snapshot = true
  username             = var.db_username
  password             = var.db_password
  tags = {
      Name = "project-db"
  }

}

resource "aws_security_group" "project_rds_sg" {
  name = var.rds_security_group_name
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = [var.pc_ipv4_cidr, var.ec2_ipv4_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.pc_ipv4_cidr, var.ec2_ipv4_cidr]
  }
}

resource "tls_private_key" "terraform_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  key_name   = "tf-ec2"

  public_key = tls_private_key.terraform_generated_private_key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terraform_generated_private_key.private_key_pem}' > tf-ec2.pem
      chmod 400 tf-ec2.pem
    EOT
  }
}
