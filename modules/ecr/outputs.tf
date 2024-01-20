output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.image.repository_url
}

output "codecommit_repository_id" {
  description = "CodeCommit repository ID"
  value       = aws_codecommit_repository.image.repository_id
}

output "codecommit_repository_clone_url_http" {
  description = "CodeCommit repository URL for cloning over HTTPS"
  value       = aws_codecommit_repository.image.clone_url_http
}
