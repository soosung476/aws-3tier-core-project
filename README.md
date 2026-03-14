# AWS 3-Tier Core Project

## 1. 프로젝트 개요
이 프로젝트는 **클라우드 / 시스템 엔지니어 취업 포트폴리오**를 목표로 만든 AWS 기반 3-Tier 아키텍처 코어 프로젝트입니다.

**퍼블릭과 프라이빗 네트워크를 분리하고**,  
**ALB - App 서버 - RDS** 구조를 구성하여  
실무형 인프라 설계 흐름을 이해하고 구현하는 것을 목표로 했습니다.

최종적으로는 AWS Console 기반으로 코어 구조를 먼저 완성한 뒤,  
다음 단계에서 Terraform으로 코드화하는 것까지 확장할 계획입니다.

아키텍처 흐름:

**Client → ALB (Public) → App EC2 (Private) → RDS (Private)**

---

## 2. 프로젝트 목표
- AWS 기반 3-Tier 아키텍처 코어 버전 구현
- Public / Private Subnet 분리 설계
- ALB를 통한 트래픽 분산
- Auto Scaling Group을 통한 App 계층 가용성 확보
- App 서버의 Private Subnet 배치
- RDS의 Private DB Subnet 배치
- NAT Gateway를 통한 Private App 서버의 아웃바운드 인터넷 통신 구성
- Security Group 최소 권한 설계
- CloudWatch 최소 모니터링 구성
- 이후 Terraform 전환이 가능한 구조로 설계

---

## 3. 아키텍처 구성


## 4. 앞으로 넣어야 할 자료
- 전체 아키텍처 그림
- 사용한 AWS 서비스
- 핵심 설계 이유
- 구현 범위
- 검증 결과 요약
- 상세 문서 링크
- 향후 개선 계획