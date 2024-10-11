1. iac.sh 와 같은경로에 텍스트 파일을 생성합니다.
파일명은 [iac_config.txt] 로 작명하시고 내용은 다음과 같습니다.

```
####iac_config.txt####
# 민감 정보
access_key="access_key_value_here"
secret_key="secret_key_value_here"
bastion_key_name="key_name_here"

# 프로젝트 리스트 (순서대로 실행)
projects=("eks" "karpenter" "karpenter_manifest" "plg" "argocd")

# 민감 정보가 필요한 프로젝트
secret_projects=("eks")

##################
```

-> iac_config.txt 파일은 .gitignore 설정으로 git push/pull 제외 대상입니다.

2. Admin 권한이 있는 aws iam 계정의 access key, secret key 를 대입합니다.
계정명이 "admin" 이 아니거나, region 이 서울이 아닐경우
-> vars 디렉토리의 global_settings.tf 에서 세부 설정을 수정 할 수 있습니다.

3. Bastion host에 SSH 접속시 사용할 key의 이름을 확장자 없이 대입합니다.

4. iac.sh 파일을 bash 환경에서 실행합니다. 
실행시 반드시 아래의 두 옵션중 하나를 적용해야합니다.
-> apply
./iac.sh -apply
-> destroy
./iac.sh -destroy

Script 는 순서에따라 terraform apply, 역순으로 terraform destroy 를 자동으로 수행합니다.
apply 단계에서 문제 발생시, 에러가 생긴 프로젝트부터 시작해 역순으로 수동 terraform destroy를 권장합니다.