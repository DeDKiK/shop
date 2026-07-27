output "runner_public_ip" {
  value = aws_instance.gitlab_runner.public_ip
}

output "runner_private_ip" {
  value = aws_instance.gitlab_runner.private_ip
}