
################################################################################
# ALB
################################################################################

resource "aws_lb" "cloudbeaver_lb" {
  name               = "Cloudbeaver-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cloudbeaver_alb.id]
  subnets            = aws_subnet.public_subnets[*].id
  tags = var.common_tags
}

resource "aws_lb_listener" "cloudbeaver-listener" {

  load_balancer_arn = aws_lb.cloudbeaver_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = var.common_tags
}

resource "aws_lb_listener" "cloudbeaver-listener-https" {

  load_balancer_arn = aws_lb.cloudbeaver_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/${var.alb_certificate_Identifier}"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cloudbeaver.arn
  }
  tags = var.common_tags
}

resource "aws_lb_target_group" "cloudbeaver" {
  name        = "Cloudbeaver"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.cloudbeaver_net.id

  health_check {
    matcher = "200,302"
    unhealthy_threshold = 10
    enabled = true
    path    = "/"
  }
  tags = var.common_tags
}
