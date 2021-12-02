resource "aws_iam_role" "access_role" {
  name = "remix-access"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
  ]
}

resource "aws_apprunner_service" "this" {
  depends_on = [
    aws_iam_role.access_role
  ]

  service_name = "remix"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.access_role.arn
    }

    image_repository {
      image_configuration {
        port = "3000"
      }
      image_identifier      = "${var.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }
}
