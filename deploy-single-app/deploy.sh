#!/bin/bash
docker build -t y0zg/sample-node .
docker push y0zg/sample-node

ssh deploy@localhost << EOF
docker pull y0zg/sample-node:latest
docker stop web || true
docker rm web || true
docker rmi y0zg/sample-node:current || true
docker tag y0zg/sample-node:latest y0zg/sample-node:current
docker run -d --restart always --name web -p 3000:3000 y0zg:sample-node
EOF
