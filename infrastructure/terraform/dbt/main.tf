provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "dbt_instance" {
  ami                    = "ami-0f9d441b5d66d5f31"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.dbt_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.dbt_profile.name

  user_data = templatefile("../../../scripts/dbt/user_data.sh.tpl", {
    aws_region                = var.aws_region
    dbt_project_git_url       = var.dbt_project_git_url
    dbt_target                = var.dbt_target
    dbt_snowflake_version     = var.dbt_snowflake_version
    snowflake_credentials_arn = var.snowflake_credentials_arn
    snowflake_account         = var.snowflake_account
    snowflake_role            = var.snowflake_role
    snowflake_warehouse       = var.snowflake_warehouse
    snowflake_database        = var.snowflake_database
    snowflake_schema          = var.snowflake_schema
  })

  tags = {
    Name    = "dbt-instance-direct-snowflake-POC"
    Project = "dbt-runner-POC"
    WARNING = "SSH-Open-To-All-Temporary" # Add a warning tag
  }
}

resource "aws_security_group" "dbt_sg" {
  name        = "dbt-direct-sg-poc-open" # Name reflects insecure state
  description = "ALLOW SSH FROM ALL (POC ONLY - INSECURE), HTTPS Outbound"
  vpc_id      = var.vpc_id

  # --- INSECURE SSH RULE FOR POC ---
  ingress {
    description = "SSH - ALLOW ALL (TEMPORARY POC ONLY - HIGH RISK)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <-- Allows all IPs (Insecure!)
  }
  # --- END INSECURE RULE ---

  egress {
    description = "Allow all outbound" # For yum, git, pip, Snowflake (HTTPS)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "dbt-direct-sg-poc-open"
    WARNING = "SSH-Open-To-All-Temporary"
  }
}

resource "aws_iam_instance_profile" "dbt_profile" {
  name = "dbt-instance-profile-direct-snowflake"
  role = aws_iam_role.dbt_role.name
}

resource "aws_iam_role" "dbt_role" {
  name               = "dbt-instance-role-direct-snowflake"
  description        = "IAM role for EC2 instance running dbt (POC)"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
      Name = "dbt-instance-role-direct-snowflake"
  }
}

resource "aws_iam_policy" "secrets_manager_read" {
  name        = "dbt-snowflake-secrets-read-policy"
  description = "Allow reading specific Snowflake credentials secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = var.snowflake_credentials_arn # Restrict to the specific secret
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.dbt_role.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}
