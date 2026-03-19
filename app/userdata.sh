#!/bin/bash
dnf update -y || yum update -y

dnf install -y nginx || yum install -y nginx

cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>AWS 3-Tier Core Project</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 40px;
      background: #f4f6f8;
      color: #222;
    }
    .card {
      max-width: 700px;
      margin: 0 auto;
      background: white;
      padding: 30px;
      border-radius: 12px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.08);
    }
    h1 {
      margin-top: 0;
      color: #1a73e8;
    }
    p {
      line-height: 1.6;
    }
    code {
      background: #eef2f7;
      padding: 2px 6px;
      border-radius: 6px;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>AWS 3-Tier Core Project</h1>
    <p>이 페이지는 Auto Scaling Group으로 생성된 Private App EC2에서 제공되고 있습니다.</p>
    <p>웹 요청 흐름: <code>ALB → App EC2 → RDS</code></p>
    <p>배포 확인 시간: $(date)</p>
  </div>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx