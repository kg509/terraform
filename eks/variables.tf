# bastion host 생성시 사용할 ssh key 지정
variable "bastion_key_name" {
  type    = string
}

# IAM 계정 정보. 이부분은 default 사용을 권장하지 않습니다. 실행시 수동입력 권장.
variable "access_key" {
  type    = string
}

# IAM 계정 정보. 이부분은 default 사용을 권장하지 않습니다. 실행시 수동입력 권장.
variable "secret_key" {
  type    = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}