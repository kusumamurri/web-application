# security group for application load balancer
resource "aws_security_group" "web_alb_sg" {
  name        = "web-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.prod.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-security-groupweb"
  }
}

# using ALB - instances in private subnets
resource "aws_alb" "web_alb" {
  name                      = "web-alb"
  security_groups           = ["${aws_security_group.web_alb_sg.id}"]
  subnets                   = aws_subnet.public.*.id             
  tags = {
    Name = "web-alb"
  }
}

# listener
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.web_alb_tg.arn
    type             = "forward"
  }
}


# alb target group
resource "aws_alb_target_group" "web_alb_tg" {
  name     = "web-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod.id
  health_check {
    path = "/"
    port = 80
  }
}


# creating launch configuration
resource "aws_launch_configuration" "web-template" {
  image_id               = data.aws_ami.amazon-linux.id               
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.web_ec2.id}"]
  user_data              = file("user_data.sh")
  key_name               = var.key                             
  lifecycle {
    create_before_destroy = true
  }
}


# creating autoscaling group
resource "aws_autoscaling_group" "web_asg" {
  name                        = "web-autoscaling-group"
  launch_configuration = aws_launch_configuration.web-template.id

  vpc_zone_identifier       = aws_subnet.private.*.id

  desired_capacity = 3
  max_size = 6
  min_size = 1

  health_check_type = "ELB"
}

# autoscaling attachment
resource "aws_autoscaling_attachment" "asg-alb-assosciation" {
  alb_target_group_arn   = aws_alb_target_group.web_alb_tg.arn
  autoscaling_group_name = aws_autoscaling_group.web_asg.id
}


# ALB DNS is generated dynamically, return URL so that it can be used
output "url" {
  value = "http://${aws_alb.web_alb.dns_name}/"
}

