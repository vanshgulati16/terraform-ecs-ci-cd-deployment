
resource "aws_ecs_cluster" "flask_app_demo" {
  name = "flask-app-demo"
}
resource "aws_ecs_task_definition" "flask_app_demo" {
  family                   = "flask-app-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions = <<DEFINITION
[
  {
    "name": "${aws_ecr_repository.ecr_repo.name}",
    "image": "${aws_ecr_repository.ecr_repo.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "cpu": 256, 
    "memory": 512,  
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.flask_app_demo.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "flask-app-demo"
      }
    }
  }
]
DEFINITION
  execution_role_arn = aws_iam_role.task_definition_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
output "ecr-repo-url"{
  value = aws_ecr_repository.ecr_repo.repository_url
}
resource "aws_cloudwatch_log_group" "flask_app_demo" {
  name = "/ecs/flask-app-demo2"
}
resource "aws_ecs_service" "flask_app_demo" {
  name            = "flask-app-demo"
  cluster         = aws_ecs_cluster.flask_app_demo.id
  task_definition = aws_ecs_task_definition.flask_app_demo.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.my_subnet-1.id, aws_subnet.my_subnet-2.id, aws_subnet.my_subnet-3.id, aws_subnet.my_subnet-4.id]
    security_groups = [aws_security_group.flask_app_demo.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.flask_app_demo.arn
    container_name   = "${aws_ecr_repository.ecr_repo.name}"
    container_port   = 5000
  }
}
resource "aws_security_group" "flask_app_demo" {
  name        = "flask-app-demo"
  description = "Allow inbound traffic to flask app"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_lb_target_group" "flask_app_demo" {
  name        = "flask-app-demo"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb" "flask_app_demo" {
  name               = "flask-app-demo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.flask_app_demo.id]
  subnets            = [aws_subnet.my_subnet-1.id, aws_subnet.my_subnet-2.id, aws_subnet.my_subnet-3.id, aws_subnet.my_subnet-4.id]
  enable_deletion_protection = false
  tags = {
    Name = "flask-app-demo"
  }
}
resource "aws_lb_listener" "flask_app_demo" {
  load_balancer_arn = aws_lb.flask_app_demo.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_app_demo.arn
  }
}
resource "aws_lb_listener_rule" "flask_app_demo" {
  listener_arn = aws_lb_listener.flask_app_demo.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_app_demo.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
resource "aws_iam_role" "task_definition_role" {
  name = "flask_demo_task_definition"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "task_definition_policy" {
  name = "flask_demo_task_definition_policy"
  role = aws_iam_role.task_definition_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "task_role" {
  name               = "flask-app-demo-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "task_role_policy" {
  name   = "flask-app-demo-task-role-policy"
  role   = aws_iam_role.task_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "load-balancer-arn" {
  value = aws_lb.flask_app_demo.arn 
}
