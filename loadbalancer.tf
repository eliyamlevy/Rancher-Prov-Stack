############################# L O A D   B A L A N C I N G #############################
# create a target group for 80
resource "aws_lb_target_group" "tg_80" {
  name        = "${var.aws_prefix}-tg-80"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    protocol          = "TCP"
    port              = "traffic-port"
    healthy_threshold = 3
    interval          = 10
  }
}

# create a target group for 443
resource "aws_lb_target_group" "tg_443" {
  name        = "${var.aws_prefix}-tg-443"
  port        = 443
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    protocol          = "TCP"
    port              = 443
    healthy_threshold = 3
    interval          = 10
  }
}

# attach instances to the target group 80
resource "aws_lb_target_group_attachment" "attach_tg_80" {
  count = length(aws_instance.local-node)
  target_group_arn = aws_lb_target_group.tg_80.arn
  target_id        = aws_instance.local-node[count.index].id
  port             = 80
}

# attach instances to the target group 443
resource "aws_lb_target_group_attachment" "attach_tg_443" {
  count = length(aws_instance.local-node)
  target_group_arn = aws_lb_target_group.tg_443.arn
  target_id        = aws_instance.local-node[count.index].id
  port             = 443
}

# create a load balancer
resource "aws_lb" "aws_lb" {
  load_balancer_type = "network"
  name               = "${var.aws_prefix}-lb"
  internal           = false
  ip_address_type    = "ipv4"
  subnets            = [aws_subnet.public_subnet.id]
}

# add a listener for port 80
resource "aws_lb_listener" "aws_lb_listener_80" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_80.arn
  }
}

# add a listener for port 443
resource "aws_lb_listener" "aws_lb_listener_443" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_443.arn
  }
}

############################# R O U T E   5 3 #############################
# find route 53 zone id 
data "aws_route53_zone" "zone" {
  name = "eng.rancher.space"
}

# create a route53 record using the aws_instance
resource "aws_route53_record" "route_53_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.aws_prefix}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.aws_lb.dns_name]
}

# print route53 full record
output "route_53_record" {
  value = aws_route53_record.route_53_record.fqdn
}
