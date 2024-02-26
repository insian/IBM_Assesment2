resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"  # Make sure this CIDR block does not overlap with any other subnet
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"  # Make sure this CIDR block does not overlap with any other subnet
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_assoc_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_route_table_assoc_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "securitygroup" {
  name   = "SSH"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Security Group"
  }
}

resource "aws_security_group_rule" "http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic from any source
  security_group_id = aws_security_group.securitygroup.id
}

resource "aws_security_group_rule" "ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic from any source
  security_group_id = aws_security_group.securitygroup.id
}

resource "aws_security_group_rule" "rds_inbound" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Allow traffic from any source
  security_group_id = aws_security_group.securitygroup.id
}

resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "tls_public_key" "my_key_pair_public" {
  private_key_pem = tls_private_key.my_key_pair.private_key_pem
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-keypair"  # Name of the key pair
  public_key = data.tls_public_key.my_key_pair_public.public_key_openssh
}

resource "local_file" "ssh_key" { 
  filename = "${aws_key_pair.my_key_pair.key_name}.pem"
  content = tls_private_key.my_key_pair.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "webserver" {
  ami                    = "ami-06aa3f7caf3a30282" # Replace with your desired AMI
  instance_type          = "t2.micro"             # Replace with your desired instance type
  vpc_security_group_ids = [aws_security_group.securitygroup.id]
  subnet_id              = aws_subnet.subnet_a.id
  associate_public_ip_address = true
  key_name        = aws_key_pair.my_key_pair.key_name  # Specify the key pair name here

  tags = {
    Name = "Ubuntu Server"
  }

  # Consider adding user data script for initial configuration like installing java, jenkins, mysql,etc
  # user_data = file("user_data.sh")  
}

output "public_ip" {
  value = aws_instance.webserver.public_ip
}



resource "aws_db_subnet_group" "my_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

resource "aws_db_instance" "RDS" {
  identifier           = "db-1"
  allocated_storage    = 20  # Size of the storage (in GB)
  storage_type         = "gp2"  # Storage type (General Purpose SSD)
  engine               = "mysql"  # Database engine
  engine_version       = "5.7"  # Engine version
  instance_class       = "db.t3.micro"  # Instance type
  username             = "sohampatra"  # Master username
  password             = "sohampatra1234"  # Master password
  port = 3306
  publicly_accessible  = true
  multi_az             = false
  skip_final_snapshot  = true
  db_subnet_group_name   = aws_db_subnet_group.my_subnet_group.name
  
  vpc_security_group_ids = [aws_security_group.securitygroup.id]
  
  tags = {
    Name = "RDS database"
    Environment = "Dev/Test"
  }
}
