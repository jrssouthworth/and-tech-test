#Create EC2 Instances 
resource "aws_instance" "instance" {
  count                = length(aws_subnet.private_subnet.*.id)
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = element(aws_subnet.private_subnet.*.id, count.index)
  security_groups      = [aws_security_group.sg.id, ]

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  apt-get update -y
                  apt-get install apache2 -y
                  echo "<p> Hello World :) </p>" >> /var/www/html/index.html
                  sudo systemctl enable apache2
                  sudo systemctl start apache2
                  EOF

  tags = {
    "Name"        = "Ubuntu-Web-${count.index}"
  }

}


