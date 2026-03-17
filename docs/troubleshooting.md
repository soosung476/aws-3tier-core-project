# Troubleshooting

이 문서는 AWS 3-Tier Core Project를 구현하면서 실제로 겪었던 문제와 해결 과정을 정리한 기록이다.  
구현 과정에서 발생한 문제를 원인과 함께 정리하여, 이후 비슷한 구조를 만들 때 참고할 수 있도록 했다.

---

## 1. DB Subnet Group 이름 생성 실패

### 문제
DB Subnet Group 생성 시 `3tier-core-db-subnet-group` 이름을 사용할 수 없었다.

### 원인
RDS DB Subnet Group 이름은 숫자로 시작할 수 없어서, `3tier-...` 형식의 이름이 거절되었다.

### 해결
숫자로 시작하지 않도록 이름을 변경했다.

- 변경 전: `3tier-core-db-subnet-group`
- 변경 후: `tier3-core-db-subnet-group`

### 배운 점
RDS 관련 리소스는 EC2나 SG와 달리 이름 규칙이 더 엄격할 수 있으므로,  
생성 실패 시 단순 오타뿐 아니라 리소스별 naming rule도 확인해야 한다.

---

## 2. NAT Gateway의 위치와 역할이 처음에는 헷갈렸음

### 문제
처음에는 NAT Gateway를 왜 Public Subnet에 두는지 이해가 잘 되지 않았다.  
Private App EC2가 인터넷에 나가야 하므로 NAT를 Private 쪽에 둬야 하는 것처럼 느껴졌다.

### 원인
NAT Gateway의 목적이 “Private 인스턴스 대신 외부 인터넷으로 나가주는 출구”라는 점을 정확히 이해하지 못했다.

### 해결
구조를 다음과 같이 정리하면서 이해했다.

- Private App EC2는 Public IP가 없음
- 외부 목적지로 가는 패킷은 NAT Gateway로 전달
- NAT Gateway는 Public Subnet에 위치
- NAT Gateway는 Elastic IP를 이용해 외부 인터넷과 통신
- 그 경로는 NAT Gateway → Internet Gateway → Internet

### 배운 점
NAT Gateway는 Private Subnet에 있는 리소스가 사용하는 출구이지만,  
실제 NAT Gateway 자체는 **반드시 Public Subnet에 위치해야** 인터넷 연결이 가능하다.

---

## 3. Route Table의 `0.0.0.0/0` 과 Target 관계가 처음에는 헷갈렸음

### 문제
처음에는 `0.0.0.0/0` 이 “어디와 통신한다”는 의미처럼 느껴져서,  
Destination과 Target의 관계를 머릿속으로 바로 이해하기 어려웠다.

### 원인
라우팅 테이블을 “누가 들어오느냐” 기준으로 생각해서 헷갈렸다.  
실제로는 “내가 어디로 가고 싶을 때 다음으로 어디에 넘길지”를 정하는 표이다.

### 해결
Route Table을 아래처럼 이해하면서 정리했다.

- **Destination**: 최종 목적지
- **Target**: 그 목적지로 가기 위해 먼저 넘길 다음 대상

예:
- Public RT  
  - `0.0.0.0/0 -> Internet Gateway`
- Private App RT  
  - `0.0.0.0/0 -> NAT Gateway`

즉,
- Public Subnet은 외부 목적지로 직접 나갈 때 IGW 사용
- Private App Subnet은 외부 목적지로 나갈 때 NAT 사용

### 배운 점
라우팅 테이블은 “누가 나에게 오나”가 아니라  
“내 패킷이 목적지에 가기 위해 다음에 누구에게 가야 하나”로 이해해야 헷갈리지 않는다.

---

## 4. Security Group Outbound 규칙이 왜 전체 허용인지 처음에는 이해가 어려웠음

### 문제
App 서버는 ALB와 DB만 통신하는 것처럼 보였기 때문에,  
왜 App Security Group의 Outbound를 `0.0.0.0/0` 으로 두는지 처음에는 이해하기 어려웠다.

### 원인
요청 응답 흐름과 서버 운영에 필요한 아웃바운드 통신을 구분하지 못했다.

### 해결
아래처럼 정리하면서 이해했다.

- ALB를 통해 들어온 요청에 대한 응답은 SG의 **stateful 특성** 때문에 별도 outbound 규칙 없이도 돌아갈 수 있음
- 하지만 App EC2는 다음과 같은 외부 통신이 필요할 수 있음
  - `apt update`
  - 패키지 설치
  - 외부 저장소 접근
  - 외부 API 호출

즉, App Security Group의 outbound를 넓게 둔 이유는
ALB 때문이 아니라 **NAT를 통한 외부 통신**까지 고려한 것이었다.

### 배운 점
보안 그룹에서 inbound와 outbound는 “누가 먼저 연결을 시작하느냐” 관점으로 이해해야 한다.  
특히 SG의 stateful 특성을 이해하면 ALB/App/DB 흐름이 훨씬 덜 헷갈린다.

---

## 5. Launch Template 화면에서 Security Group 이름이 보이지 않음

### 문제
Launch Template 상세 화면에서 `Security groups` 항목은 `-` 로 표시되어 있어서  
App Security Group이 제대로 연결되지 않은 것처럼 보였다.

### 원인
콘솔 표시 방식상 Security Group 이름 대신 `Security group IDs` 가 보이는 형태였다.

### 해결
화면에서 표시된 `Security group ID` 를 기준으로 확인했고,  
실제 연결된 보안 그룹이 `3tier-core-SG-App` 임을 검증했다.

### 배운 점
AWS 콘솔은 화면에 따라 Security Group 이름이 아니라 ID만 보여줄 수 있다.  
이 경우에는 실제 SG ID를 기준으로 리소스 연결 여부를 확인해야 한다.

---

## 6. ALB 다이어그램 표현에서 개념적으로 헷갈렸음

### 문제
처음에는 “사용자가 ALB로 들어온 뒤 Public Subnet으로 들어간다”는 식으로 이해해서,  
다이어그램에서 `ALB -> Public Subnet` 화살표를 그려야 하는지 혼란스러웠다.

### 원인
“리소스가 어느 서브넷에 배치되어 있는가”와 “실제 요청 흐름”을 구분하지 못했다.

### 해결
개념을 아래처럼 정리했다.

- 사용자는 **Public Subnet 자체**에 접속하는 것이 아님
- 사용자는 **Public Subnet에 배치된 ALB** 에 접속
- ALB가 Target Group을 통해 Private App EC2로 요청 전달
- Public Subnet은 ALB가 위치하는 네트워크 영역

그래서 README용 다이어그램에서는:
- ALB를 Public Tier 안에 배치
- 화살표는 `User → ALB → App → RDS` 중심으로 단순화
- ALB가 Public Subnet에 있다는 사실은 **위치로 표현**

하는 방식으로 정리했다.

### 배운 점
다이어그램에서는 **배치 구조**와 **요청 흐름**을 분리해서 표현해야 가독성이 좋아진다.

---

## 7. CloudWatch 알람 생성 시 UI가 예상과 달라 혼란스러웠음

### 문제
CloudWatch 알람 생성 과정에서 예전 설명처럼 `Evaluation periods` 입력칸이 바로 보이지 않았고,  
Notification 설정도 예상과 다른 UI로 보여 혼란스러웠다.

### 원인
AWS 콘솔 UI가 변경되어, 현재는 조건 설정이 다음처럼 구성되어 있었다.

- Metric
- Conditions
- Additional configuration
- Notification

특히 평가 기간은 별도 입력칸이 아니라  
`Datapoints to alarm` 과 `out of` 형식으로 설정되었다.

### 해결
현재 콘솔 UI 기준으로 다음과 같이 이해했다.

- `2 out of 2`
  - 2개의 평가 구간 중 2개가 임계값을 넘으면 알람
- Notification은 SNS topic 생성 또는 기존 topic 선택 방식
- 이번 프로젝트에서는 이메일 알림 없이 콘솔 알람만 생성

### 배운 점
CloudWatch는 콘솔 UI가 바뀔 수 있으므로,  
이전 기억보다 현재 실제 화면 흐름을 기준으로 확인하는 것이 중요하다.

---

## 8. EC2 CPU 알람 생성 시 인스턴스 선택이 어려웠음

### 문제
CloudWatch에서 EC2 CPU 알람을 만들 때,  
이미 삭제된 인스턴스까지 목록에 섞여 있어서 현재 ASG 인스턴스를 바로 찾기 어려웠다.

### 원인
CloudWatch metric 선택 화면에는 과거 인스턴스 메트릭도 함께 보일 수 있다.

### 해결
다음 순서로 현재 인스턴스를 확인했다.

1. Auto Scaling Group → Instance management
2. 현재 `InService`, `Healthy` 상태인 인스턴스 ID 확인
3. CloudWatch metric 검색창에 해당 인스턴스 ID로 검색
4. 현재 살아 있는 App EC2에 대해 CPU 알람 생성

### 배운 점
CloudWatch에서 EC2 인스턴스를 찾을 때는 EC2 전체 목록을 눈으로 찾기보다,  
ASG에서 현재 인스턴스 ID를 먼저 확인한 뒤 검색하는 방식이 훨씬 효율적이다.

---

## 9. 이번 프로젝트에서 얻은 가장 큰 정리

이번 프로젝트를 통해 가장 크게 정리된 개념은 다음과 같다.

- 인터넷에서 직접 접근 가능한 것은 ALB만 둔다
- App EC2와 RDS는 모두 Private Subnet에 둔다
- Public / Private 구분은 이름이 아니라 Route Table과 연결 구조가 결정한다
- Security Group은 계층별 접근 범위를 제한하는 핵심 수단이다
- NAT Gateway는 Private App 서버의 아웃바운드 통신을 위한 리소스다
- 다이어그램은 배치 구조와 요청 흐름을 분리해서 표현해야 읽기 쉽다

이러한 이해를 바탕으로, 이후 HTTPS, IAM Role, SSM, Terraform 단계로 확장할 계획이다.