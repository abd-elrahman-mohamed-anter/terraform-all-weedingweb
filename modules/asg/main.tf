########################################
# LAUNCH TEMPLATE
########################################

resource "aws_launch_template" "lt_name" {
  name          = "${var.project_name}-lt"
  image_id      = var.ami
  instance_type = var.cpu
  key_name      = var.key_name
  user_data     = filebase64("${path.module}/config.sh")

  vpc_security_group_ids = [var.client_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  tags = {
    Name = "${var.project_name}-lt"
  }
}

########################################
# AUTO SCALING GROUP
########################################

resource "aws_autoscaling_group" "asg_name" {
  name                      = "${var.project_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_cap
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type # "EC2" or "ELB"
  vpc_zone_identifier       = [var.pri_sub_3a_id, var.pri_sub_4b_id]
  target_group_arns         = [var.tg_arn]

  launch_template {
    id      = aws_launch_template.lt_name.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = true
  }
}

########################################
# SCALE UP POLICY + ALARM
########################################

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.project_name}-scale-up-alarm"
  alarm_description   = "Scale up when CPU >= 70%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

########################################
# SCALE DOWN POLICY + ALARM
########################################

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_name.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.project_name}-scale-down-alarm"
  alarm_description   = "Scale down when CPU <= 10%"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_name.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}
