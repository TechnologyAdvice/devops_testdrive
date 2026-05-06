output "ecr_repository_url" {
  description = "Repository URL for docker push/pull."
  value       = aws_ecr_repository.app.repository_url
}
