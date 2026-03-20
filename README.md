# AWS 3-Tier Core Project

## Overview
이 프로젝트는 클라우드 운영 / 시스템 엔지니어 취업 포트폴리오를 목표로 만든 AWS 기반 3-Tier 아키텍처 프로젝트입니다.

초기 단계에서는 AWS Console 기반으로 코어 아키텍처를 직접 구축했고,
이후 운영 고도화와 Terraform 코드화까지 확장하는 것을 목표로 합니다.

## Architecture Diagram
![AWS 3-Tier Core Architecture](diagram/aws-3tier-core.png)

## Project Scope
### Phase 1. Core Build
- Public / Private 네트워크 분리
- ALB - App EC2 - RDS 구조
- NAT Gateway 기반 Private App Tier 아웃바운드 통신
- Launch Template + Auto Scaling Group
- Security Group 계층 분리
- 최소 CloudWatch Alarm 구성

### Phase 2. 운영고도화
- IAM Role 등록 및 SSM Session Manager을 통한 접근
- Launch Template 수정 후 Instance Refresh를 통한 인스턴스 교체
- CloudWatch Dashboard *(planned)*
- HTTPS, ACM, and Route 53 *(planned)*

### Phase 3. Infrastructure as Code (IaC 단계)
- Terraform *(planned)*

## Documentation

### Phase 1. Core Build
- [Core Build](docs/core-build.md)
- [Security Group Design](docs/security-group-design.md)
- [Troubleshooting](docs/troubleshooting.md)

### Phase 2. Operational Enhancements
- [IAM Role and SSM Session Manager](docs/iam-role-ssm-session-manager.md)
- [Launch Template Update and Instance Refresh](docs/launch-template-instance-refresh.md)
- CloudWatch Dashboard *(planned)*
- HTTPS, ACM, and Route 53 *(planned)*

### Phase 3. Infrastructure as Code
- Terraform *(planned)*

## Current Status
- AWS Console 기반 Core Build 문서화 완료
- Security Group 설계 문서화 완료
- IAM Role, SSM Session Manager 문서화 완료
- Launch Template, Instance Refresh 문서화 완료
- Troubleshooting 문서화 완료
- CloudWash Dashboard, HTTP, ACM and Route3 및 Terraform 단계는 예정

## Why This Project
- 단순 EC2 1대 배포가 아니라 실무형 3-Tier 구조를 직접 설계하고 구현
- Public / Private 계층 분리와 보안 그룹 설계 경험 확보
- 이후 운영 개선과 IaC 전환까지 이어질 수 있는 기준선 프로젝트

## Future Improvements
- CloudWatch Dashboard 구성
- HTTPS + ACM + Route 53 연결
- Terraform 코드화
- 운영 자동화 구조 확장

## 최근 업데이트

- `core-build.md` 기준으로 AWS 3-Tier Core 아키텍처를 재구성했다.
- Launch Template에 새로운 버전 v2를 만들고 ASG에 적용, Instance Refresh를 통해서 안전하게 대체작업을 했다.
- Launch Template 실습중 발생한 문제에 대해서 Troubleshooting.md 문서에 정리했다.