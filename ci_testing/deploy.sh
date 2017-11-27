#!/bin/bash
docker build -t y0zh/sample-node .
docker push y0zh/sample-node

ssh sh -p 64788 ubuntu@18.221.30.52<< EOF
docker pull y0zh/sample-node:latest
docker stop web || true
docker rm web || true
docker rmi y0zh/sample-node:current || true
docker tag y0zh/sample-node:latest y0zh/sample-node:current
docker run -d --net app --restart always --name web -p 3000:3000 y0zh/sample-node:current
EOF
