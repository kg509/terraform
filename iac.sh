#!/bin/bash

# iac_config.txt 파일에서 민감한 정보를 읽어옵니다.
if [ ! -f iac_config.txt ]; then
  echo "Error: iac_config.txt 파일을 찾을 수 없습니다."
  exit 1
fi

# iac_config.txt에서 값을 읽어서 환경변수로 저장합니다.
source iac_config.txt

# 민감 정보가 모두 있는지 확인합니다.
if [ -z "$access_key" ] || [ -z "$secret_key" ] || [ -z "$bastion_key_name" ]; then
  echo "Warning: 필요한 민감 정보가 누락되었습니다. 일부 프로젝트에서 시크릿 값이 필요할 수 있습니다."
fi

# 실행할 명령어를 결정합니다.
if [ "$1" == "-apply" ]; then
  action="apply"
elif [ "$1" == "-destroy" ]; then
  action="destroy"
else
  echo "Usage: $0 -apply | -destroy"
  exit 1
fi

# destroy일 경우 리스트를 역순으로 처리
if [ "$action" == "destroy" ]; then
  projects=($(echo "${projects[@]}" | tac -s ' '))
fi

# 프로젝트들을 순차적으로 Terraform 명령어 실행
for project in "${projects[@]}"; do
  echo "===== ${project}에 대해 terraform init 및 ${action} 시작 ====="

  # 각 프로젝트 디렉토리로 이동
  cd "$project" || { echo "Error: ${project} 디렉토리를 찾을 수 없습니다."; exit 1; }

  # Terraform 초기화
  terraform init
  if [ $? -ne 0 ]; then
    echo "Error: ${project}에서 terraform init 실패"
    exit 1
  fi

  # 민감 정보가 필요한 프로젝트만 시크릿 값 전달
  if [[ " ${secret_projects[@]} " =~ " ${project} " ]]; then
    terraform $action \
      -var "access_key=$access_key" \
      -var "secret_key=$secret_key" \
      -var "bastion_key_name=$bastion_key_name" \
      -auto-approve
  else
    terraform $action -auto-approve
  fi

  # 예외 처리: apply 또는 destroy가 실패하면 스크립트 종료
  if [ $? -ne 0 ]; then
    echo "Error on ${action} project ${project}... manual destroy recommended, try again after fixing error."
    exit 1
  fi

  # 이전 디렉토리로 돌아가기
  cd ..

  echo "===== ${project}에 대해 terraform ${action} 완료 ====="
done

echo "모든 프로젝트에 대한 Terraform ${action}가 완료되었습니다."

# action이 apply인 경우 ./data 디렉토리로 이동하여 terraform apply 실행
if [ "$action" == "apply" ]; then
  echo "===== data 프로젝트에 대해 terraform apply 시작 ====="
  cd ./data || { echo "Error: data 디렉토리를 찾을 수 없습니다."; exit 1; }

  terraform init
  if [ $? -ne 0 ]; then
    echo "Error: data 프로젝트에서 terraform init 실패"
    exit 1
  fi

  terraform apply -auto-approve
  if [ $? -ne 0 ]; then
    echo "Error: data 프로젝트에서 terraform apply 실패"
    exit 1
  fi

  echo "===== data 프로젝트에 대한 terraform apply 완료 ====="

  # ArgoCD Admin Password 출력
  echo -e "\n===== ArgoCD Admin Password ====="
  terraform output -raw argocd_admin_password
  echo -e "\n"

  cd ..
fi
