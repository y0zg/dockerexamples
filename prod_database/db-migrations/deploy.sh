#!/bin/bash
docker build -t y0zh/test-db-migrations .
docker push y0zh/test-db-migrations

ssh deploy@localhost << EOF
docker pull y0zh/test-db-migrations
docker run --net web --rm y0zh/test-db-migrations
docker rmi y0zh/sample-node1
EOF
