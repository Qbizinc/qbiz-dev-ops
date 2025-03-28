#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting dbt setup (venv POC with OPEN SSH) on $(date)"
echo "Running as: $(whoami)"

echo "Updating OS and installing packages..."
sudo yum update -y
sudo yum install -y python3 python3-pip git jq

DBT_VENV_PATH_DEFINITION="/home/ec2-user/dbt_venv"

echo "Fetching Snowflake credentials (User/Password) from Secrets Manager ARN: ${snowflake_credentials_arn}"
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "${snowflake_credentials_arn}" --region "${aws_region}" --query SecretString --output text)

if [ -z "$SECRET_JSON" ]; then
    echo "ERROR: Failed to retrieve secret from Secrets Manager ARN: ${snowflake_credentials_arn}"
    exit 1
fi

SNOWFLAKE_USER=$(echo "$SECRET_JSON" | jq -r .username)
SNOWFLAKE_PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)

if [ -z "$SNOWFLAKE_USER" ] || [ "$SNOWFLAKE_USER" == "null" ]; then
    echo "ERROR: Username key (.username) not found or value is null in the secret JSON."
    exit 1
fi
 if [ -z "$SNOWFLAKE_PASSWORD" ] || [ "$SNOWFLAKE_PASSWORD" == "null" ]; then
    echo "ERROR: Password key (.password) not found or value is null in the secret JSON."
    exit 1
fi
echo "Successfully fetched Snowflake username and password."

echo "Setting Snowflake connection environment variables..."
sudo tee /etc/profile.d/dbt_env.sh > /dev/null <<EOF
export DBT_TARGET="${dbt_target}"
export SNOWFLAKE_ACCOUNT="${snowflake_account}"
export SNOWFLAKE_ROLE="${snowflake_role}"
export SNOWFLAKE_WAREHOUSE="${snowflake_warehouse}"
export SNOWFLAKE_DATABASE="${snowflake_database}"
export SNOWFLAKE_SCHEMA="${snowflake_schema}"
export SNOWFLAKE_USER="$${SNOWFLAKE_USER}"
export SNOWFLAKE_PASSWORD="$${SNOWFLAKE_PASSWORD}"
EOF
sudo chmod +x /etc/profile.d/dbt_env.sh
echo "Connection environment variables script created at /etc/profile.d/dbt_env.sh"

echo "Creating Python virtual environment at /home/ec2-user/dbt_venv..."
sudo -u ec2-user python3 -m venv "/home/ec2-user/dbt_venv"
echo "Virtual environment created."

echo "Installing/upgrading pip and installing dbt-snowflake==${dbt_snowflake_version} inside venv..."
sudo -u ec2-user -E bash -c "source /home/ec2-user/dbt_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install dbt-snowflake==${dbt_snowflake_version}"
echo "dbt installed inside virtual environment."

echo "Cloning dbt project from ${dbt_project_git_url}..."
sudo -u ec2-user git clone "${dbt_project_git_url}" /home/ec2-user/dbt_project
echo "dbt project cloned to /home/ec2-user/dbt_project"

echo "Running dbt deps inside venv..."
cd /home/ec2-user/dbt_project
sudo -u ec2-user -E bash -c "source /home/ec2-user/dbt_venv/bin/activate && \
    source /etc/profile.d/dbt_env.sh && \
    dbt deps" || echo "WARNING: 'dbt deps' failed. Check project dependencies and connection."
echo "dbt deps execution attempted."
