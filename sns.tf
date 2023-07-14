resource "aws_sns_topic" "my_topic" {
  name = "CodebuildTopic"
  display_name = "CodebuildTopic"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "Build-lambda-function"
  runtime          = "python3.10"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256("python_code.zip")
  filename = "python_code.zip"
}
output "subscription_arn" {
  value = aws_sns_topic_subscription.gchat_subscription.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
  
}

output "source_code_hash" {
  value = filebase64sha256("python_code.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "my-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_sns_topic_subscription" "gchat_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}

output "sns_topic_arn" {
  value = aws_sns_topic.my_topic.arn
}

