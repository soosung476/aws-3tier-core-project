여기에 들어갈 내용:

VPC CIDR
VPC Name: aws-3tier-core-project
VPC CIDR: 10.0.0.0/16

서브넷 구성

Public / Private 분리 이유

트래픽 흐름




ALB → App → RDS 관계


AZ를 2개 쓴 이유

이번 코어 버전에서 제외한 것(IAM, Route53, HTTPS, Terraform 등)