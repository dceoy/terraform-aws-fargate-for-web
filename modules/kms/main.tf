resource "aws_kms_key" "custom" {
  description             = "KMS key for SNS"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
  rotation_period_in_days = var.kms_key_rotation_period_in_days
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = ["kms:*"]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchDecryptAndGenerateDataKey"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "AllowEventBridgeDecryptAndGenerateDataKey"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-kms-key"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_alias" "custom" {
  name          = "alias/${aws_kms_key.custom.tags.Name}"
  target_key_id = aws_kms_key.custom.arn
}
