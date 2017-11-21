#!/bin/bash
docker build -t y0zh/sample-deploy .
docker push y0zh/sample-deploy

ssh deploy@localhost << EOF
docker pull y0zh/sample-deploy:latest
docker stop web || true
docker rm web || true
docker rmi y0zh/sample-deploy:current || true
docker tag y0zh/sample-deploy:latest y0zh/sample-deploy:current
docker run -d --restart always --name web -p 3000:3000 y0zh/sample-deploy
EOF
