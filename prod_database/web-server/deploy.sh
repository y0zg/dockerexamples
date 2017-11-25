#!/bin/bash
docker build -t y0zh/sample-node1 .
docker push y0zh/sample-node1

ssh deploy@localhost << EOF
docker pull y0zh/sample-node1:latest
docker stop web || true
docker rm web || true
docker rmi y0zh/sample-node1:current || true
docker tag y0zh/sample-node1:latest y0zh/sample-node1:current
docker run -d --net app1 --restart always --name web -p 3000:3000 y0zh/sample-node1:current
EOF
