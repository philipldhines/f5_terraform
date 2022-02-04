# Networking

############################ Locals ############################

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  awsAz1 = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2 = var.awsAz2 != null ? var.awsAz1 : data.aws_availability_zones.available.names[1]
  awsAz3 = var.awsAz3 != null ? var.awsAz1 : data.aws_availability_zones.available.names[2]
}

############################ VPC ############################

# Create VPC, subnets, route tables, and IGW
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = format("%s-vpc-%s", var.projectPrefix, random_id.buildSuffix.hex)
  cidr   = "10.0.0.0/16"

  azs             = [local.awsAz1, local.awsAz2, local.awsAz3]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name  = format("%s-vpc-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner
  }
}

############################ Subnets ############################

resource "aws_subnet" "mgmtAz1" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz1
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name  = format("%s-mgmtAz1-subnet-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "mgmtAz2" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz2
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name  = format("%s-mgmtAz2-subnet-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "mgmtAz3" {
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.awsAz3
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name  = format("%s-mgmtAz3-subnet-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner
  }
}

############################ Associate Route Table ############################

resource "aws_route_table_association" "mgmtAz1" {
  subnet_id      = aws_subnet.mgmtAz1.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

resource "aws_route_table_association" "mgmtAz2" {
  subnet_id      = aws_subnet.mgmtAz2.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

resource "aws_route_table_association" "mgmtAz3" {
  subnet_id      = aws_subnet.mgmtAz3.id
  route_table_id = module.vpc.public_route_table_ids[0]
}

############################ Security Groups ############################

# Security Group - mgmt
resource "aws_security_group" "mgmt" {
  name   = format("%s-sg-mgmt-%s", var.projectPrefix, random_id.buildSuffix.hex)
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-mgmt-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner
  }
}

# Security Group - external
resource "aws_security_group" "external" {
  name   = format("%s-sg-ext-%s", var.projectPrefix, random_id.buildSuffix.hex)
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-ext-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner

  }
}

# Security Group - internal
resource "aws_security_group" "internal" {
  name   = format("%s-sg-int-%s", var.projectPrefix, random_id.buildSuffix.hex)
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = format("%s-sg-int-%s", var.projectPrefix, random_id.buildSuffix.hex)
    Owner = var.resourceOwner

  }
}
