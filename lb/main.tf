resource "aws_lb" "this" {
  for_each = { for lb in var.load_balancers : lb.name => lb }

  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = each.value.subnet_ids

  tags = {
    Name = each.value.name
  }
}

resource "aws_lb_target_group" "this" {
  for_each = { for lb in var.load_balancers : lb.name => lb }

  name        = "${each.value.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = merge([
    for lb in var.load_balancers : {
      for idx, target in lb.target_instance_ids : "${lb.name}-${idx}" => {
        lb_name = lb.name
        target  = target
      }
    }
  ]...)

  target_group_arn = aws_lb_target_group.this[each.value.lb_name].arn
  target_id        = each.value.target
  port             = 80
}


resource "aws_lb_listener" "http" {
  for_each = { for lb in var.load_balancers : lb.name => lb }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}
