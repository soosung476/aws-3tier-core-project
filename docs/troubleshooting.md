
NAT Gateway 역할
왜 Elastic IP가 필요한가? Elastic IP = 고정IP
우리가 와이파이를 쓸때 공유기가 공유 IP를 담당하고 사설 IP를 가진 여러 기기가 공유기를 통해 인터넷과 소통하듯
Elastic IP가 그 역할을 해준다고 생각하면 된다.


라우터 테이블의 destination, target 관계
destination은 최종 목적지, target은 최종 목적지에 도달하기 위해 가야하는 다음 홉.
예를 들어 Private App EC2에서 외부에 연결하고 싶을 때
Private subnet은 NAT에게 패킷을 넘김
NAT는 공인IP (엘라스틱 IP)로 IGW를 통해서 인터넷에 보냄.
인터넷에서 정보가 들어오면 수신. 이걸 다시 사설 IP로 바꿔서 Private App으로 돌아옴.
