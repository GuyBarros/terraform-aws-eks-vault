resource "aws_security_group" "database" {
  name_prefix = var.cluster_name
  description = "Manual Security group for ${var.cluster_name} cluster"
  vpc_id      = module.vpc.vpc_id
  
  #Allow internal communication between nodes
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = -1
  }


  ingress {
    from_port   = 20
    to_port     = 32000
    protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 20
    to_port     = 32000
    protocol    = "udp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
