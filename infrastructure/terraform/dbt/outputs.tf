output "instance_public_ip" {
  description = "Public IP address of the dbt EC2 instance"
  value       = aws_instance.dbt_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the dbt EC2 instance"
  value       = aws_instance.dbt_instance.public_dns
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.dbt_instance.id
}

output "ssh_command" {
  description = "Example SSH command to connect (using default ec2-user and your key)"
  value       = "ssh -i /path/to/${var.key_name}.pem ec2-user@${aws_instance.dbt_instance.public_dns}"
}

output "WARNING" {
  description = "Security Warning Regarding Open SSH Port"
  value       = "Instance Security Group allows SSH from 0.0.0.0/0. This is HIGHLY INSECURE. Destroy or restrict access ASAP."
}