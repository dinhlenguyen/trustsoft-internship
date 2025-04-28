########################################
# Application Load Balancer
########################################

# Create the Load Balancer
resource "aws_lb" "alb_internship_dinh" {
  name               = "alb-internship-dinh"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internship_dinh.id]
  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  tags = {
    Name = "alb_internship_dinh"
  }
}

########################################
# Target Group
########################################

resource "aws_lb_target_group" "tg_internship_dinh" {
  name     = "tg-internship-dinh"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_internship_dinh.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "tg_internship_dinh"
  }
}

########################################
# Target Group Attachments (EC2 instances)
########################################

resource "aws_lb_target_group_attachment" "tg_attachment_a" {
  target_group_arn = aws_lb_target_group.tg_internship_dinh.arn
  target_id        = aws_instance.web_a_internship_dinh.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_b" {
  target_group_arn = aws_lb_target_group.tg_internship_dinh.arn
  target_id        = aws_instance.web_b_internship_dinh.id
  port             = 80
}

########################################
# Load Balancer Listener
########################################

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb_internship_dinh.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_internship_dinh.arn
  }
}
