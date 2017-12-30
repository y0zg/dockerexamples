#!/bin/bash
docker build -t y0zh/test-node .
docker push y0zh/test-node

ssh $USER@localhost << 'EOF'
    for i in `seq 1 3`
    do
      docker -H :4000 build --build-arg="affinity:container==~web$i" --pull - <<< "FROM y0zh/test-node"
      docker -H :4000 stop web$i || true
      docker -H :4000 rm web$i || true
      docker -H :4000 run -d --restart always --net apps --name web$i \
        -e constraint:type==apps \
        -e SERVICE_VIRTUAL_HOST=test.com \
        -e SERVICE_NAME=web \
        -e SERVICE_TAGS=nginx:production \
        -e SERVICE_PORT=3000 \
        y0zh/test-node
    done
EOF
