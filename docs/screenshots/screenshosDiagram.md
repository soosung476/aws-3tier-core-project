docs/screenshots/
├─ 01-vpc-created.png
├─ 02-subnets-created.png
├─ 03-igw-attached.png
├─ 04-nat-gateway-created.png
├─ 05-route-table-public.png
├─ 06-route-table-private-app.png
├─ 07-route-table-private-db.png
├─ 08-security-group-alb.png
├─ 09-security-group-app.png
├─ 10-security-group-db.png
├─ 11-rds-created.png
├─ 12-launch-template.png
├─ 13-target-group-healthy.png
├─ 14-alb-created.png
├─ 15-asg-instances.png
├─ 16-alb-web-test.png
├─ 17-cloudwatch-alarms.png

너무 넓게 찍지 말기
핵심 정보가 보이게 적당히 잘라서 중요한 값이 보이게 찍기

예:
subnet 이름
route destination/target
SG source
health status

민감정보는 가리기

DB endpoint는 경우에 따라 가려도 됨
계정 ID는 굳이 노출 안 해도 됨
퍼블릭 IP, 내부 정보는 필요 시 일부 가리기
한 화면에 한 메시지

예:

“서브넷 구성이 완료되었다”
“App route table이 NAT로 연결되었다”
“Target group이 healthy 상태다”
이런 식으로 캡처 1장당 전달 메시지가 명확하게끔