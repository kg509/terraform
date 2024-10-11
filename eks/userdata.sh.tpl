#!/bin/bash

ACCESS_KEY="${ACCESS_KEY}"
SECRET_KEY="${SECRET_KEY}"
REGION="${REGION}"
PROFILE_NAME="${PROFILE_NAME}"
CLUSTER_NAME="${CLUSTER_NAME}"

DB_NAME="${DB_NAME}"
DB_USERNAME="${DB_USERNAME}"
DB_PASSWORD="${DB_PASSWORD}"
DB_ENDPOINT="${DB_ENDPOINT}"
DB_PORT="${DB_PORT}"

# AWS CLI configure
sudo -u ec2-user aws configure set aws_access_key_id "${ACCESS_KEY}" --profile "${PROFILE_NAME}"
sudo -u ec2-user aws configure set aws_secret_access_key "${SECRET_KEY}" --profile "${PROFILE_NAME}"
sudo -u ec2-user aws configure set region "${REGION}" --profile "${PROFILE_NAME}"

# Create ec2-user only bin directory
sudo -u ec2-user mkdir -p /home/ec2-user/bin

#################### kubectl ####################
# Download kubectl
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl

# File Move
sudo mv ./kubectl /home/ec2-user/bin/kubectl

# Make kubectl executable
sudo chown ec2-user:ec2-user /home/ec2-user/bin/kubectl
sudo chmod +x /home/ec2-user/bin/kubectl

# Update kubeconfig for EKS
sudo -u ec2-user aws eks update-kubeconfig --region "${REGION}" --name "${CLUSTER_NAME}" --profile "${PROFILE_NAME}"

#################### eksctl #####################
# Download eksctl
sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# File Move
sudo mv /tmp/eksctl /home/ec2-user/bin/eksctl

# Make eksctl executable
sudo chown ec2-user:ec2-user /home/ec2-user/bin/eksctl
sudo chmod +x /home/ec2-user/bin/eksctl

##################### helm #######################
# Download Helm installation script
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# File Move
sudo mv get_helm.sh /home/ec2-user/bin/get_helm.sh

# Make helm installation script executable
sudo chown ec2-user:ec2-user /home/ec2-user/bin/get_helm.sh
sudo chmod +x /home/ec2-user/bin/get_helm.sh

# Run Helm installation script
sudo -u ec2-user /home/ec2-user/bin/get_helm.sh


#################### Docker #######################
# Docker 설치
sudo yum update -y
sudo yum install -y docker

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# ec2-user를 Docker 그룹에 추가
sudo usermod -aG docker ec2-user

#################### GitLab Runner #################
# GitLab Runner 설치
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

# Docker 권한 설정
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner

################## RDS Configure ####################
sudo yum update -y
sudo dnf install -y mariadb105

# MariaDB 클라이언트 권한 설정
sudo chown ec2-user:ec2-user /usr/bin/mysql
sudo chmod +x /usr/bin/mysql

# ec2-user가 sudo 권한으로 SQL 실행
sudo -u ec2-user mysql -h ${DB_ENDPOINT} -P ${DB_PORT} -u ${DB_USERNAME} -p${DB_PASSWORD} <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
USE ${DB_NAME};

CREATE TABLE IF NOT EXISTS board(
    no int,
    title varchar(100),
    content varchar(200),
    id varchar(20),
    write_date varchar(15),
    hits int,
    file_name varchar(255),
    primary key(no)
) DEFAULT CHARSET=UTF8;

CREATE TABLE IF NOT EXISTS member(
    id varchar(20),
    pw VARCHAR(60),
    user_name varchar(21),
    address varchar(1000),
    mobile varchar(20),
    PRIMARY KEY(id)
) DEFAULT CHARSET=UTF8;
EOF