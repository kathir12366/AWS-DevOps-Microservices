resource "aws_iam_role_policy" "ecr_push" {
  name = "${var.environment}-ecr-push-policy"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          aws_ecr_repository.user_service.arn,
          aws_ecr_repository.product_service.arn,
          aws_ecr_repository.order_service.arn
        ]
      }
    ]
  })
}