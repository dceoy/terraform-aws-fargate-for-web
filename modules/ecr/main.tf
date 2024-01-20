resource "aws_ecr_repository" "image" {
  name                 = local.ecr_repository_name
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.image.arn
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name       = local.ecr_repository_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_key" "image" {
  description             = "KMS key for encrypting ECR images"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    Name       = "${local.ecr_repository_name}-kms-key"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_alias" "image" {
  name          = "alias/${aws_kms_key.image.tags.Name}"
  target_key_id = aws_kms_key.image.arn
}

resource "aws_codecommit_repository" "image" {
  repository_name = local.codecommit_repository_name
  tags = {
    Name       = local.codecommit_repository_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
