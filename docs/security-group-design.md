# Security Group 설계

## 1. 설계 목표
- 인터넷에 노출되는 리소스를 최소화한다.
- 외부 요청은 ALB를 통해서만 수신한다.
- App 서버는 ALB를 통해서만 가능하다.
- DB 접근은 APP 서버를 통해서만 가능하다.

**Internet -> App -> DB**흐름만 허용한다.

---

## 2. 전체 보안 흐름
이 서비스의 네트워크/보안 흐름은 아래와 같다.

- Internet -> ALB
- ALB -> App EC2
- App EC2 -> RDB
- App EC2 -> NAT Gateway -> IGW -> Internet (Outbound)

---

## 3. ALB Security Group

### 이름
- `3tier-core-SG-ALB`

### 역할
ALB는 인터넷에서 들어오는 HTTP 요청을 수신하는 진입점 역할을 한다.

### Inbound 규칙
- HTTP 80
- Source: `0.0.0.0/0`

### Outbound 규칙
- 기본 전체 허용

### 설계 이유
ALB는 외부 사용자의 요청을 직접 받아야 하므로 HTTP 80 포트를 전체 인터넷에 열어야 한다.  
다만 실제 요청 처리는 ALB 뒤의 App 서버가 수행하며, 인터넷에 직접 노출되는 것은 ALB로 제한한다.

---

## 4. App Security Group

### 이름
- `3tier-core-SG-App`

### 역할
App EC2는 실제 어플리케이션의 처리를 담당한다.
이 계층은 외부로 노출되지 않고 ALB를 통해서만 트래픽을 수신 가능하다.

### Inbound 규칙
- HTTP 80
- Source: `3tier-core-SG-ALB`

### Outbound 규칙
- 기본 전체 허용

### 설계 이유
App 서버는 외부에 직접 접근할 필요가 없으므로 ALB를 통해서만 접근 가능하게 인바운드 규칙을 설정하였다.
아웃바운드의 경우
- App 서버는 RDS와 소통해야한다.
- App 서버는 NAT를 통하여 인터넷에 연결돼야한다.
을 고려하여 전체 허용을 했다.

### 배운점
- ALB 요청에 대한 응답은 Stateful 원칙에 의해서 Outbound 규칙과 상관없이 정상적으로 반환된다.
즉, 시큐리티 그룹은 인바운드를 열어놓은곳 (App Ec2의 경우 ALB)에 관하여 별도의 아웃바운드 규칙 없이 정상적으로 반환 가능하다.
App SG의 아웃바운드 규칙이 전체허용인 이유도 RDS와 NAT와의 관계 때문이지 ALB와는 상관이 없다.


---

## 5. DB Security Group

### 이름
- `3tier-core-SG-DB`

### 역할
DB는 어플리케이션 데이터가 저장되는 영역이며, App계층만 접근 가능해야 한다.

### Inbound 규칙
- Mysql 3306
- Source: `3tier-core-SG-App`

### Outbound 규칙
- 기본 전체 허용

### 설계 이유
DB는 인터넷이나 ALB가 직접 접근할 필요가 없으므로,  
App Security Group에서 오는 DB 포트 요청만 허용했다.

즉, App 서버 외의 다른 리소스는 DB에 직접 접근할 수 없도록 제한했다.

Outbound는 기본값을 유지했으며, 이번 코어 프로젝트에서는 인바운드 제한을 중심으로 DB 접근 제어를 구현했다.

---

## 6. 보안 설계 의도 정리
이번 Security Group 설계의 핵심은 계층별 접근 범위를 명확히 제한하는 것이다.

- ALB만 외부 인터넷에 노출
- App는 ALB를 통해서만 접근 가능
- DB는 App만 접근 가능

이 구조를 통해 다음과 같은 보안적 장점을 얻을 수 있다.

- App 서버의 직접 노출 방지
- DB 서버의 직접 노출 방지
- 계층별 접근 경로 명확화
- 최소 권한 원칙에 가까운 구조 설계

이번 프로젝트는 코어 버전이므로 outbound 규칙은 운영 편의성과 구현 단순성을 고려해 기본 허용으로 두었다.  
향후 고도화 단계에서는 필요한 목적지와 포트만 허용하도록 outbound를 더 세밀하게 제한할 수 있다.

