locals {
  ingress_rules = [{
    name        = "HTTPS"
    port        = 443
    description = "Ingress 443"
    },
    {
      name        = "HTTP"
      port        = 80
      description = "Ingress 80"
    },
   ]

}

resource "aws_security_group" "sg" {

  name        = "CustomSG"
  description = "Allow all outbound, HTTPS, HTTP and SSH inbound"
  vpc_id      = aws_vpc.and_vpc.id
  egress = [
    {
      description      = "for all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "Web Security Group"
  }

}
