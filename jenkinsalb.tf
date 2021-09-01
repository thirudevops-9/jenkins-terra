resource "aws_lb" "jenkins" {
  name               = "jenkins-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = ["${aws_subnet.public[0].id}","${aws_subnet.public[1].id}","${aws_subnet.public[2].id}"]
  enable_deletion_protection = false


  tags = {
    Environment = "jenkins"
  }
}


# instance target group

resource "aws_lb_target_group" "jenkins" {
  name     = "jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id
}



resource "aws_lb_target_group_attachment" "attach-tg" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}

# listner


resource "aws_lb_listener" "r_end" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}
