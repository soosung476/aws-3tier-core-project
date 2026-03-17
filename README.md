# AWS 3-Tier Core Project

## 프로젝트 개요
이 프로젝트는 **클라우드 운영 / 시스템 엔지니어 취업 포트폴리오**를 목표로 만든 AWS 기반 3-Tier 아키텍처 코어 프로젝트입니다.

단순히 EC2 1대를 배포하는 수준이 아니라,  
**Public / Private 네트워크 분리**,  
**ALB - App EC2 - RDS 구조 설계**,  
**NAT Gateway를 통한 Private App 서버의 아웃바운드 통신**,  
**Auto Scaling Group 기반 App 계층 운영**까지 포함하여  
실무형 클라우드 인프라의 핵심 구조를 직접 구현하는 것을 목표로 했습니다.

이번 저장소는 **AWS Console 기반 코어 버전 구현**에 집중했으며,  
다음 단계에서 **Terraform 코드화**, **HTTPS 적용**, **운영 고도화**로 확장할 계획입니다.

---

## 아키텍처 다이어그램

![AWS 3-Tier Core Architecture](./diagram/aws-3tier-core.png)

---

## 프로젝트 목표
- AWS 기반 3-Tier 아키텍처 코어 버전 구현
- Public / Private Subnet 분리 설계
- 인터넷 진입점을 ALB로 제한
- App 서버를 Private Subnet에 배치
- RDS를 Private DB Subnet에 배치
- NAT Gateway를 통한 Private App 서버의 아웃바운드 인터넷 통신 구성
- Auto Scaling Group을 통한 App 계층 확장 구조 구현
- Security Group 기반 계층별 접근 제어
- CloudWatch 최소 알람 구성
- 이후 Terraform 전환이 가능한 구조 설계

---

## 사용한 AWS 서비스
- Amazon VPC
- Subnet
- Route Table
- Internet Gateway
- NAT Gateway
- Application Load Balancer
- Target Group
- EC2
- Launch Template
- Auto Scaling Group
- Amazon RDS (MySQL)
- Security Group
- Amazon CloudWatch

---

## 전체 아키텍처 구성

### Network
- VPC 1개
- Public Subnet 2개
- Private App Subnet 2개
- Private DB Subnet 2개
- Internet Gateway 1개
- NAT Gateway 1개
- Route Table 3개

### Compute / Load Balancing
- Application Load Balancer 1개
- Target Group 1개
- Launch Template 1개
- Auto Scaling Group 1개
- EC2 App 서버 2대 이상 운영 구조

### Database
- DB Subnet Group 1개
- RDS MySQL 1개

### Monitoring
- CloudWatch 최소 알람 구성
  - App EC2 CPU 높음
  - ALB HealthyHostCount 낮음
  - RDS CPU 높음
  - RDS FreeStorageSpace 낮음

---

## 트래픽 흐름
이 프로젝트의 요청 흐름은 아래와 같습니다.

**User / Internet → ALB → Private App EC2 → RDS**

추가로 Private App EC2는 외부 인터넷으로 직접 연결되지 않으며,  
패키지 설치 및 업데이트 등 아웃바운드 통신이 필요한 경우에만  
아래 경로를 사용합니다.

**Private App EC2 → NAT Gateway → Internet Gateway → Internet**

---

## 왜 이 구조로 설계했는가

### 1. 인터넷 진입점을 ALB로 제한
외부에서 직접 접근 가능한 리소스를 ALB로 한정하여  
App 서버와 DB 서버의 직접 노출을 방지했습니다.

### 2. App 서버를 Private Subnet에 배치
실제 애플리케이션 처리를 담당하는 EC2는 Private App Subnet에 배치하고,  
ALB를 통해서만 접근할 수 있도록 구성했습니다.

### 3. DB를 Private DB Subnet에 배치
RDS는 Public access를 비활성화하고,  
App 계층만 접근 가능한 구조로 설계했습니다.

### 4. NAT Gateway를 통한 아웃바운드 통신
Private App EC2는 Public IP를 갖지 않으므로 인터넷과 직접 통신할 수 없습니다.  
대신 NAT Gateway를 통해 패키지 설치, 업데이트 등의 아웃바운드 통신만 가능하도록 구성했습니다.

### 5. ASG를 통한 확장 구조
App 계층은 Launch Template + Auto Scaling Group으로 구성하여  
다중 AZ 기반 배치와 자동 확장 구조를 구현했습니다.

---

## 서브넷 구성

| 구분 | 이름 | CIDR |
|---|---|---|
| Public | Public-2a | 10.0.1.0/24 |
| Public | Public-2c | 10.0.2.0/24 |
| Private App | Private-App-2a | 10.0.11.0/24 |
| Private App | Private-App-2c | 10.0.12.0/24 |
| Private DB | Private-DB-2a | 10.0.21.0/24 |
| Private DB | Private-DB-2c | 10.0.22.0/24 |

---

## 보안 설계 요약

### ALB Security Group
- Inbound
  - HTTP 80 from `0.0.0.0/0`
- Outbound
  - 기본 전체 허용

### App Security Group
- Inbound
  - HTTP 80 from `3tier-core-SG-ALB`
- Outbound
  - 기본 전체 허용

### DB Security Group
- Inbound
  - MySQL 3306 from `3tier-core-SG-App`
- Outbound
  - 기본 전체 허용

핵심은 아래와 같습니다.

- 인터넷은 ALB만 직접 접근 가능
- App EC2는 ALB를 통해서만 접근 가능
- DB는 App 계층만 접근 가능

---

## 구현 결과
아래 항목을 기준으로 코어 구조 동작을 검증했습니다.

- VPC 및 6개 서브넷 생성 완료
- Internet Gateway / NAT Gateway / Route Table 구성 완료
- ALB, Target Group, Launch Template, ASG 구성 완료
- ASG가 Private App Subnet 2개에 EC2 인스턴스 2대를 생성
- Target Group에서 healthy target 2개 확인
- RDS를 Private DB Subnet Group 기반으로 생성
- RDS Public access = No 확인
- ALB DNS로 접속 시 테스트 페이지 정상 출력 확인
- CloudWatch 최소 알람 구성 완료

---

## 상세 문서
- [구현 단계 정리](./docs/implementation-steps.md)
- [Security Group 설계](./docs/security-group-design.md)
- [트러블슈팅](./docs/troubleshooting.md)

---

## 프로젝트를 통해 학습한 내용
- Public / Private Subnet 분리의 의미
- Internet Gateway와 NAT Gateway의 역할 차이
- Route Table의 `Destination` 과 `Target` 관계
- ALB, Target Group, Launch Template, ASG의 연동 방식
- Security Group을 통한 계층별 접근 제어
- RDS를 Private 영역에 배치하는 구조
- CloudWatch를 통한 최소 운영 모니터링 구성

---

## 한계 및 향후 개선 계획
이번 저장소는 **코어 버전** 구현을 목표로 했기 때문에 아래 항목은 다음 단계로 확장할 예정입니다.

- HTTPS + ACM 적용
- Route 53 도메인 연결
- IAM Role 및 SSM Session Manager 적용
- Launch Template 업데이트 및 Instance Refresh 경험 정리
- CloudWatch 대시보드 구성
- Terraform 코드화
- 운영 고도화 및 배포 자동화 구조 확장

