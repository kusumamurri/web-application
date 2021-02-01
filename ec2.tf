# security group for EC2 instances in ASG
resource "aws_security_group" "web_ec2" {
  name        = "web-ec2"
  description = "allow incoming HTTP traffic from public subnet only"
  vpc_id      = aws_vpc.prod.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/16"]                   #Allowing incoming traffic from 10.0.0.0/16
  }
  ingress {                                         
    description = "EFS mount target"
	from_port   = 2049
	to_port     = 2049
	protocol    = "tcp"
	cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
	description = "SSH from VPC"
	from_port   = 22
	to_port     = 22
	protocol    = "tcp"
	cidr_blocks = ["10.0.0.0/16"]
  }  
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]                    
  }
}

#Fetching latest image                             
data "aws_ami" "amazon-linux" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

