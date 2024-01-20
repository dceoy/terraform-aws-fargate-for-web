resource "aws_ssm_document" "session" {
  name            = local.ssm_session_document_name
  document_type   = "Session"
  document_format = "JSON"
  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      kmsKeyId                    = aws_kms_key.session.arn
      idleSessionTimeout          = tostring(var.idle_session_timeout)
      runAsEnabled                = true
      runAsDefaultUser            = "ec2-user"
      shellProfile = {
        linux = "cd && exec bash -l"
      }
    }
  })
  target_type = "/AWS::SSM::ManagedInstance"
  tags = {
    Name       = local.ssm_session_document_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_group" "session" {
  name              = local.ssm_session_cloudwatch_log_group_name
  retention_in_days = 14
  kms_key_id        = aws_kms_key.session.arn
  tags = {
    Name       = local.ssm_session_cloudwatch_log_group_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_key" "session" {
  description             = "KMS key for encrypting CloudWatch Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.ssm_session_cloudwatch_log_group_name}"
          }
        }
      }
    ]
  })
  tags = {
    Name       = "${local.ssm_session_cloudwatch_log_group_name}-kms-key"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_alias" "session" {
  name          = "alias/${aws_kms_key.session.tags.Name}"
  target_key_id = aws_kms_key.session.arn
}

resource "aws_iam_policy" "session" {
  name = "${aws_cloudwatch_log_group.session.name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [aws_kms_key.session.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups"]
        Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = ["${aws_cloudwatch_log_group.session.arn}:*"]
      }
    ]
  })
  path = "/"
  tags = {
    Name       = "${aws_cloudwatch_log_group.session.name}-policy"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
